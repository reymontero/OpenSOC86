//
//    This file is part of the OpenSOC86 project
//    Copyright (c) 2013-2014 Roy van Koten
//
//    This 'system on chip' (SOC) is free hardware: you can redistribute it
//    and/or modify it under the terms of the GNU General Public License as
//    published by the Free Software Foundation, either version 3 of the
//    License, or (at your option) any later version.
//
//    This SOC is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//


module Divider
	(
		input							iClk,
		
		input							iStall,
		
		input							iReq,
		input							iSgn,
		input							iBW,
		
		input				[31:0]	iNumer,
		input				[15:0]	iDenom,
		
		output	reg	[15:0]	oQuotient,
		output	reg	[15:0]	oRemain,
		output	reg				oAck,
		output	reg				oErr
	);

reg [31:0] inpNum;

reg curBW;
reg [31:0] curNum;
reg [15:0] curDen;
reg curSgnNum;
reg curSgnDen;
reg finSgn;

reg [31:0] iPosNum;	//wire
reg [15:0] iPosDen;	//wire
reg iSgnNum;	//wire
reg iSgnDen;	//wire

wire doSub = (curNum[31:15] >= {1'b0, curDen});
reg [16:0] nxtNum;	//wire

reg OFlow;
reg [15:0] Quot;

reg [3:0] cnt;
reg [1:0] state;

initial
begin
	oQuotient = 16'd0;
	oRemain = 16'd0;
	oAck = 1'b0;
	oErr = 1'b0;

	curNum = 32'd0;
	curDen = 16'd0;
	curSgnNum = 1'b0;
	curSgnDen = 1'b0;
	finSgn = 1'b0;
	
	OFlow = 1'b0;
	Quot = 16'd0;
	
	cnt = 4'd0;
	state = 2'd0;
end

always @(posedge iClk)
begin
	oAck <= 1'b0;
	case (state)
		2'd0:	if (iReq & ~iStall)
			begin
				inpNum <= iNumer;
				
				iSgnNum = (iBW) ? iNumer[31] : iNumer[15];
				iSgnDen = (iBW) ? iDenom[15] : iDenom[7];
				iPosNum = (iSgn & iSgnNum) ? (~iNumer + 32'd1) : iNumer;
				iPosDen = (iSgn & iSgnDen) ? (~iDenom + 16'd1) : iDenom;
				
				curNum[31:0] <= (iBW) ? iPosNum : {8'b0, iPosNum[15:0], 8'b0};
				curDen <= (iBW) ? iPosDen : {8'b0, iPosDen[7:0]};
				curSgnNum <= iSgn & iSgnNum;
				curSgnDen <= iSgn & iSgnDen;
				finSgn <= iSgn & (iSgnNum ^ iSgnDen);
				curBW <= iBW;
				
				oErr <= 1'b0;
				OFlow <= (iDenom == 16'd0) ? 1'b1 : 1'b0;
				Quot <= 16'd0;
				
				cnt <= (iBW) ? 4'd0 : 4'd8;
				state <= 2'd1;
			end
		2'd1:	begin
				nxtNum = (doSub) ? (curNum[31:15] - {1'b0, curDen}) : curNum[31:15];
				if (curBW)
					OFlow <= OFlow | nxtNum[16];
				else
					OFlow <= OFlow | nxtNum[8];
				curNum <= {nxtNum[15:0], curNum[14:0], 1'b0};
				Quot <= {Quot[14:0], doSub};
				
				cnt <= cnt + 4'd1;
				if (cnt == 4'd15)
					state <= 2'd2;
			end
		2'd2:	begin
				if (OFlow)
				begin
					oQuotient <= inpNum[15:0];
					oRemain <= inpNum[31:16];
				end else begin
					oQuotient <= (finSgn) ? (~Quot + 16'd1) : Quot;
					oRemain <= (curSgnNum) ? (~curNum[31:16] + 16'd1) : curNum[31:16];
				end
				oErr <= OFlow;
				oAck <= 1'b1;
				state <= 2'd0;
			end
		2'd3: state <= 2'd0;
	endcase
end

endmodule
