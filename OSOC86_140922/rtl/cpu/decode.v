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



module decode
	(

		input							iClk,
		input							iRst,
		
		input							iJumped,
		
		input				[47:0]	iBuf48,
		//input				[10:0]	iDec,
		//input 			[1:0]		iDispCnt,
		input				[2:0]		iLen,
		input							iAck,
		
		output	reg	[7:0]		I_OP0,
		output	reg	[7:0]		I_OP1,
		output	reg	[15:0]	imm,
		output	reg	[15:0]	offset,
		output	reg	[2:0]		oUsed,
		
		output	reg				oAck
	);


wire	[7:0]		iBuf0 = iBuf48[7:0];
wire	[7:0]		iBuf1 = iBuf48[15:8];
wire	[7:0]		iBuf2 = iBuf48[23:16];
wire	[7:0]		iBuf3 = iBuf48[31:24];
wire	[7:0]		iBuf4 = iBuf48[39:32];
wire	[7:0]		iBuf5 = iBuf48[47:40];

wire	[7:0]		First = iBuf48[7:0];
wire	[7:0]		Second = iBuf48[15:8];

	//---------------------------------------------------
wire	tM0 = (((First & 8'hC4) == 8'h00) ? 1'b1 : 1'b0);	//11000100 C4 00 08'hxx0dw mmregr/m
wire	tM1 = (((First & 8'hF0) == 8'h80) ? 1'b1 : 1'b0);	//11110000 F0 80 1008'hxxx mmxxxr/m
wire	tM2 = (((First & 8'hFC) == 8'hC4) ? 1'b1 : 1'b0);	//11111100 FC C4 110001xx mmregr/m
wire	tM3 = (((First & 8'hFC) == 8'hD0) ? 1'b1 : 1'b0);	//11111100 FC D0 110100vw mmxxxr/m
wire	tM4 = (((First & 8'hF8) == 8'hD8) ? 1'b1 : 1'b0);	//11111000 F8 D8 11011xxx mmxxxr/m
wire	tM5 = (((First & 8'hF6) == 8'hF6) ? 1'b1 : 1'b0);	//11110110 F6 F6 1111x11w mmxxxr/m

//wire	tOp = (((First & 8'hFE) == 8'hD4) ? 1'b1 : 1'b0);	//11111110 FE D4 1101018'h 00001010

wire	tD0 = (((First & 8'hFC) == 8'h80) ? 1'b1 : 1'b0);	//11111100 FC 80 100000sw mmxxxr/m data data if sw = 01
wire	tD1 = (((First & 8'hFE) == 8'hC6) ? 1'b1 : 1'b0);	//11111110 FE C6 1100011w mm000r/m data data if w = 1
wire	tD2 = (((First & 8'hFE) == 8'hF6) ? (((Second & 8'h38) == 8'h00) ? 1'b1 : 1'b0) : 1'b0);	//11111110 FE F6 1111011w mm000r/m data data if w = 1
wire	tD3 = (((First & 8'hC6) == 8'h04) ? 1'b1 : 1'b0);	//11000110 C6 04 08'hxx10w			 data data if w = 1
wire	tD4 = (((First & 8'hFE) == 8'hA8) ? 1'b1 : 1'b0);	//11111110 FE A8 1010100w			 data data if w = 1
wire	tD5 = (((First & 8'hF0) == 8'hB0) ? 1'b1 : 1'b0);	//11110000 F0 B0 1011w			data data if w = 1
wire  tD6 = (((First & 8'hFE) == 8'hD4) ? 1'b1 : 1'b0);

wire	tBW0 = (tD0 | tD1 | tD2 | tD3 | tD4) & First[0];
wire	tBW1 = tD5 & First[3];

wire	tSE = (((First & 8'hFE) == 8'h82) ? 1'b1 : 1'b0);	//11111110 FE 82 100000sw mmxxxr/m data data if sw = 01

wire	tS0 = (((First & 8'hFF) == 8'h9A) ? 1'b1 : 1'b0);	//11111111 FF 9A 10011010 offset-low offset-high seg-low seg-high
wire	tS1 = (((First & 8'hFF) == 8'hEA) ? 1'b1 : 1'b0);	//11111111 FF EA 11101010 offset-low offset-high seg-low seg-high

wire	tW0 = (((First & 8'hFC) == 8'hA0) ? 1'b1 : 1'b0);	//11111100 FC A0 101008'hw addr-low addr-high
wire	tW1 = (((First & 8'hFE) == 8'hE8) ? 1'b1 : 1'b0);	//11111110 FE E8 1110108'h disp-low disp-high
wire	tW2 = (((First & 8'hF7) == 8'hC2) ? 1'b1 : 1'b0);	//11110111 F7 C2 1108'h010 data-low data-high

wire	tP0 = (((First & 8'hFF) == 8'hCD) ? 1'b1 : 1'b0);	//11111111 FF CD 11001101 type
wire	tP1 = (((First & 8'hFC) == 8'hE4) ? 1'b1 : 1'b0);	//11111100 FC E4 111001xw port

wire	tJ0 = (((First & 8'hFF) == 8'hEB) ? 1'b1 : 1'b0);	//11111111 FF EB 11101011 disp
wire	tJ1 = (((First & 8'hFC) == 8'hE0) ? 1'b1 : 1'b0);	//11111100 FC E0 111008'hx disp
wire	tJ2 = (((First & 8'hF0) == 8'h70) ? 1'b1 : 1'b0);	//11110000 F0 70 0111xxxx disp
	//---------------------------------------------------
wire	tO0 = (((First & 8'hC6) == 8'h06) ? 1'b1 : 1'b0);	//11000110 C6 06 08'hxx11x
wire	tO1 = (((First & 8'hE0) == 8'h40) ? 1'b1 : 1'b0);	//11100000 E0 40 018'hxreg
wire	tO2 = (((First & 8'hF8) == 8'h90) ? 1'b1 : 1'b0);	//11111000 F8 90 10010reg
wire	tO3 = (((First & 8'hFE) == 8'h98) ? 1'b1 : 1'b0);	//11111110 FE 98 1001108'h
wire	tO4 = (((First & 8'hFF) == 8'h9B) ? 1'b1 : 1'b0);	//11111111 FF 9B 10011011
wire	tO5 = (((First & 8'hFC) == 8'h9C) ? 1'b1 : 1'b0);	//11111100 FC 9C 100111xx
wire	tO6 = (((First & 8'hFC) == 8'hA4) ? 1'b1 : 1'b0);	//11111100 FC A4 101001xw
wire	tO7 = (((First & 8'hFE) == 8'hAA) ? 1'b1 : 1'b0);	//11111110 FE AA 1010101w
wire	tO8 = (((First & 8'hFC) == 8'hAC) ? 1'b1 : 1'b0);	//11111100 FC AC 101011xw
wire	tO9 = (((First & 8'hF7) == 8'hC3) ? 1'b1 : 1'b0);	//11110111 F7 C3 1108'h011
wire	tOA = (((First & 8'hFF) == 8'hCC) ? 1'b1 : 1'b0);	//11111111 FF CC 11001100
wire	tOB = (((First & 8'hFE) == 8'hCE) ? 1'b1 : 1'b0);	//11111110 FE CE 1100111x
wire	tOC = (((First & 8'hFF) == 8'hD7) ? 1'b1 : 1'b0);	//11111111 FF D7 11010111
wire	tOD = (((First & 8'hFC) == 8'hEC) ? 1'b1 : 1'b0);	//11111100 FC EC 111011xw
wire	tOE = (((First & 8'hFF) == 8'hF0) ? 1'b1 : 1'b0);	//11111111 FF F0 11110000
wire	tOF = (((First & 8'hFE) == 8'hF2) ? 1'b1 : 1'b0);	//11111110 FE F2 1111001z
wire	tOG = (((First & 8'hFE) == 8'hF4) ? 1'b1 : 1'b0);	//11111110 FE F4 1111018'h
wire	tOH = (((First & 8'hFC) == 8'hF8) ? 1'b1 : 1'b0);	//11111100 FC F8 111118'hx
wire	tOI = (((First & 8'hFE) == 8'hFC) ? 1'b1 : 1'b0);	//11111110 FE FC 1111118'h
	//---------------------------------------------------
wire	tU0 = (((First & 8'hF0) == 8'h60) ? 1'b1 : 1'b0);	//11110000 F0 60 0118'hxxx
wire	tU1 = (((First & 8'hF6) == 8'hC0) ? 1'b1 : 1'b0);	//11110110 F6 C0 1108'h08'h
wire	tU2 = (((First & 8'hFF) == 8'hD6) ? 1'b1 : 1'b0);	//11111111 FF D6 11010110
wire	tU3 = (((First & 8'hFF) == 8'hF1) ? 1'b1 : 1'b0);	//11111111 FF F1 11110001
	//---------------------------------------------------
wire	Mod = tM0 | tM1 | tM2 | tM3 | tM4 | tM5;
wire	Ops = Mod; //tOp | Mod;
wire	Dat = tD0 | tD1 | tD2 | tD3 | tD4 | tD5 | tD6;
wire	Dbw = tBW0 | tBW1;
wire	Seg = tS0 | tS1;
wire	Wrd = tW0 | tW1 | tW2;
wire	Prt = tP0 | tP1;
wire	Jmp = tJ0 | tJ1 | tJ2;
wire	Ext = tSE | Jmp;
wire	One = tO0 | tO1 | tO2 | tO3 | tO4 | tO5 | tO6 | tO7 | tO8 | tO9 | tOA | tOB | tOC | tOD | tOE | tOF | tOG | tOH | tOI;
wire	Inv = tU0 | tU1 | tU2 | tU3;
	//---------------------------------------------------

reg	[1:0]		dispCnt;

//wire	Mod = iDec[10];
//wire	Ops = iDec[9];
//wire	Dat = iDec[8];
//wire	Dbw = iDec[7];
//wire	Seg = iDec[6];
//wire	Wrd = iDec[5];
//wire	Prt = iDec[4];
//wire	Jmp = iDec[3];
//wire	Ext = iDec[2];
//wire	One = iDec[1];
//wire	Inv = iDec[0];

reg	[7:0]		IAdrL;
reg	[7:0]		IAdrH;
reg	[7:0]		IDatL;
reg	[7:0]		IDatH;

always @(posedge iClk)
if (iRst == 1'b1)
begin
	I_OP0 <= 8'b0;
	I_OP1 <= 8'b0;
		
	imm <= 16'b0;
	offset <= 16'b0;
		
	//oDRomAdr <= 10'b0;
		
	oAck <= 1'b0;
	oUsed <= 3'b0;

end else
begin
	case (Second[7:6])
		2'b00:	if (Second[2:0] == 3'b110)
				dispCnt = 3'd2;
			else
				dispCnt = 3'd0;
		2'b01:	dispCnt = 3'd1;
		2'b10:	dispCnt = 3'd2;
		2'b11:	dispCnt = 3'd0;
	endcase
	
	oAck <= 1'b0;
	if ((iAck == 1'b1) && (iJumped == 1'b0))
	begin
		if (Mod == 1)
      begin
			case (dispCnt)
				2'b00,
				2'b11: begin
							IAdrL = 0;
                     IAdrH = 0;
                     IDatL = (Dat == 1) ? iBuf2 : 8'b0;
                     IDatH = (Ext == 1) ? {8{iBuf2[7]}} : ((Dbw == 1) ? iBuf3 : 8'b0);
                   end
				2'b01: begin
							IAdrL = iBuf2;
                     IAdrH = {8{iBuf2[7]}};
                     IDatL = (Dat == 1) ? iBuf3 : 8'b0;
                     IDatH = (Ext == 1) ? {8{iBuf3[7]}} : ((Dbw == 1) ? iBuf4 : 8'b0);
                   end
				2'b10: begin
                     IAdrL = iBuf2;
                     IAdrH = iBuf3;
                     IDatL = (Dat == 1) ? iBuf4 : 8'b0;
                     IDatH = (Ext == 1) ? {8{iBuf4[7]}} : ((Dbw == 1) ? iBuf5 : 8'b0);
                   end
			endcase
		end else begin
         IAdrL = (Seg == 1) ? iBuf3 : 8'h00;
         IAdrH = (Seg == 1) ? iBuf4 : 8'h00;
         IDatL = ((Dat | Seg | Wrd | Prt | Jmp) == 1) ? iBuf1 : 8'h00;
         IDatH = (Ext == 1) ? {8{iBuf1[7]}} : (((Dbw | Seg | Wrd) == 1) ? iBuf2 : 8'h00);
		end
		
		I_OP0 <= iBuf0;
		I_OP1 <= (Ops == 1) ? iBuf1 : 8'hC0;
	
		oUsed <= iLen;
		if (iJumped == 1'b0)
			oAck	<= 1'b1;
	
		if ((iBuf0 & 8'hFC) == 8'hA0)
		begin
			offset <= {IDatH, IDatL};
			imm <= 16'b0;
		end else
		if (iBuf0 == 8'hCC)
			imm <= 16'd3;
		else if (iBuf0 == 8'hCE)
			imm <= 16'd4;
		else if ((iBuf0 & 8'hFE) == 8'hD4)
			offset <= {IDatH, IDatL};
		else begin
			offset <= {IAdrH, IAdrL};
			imm <= {IDatH, IDatL};
		end
	end
end

endmodule

