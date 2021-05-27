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



module I8237
	(
		input							iClk,
		
		input				[1:0]		iRW,
		input				[4:0]		iAdr,
		input				[7:0]		iData,
		output	reg	[7:0]		oData,
		output	reg				oAck,
		
		input							DREQ0,
		input							DREQ1,
		input							DREQ2,
		input							DREQ3,
		
		output	reg				DACK0,
		output	reg				DACK1,
		output	reg				DACK2,
		output	reg				DACK3,
		
		//output	reg	[15:0]	oMemAdr,
		//output	reg	[1:0]		oMemRW,
		//output	reg	[7:0]		oMemData,
		//input				[7:0]		iMemData
		
		output			[23:0]	oMemAdr0,
		output			[15:0]	oMemCnt0,
		output			[23:0]	oMemAdr1,
		output			[15:0]	oMemCnt1,
		output			[23:0]	oMemAdr2,
		output			[15:0]	oMemCnt2,
		output			[23:0]	oMemAdr3,
		output			[15:0]	oMemCnt3
	);

reg	[7:0]		PAGE[0:3];

reg	[15:0]	BADR[0:3];
reg	[15:0]	BCNT[0:3];
reg	[15:0]	CADR[0:3];
reg	[15:0]	CCNT[0:3];

reg	[15:0]	TADR;
reg	[15:0]	TCNT;

reg	[7:0]		STAT;
reg	[7:0]		CMD;
reg	[7:0]		TMP;
reg	[5:0]		MODE[0:3];

reg	[3:0]		MASK;
reg	[3:0]		REQ;

reg				flip;

reg	[3:0]		pri_req;
reg	[1:0]		pri_hi;
reg	[1:0]		pri_srv;
reg	[1:0]		cur_srv;

reg	[1:0]		state;

assign oMemCnt0 = CCNT[0];
assign oMemCnt1 = CCNT[1];
assign oMemCnt2 = CCNT[2];
assign oMemCnt3 = CCNT[3];

assign oMemAdr0 = {PAGE[0], CADR[0]};
assign oMemAdr1 = {PAGE[1], CADR[1]};
assign oMemAdr2 = {PAGE[2], CADR[2]};
assign oMemAdr3 = {PAGE[3], CADR[3]};

integer i;

initial
begin
	//PAGE = 8'd0;
	
	for (i = 0; i < 4; i=i+1)
	begin
		PAGE[i] = 8'd0;
		
		BADR[i] = 16'b0;
		BCNT[i] = 16'b0;
		CADR[i] = 16'b0;
		CCNT[i] = 16'b0;
		MODE[i] = 6'b0;
	end
end

always @(posedge iClk)
begin
	oAck <= 1'b0;
	if (iRW[1] == 1'b1)
	begin
		casex (iAdr[4:0])
			5'b00xx0:	if (flip == 0)
					begin
						oData <= CADR[iAdr[2:1]][7:0];
						flip <= 1'b1;
					end else begin
						oData <= CADR[iAdr[2:1]][15:8];
						flip <= 1'b0;
					end
			5'b00xx1:	if (flip == 0)
					begin
						oData <= CCNT[iAdr[2:1]][7:0];
						flip <= 1'b1;
					end else begin
						oData <= CCNT[iAdr[2:1]][15:8];
						flip <= 1'b0;
					end
			5'd8:		oData <= STAT;
			5'd13:	oData <= TMP;
			5'b10001:	oData <= PAGE[2][7:0];
			5'b10010:	oData <= PAGE[3][7:0];
			5'b10011:	oData <= PAGE[1][7:0];
			5'b10111:	oData <= PAGE[0][7:0];
			default:	begin end
		endcase
		oAck <= 1'b1;
	end
	
	if (iRW[0] == 1'b1)
	begin
		casex (iAdr[4:0])
			5'b00xx0:	if (flip == 0)
					begin
						BADR[iAdr[2:1]][7:0] <= iData;
						CADR[iAdr[2:1]][7:0] <= iData;
						flip <= 1'b1;
					end else begin
						BADR[iAdr[2:1]][15:8] <= iData;
						CADR[iAdr[2:1]][15:8] <= iData;
						flip <= 1'b0;
					end
			5'b00xx1:	if (flip == 0)
					begin
						BCNT[iAdr[2:1]][7:0] <= iData;
						CCNT[iAdr[2:1]][7:0] <= iData;
						flip <= 1'b1;
					end else begin
						BCNT[iAdr[2:1]][15:8] <= iData;
						CCNT[iAdr[2:1]][15:8] <= iData;
						flip <= 1'b0;
					end
			5'd8:		begin
						CMD <= iData;
						if (iData[4] == 0)
							pri_hi <= 0;
					end
			5'd9:		case (iData[1:0])
						2'd0:	REQ[0] <= iData[2];
						2'd1:	REQ[1] <= iData[2];
						2'd2:	REQ[2] <= iData[2];
						2'd3:	REQ[3] <= iData[2];
					endcase
			5'd10:		case (iData[1:0])
						2'd0:	MASK[0] <= iData[2];
						2'd1:	MASK[1] <= iData[2];
						2'd2:	MASK[2] <= iData[2];
						2'd3:	MASK[3] <= iData[2];
					endcase
			5'd11:	MODE[iData[1:0]] <= iData[5:0];
			5'd12:	flip <= 1'b0;
			5'd13:	begin
					CMD <= 0;
					STAT <= 0;
					REQ <= 0;
					TMP <= 0;
					flip <= 0;
					MASK <= 4'b1111;
					pri_hi <= 0;
				end
			5'd14:	begin end
			5'd15:	MASK <= iData[3:0];
			5'b10001:	PAGE[2] <= {8'b0, iData[7:0]};
			5'b10010:	PAGE[3] <= {8'b0, iData[7:0]};
			5'b10011:	PAGE[1] <= {8'b0, iData[7:0]};
			5'b10111:	PAGE[0] <= {8'b0, iData[7:0]};
		endcase
	end
	
	pri_req = ({DREQ3, DREQ2, DREQ1, DREQ0, DREQ3, DREQ2, DREQ1, DREQ0} | {REQ, REQ}) >> pri_hi;
	casex (pri_req[3:0])
		4'b0000:	pri_srv <= 2'd0;
		4'bxxx1:	pri_srv <= 2'd0;
		4'bxx10:	pri_srv <= 2'd1;
		4'bx100:	pri_srv <= 2'd2;
		4'b1000:	pri_srv <= 2'd3;
	endcase
	
	case (state)
		2'd0:	begin
				cur_srv <= pri_srv + pri_hi;
				if (pri_req != 0)
					state <= 2'd1;
			end
		2'd1:	begin end
		2'd2:	begin end
		2'd3:	begin end
	endcase

end

endmodule
