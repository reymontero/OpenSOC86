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


module LenDec
	(
		input					iClk,
		
		input			[7:0]	iOP0,
		input			[7:0]	iOP1,
		
		output		[2:0]	oLen,
		output				oMod
	);

reg	[2:0]	CntR;
reg	[2:0]	CntM;
reg	[2:0]	CntA;

wire tM0 = (((iOP0 & 8'hC4) == 8'h00) ? 1'b1 : 1'b0);
wire tM1 = (((iOP0 & 8'hF0) == 8'h80) ? 1'b1 : 1'b0);
wire tM2 = (((iOP0 & 8'hFC) == 8'hC4) ? 1'b1 : 1'b0);
wire tM3 = (((iOP0 & 8'hFC) == 8'hD0) ? 1'b1 : 1'b0);
wire tM4 = (((iOP0 & 8'hF8) == 8'hD8) ? 1'b1 : 1'b0);
wire tM5 = (((iOP0 & 8'hF6) == 8'hF6) ? 1'b1 : 1'b0);

wire Mod = tM0 | tM1 | tM2 | tM3 | tM4 | tM5;
assign oMod = Mod;

reg [2:0] tLen;
assign oLen = tLen;

always @(*)
begin
	casex (iOP0)
		8'b00xxx100,
		8'b0111xxxx,
		8'b10101000,
		8'b10110xxx,
		8'b11001101,
		8'b1101010x,
		8'b11100xxx,
		8'b11101011:
			CntR = 3'd2;
		8'b00xxx101,
		8'b101000xx,
		8'b10101001,
		8'b10111xxx,
		8'b1100x010,
		8'b1110100x:
			CntR = 3'd3;
		8'b10011010,
		8'b11101010:
			CntR = 3'd5;
		default:
			CntR = 3'd1;
	endcase
	
	casex (iOP0)
		8'b100000xx:	CntM = (iOP0[1:0] == 2'b01) ? 3'd4 : 3'd3;
		8'b1100011x:	CntM = (iOP0[0] == 1'b1) ? 3'd4 : 3'd3;
		8'b1111011x: 	if (iOP1[5:3] == 3'b000)
					CntM = (iOP0[0] == 1'b1) ? 3'd4 : 3'd3;	//!!!! mod 000 r/m
				else
					CntM = 3'd2;
		default:
			CntM = 3'd2;
	endcase
	
	case (iOP1[7:6])
		2'b00:	if (iOP1[2:0] == 3'b110)
				CntA = 3'd2;
			else
				CntA = 3'd0;
		2'b01:	CntA = 3'd1;
		2'b10:	CntA = 3'd2;
		2'b11:	CntA = 3'd0;
	endcase
	
	tLen = (Mod == 1'b1) ? (CntM + CntA) : CntR;
end

endmodule
