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


module IBufCtrlRam
	(
		input							iClk,
		input							iRst,
		
		input							iReq,
		input							iJumped,
		
		output	reg	[63:0]	oBuf,
		output	reg	[2:0]		oInd,
		output	reg				oAck,
		
		output	reg	[10:0]	oDec,	//{Mod, Ops, Dat, Dbw, Seg, Wrd, Prt, Jmp, Ext, One, Inv}
		output	reg	[1:0]		oDispCnt,
		output	reg	[2:0]		oUsed,
		output			[9:0]		oDRomAdr,
		
		output	reg				oMemReq,
		
		input				[1:0]		memIndex,
		input							iFWr,
		input				[63:0]	iFData,
		input				[23:0]	iFLen,
		input				[23:0]	iFMod,
		
		output	reg	[3:0]		oFAdrW,
		output			[2:0]		oFAdrR
	);

reg	[63:0]	IBuf;
reg	[23:0]	ILen;
reg	[23:0]	IMod;

reg				IValid;
reg				RValid;
reg				ILen7OK;

reg	[2:0]		selOut;
wire LenOK = ILen7OK | ~&selOut;

reg	[2:0]		RAdr;
reg				waitRV;

reg				didReq;
reg	[2:0]		memGet;
reg				ignoreMem;

reg	[3:0]		reqCnt;

initial
begin
	oBuf = 64'd0;
	oInd = 2'd0;
	oAck = 1'b0;
	oDec = 11'd0;
	oDispCnt = 2'd0;
	oUsed = 3'd0;
	oMemReq = 1'b0;
	oFAdrW = 4'd0;
	
	IBuf = 64'd0;
	ILen = 24'd0;
	IMod = 24'd0;
	IValid = 1'b0;
	RValid = 1'b0;
	ILen7OK = 1'b0;
	selOut = 3'd0;
	RAdr = 3'd0;
	waitRV = 1'b0;
	didReq = 1'b0;
	memGet = 3'd0;
	ignoreMem = 1'b0;
	reqCnt = 4'd0;
end

reg [47:0] tBuf;
reg [2:0] tUsed;
reg [2:0] oBufUsed;
reg tMod;
reg [1:0] tCnt;
//reg [1:0] mCnt;
//reg [1:0] eCnt;
reg [3:0] newOut;
reg newOutA;
reg newOutB;

reg [2:0] TAdr;
assign oFAdrR = TAdr;

wire [7:0] First = tBuf[7:0];
wire [7:0] Second = tBuf[15:8];

always @(*)
begin
	case (selOut)
		0: tBuf = IBuf[47:0];
		1: tBuf = IBuf[55:8];
		2: tBuf = IBuf[63:16];
		3: tBuf = {iFData[7:0], IBuf[63:24]};
		4: tBuf = {iFData[15:0], IBuf[63:32]};
		5: tBuf = {iFData[23:0], IBuf[63:40]};
		6: tBuf = {iFData[31:0], IBuf[63:48]};
		7: tBuf = {iFData[39:0], IBuf[63:56]};
	endcase
	
	case (selOut)
		0: tUsed = ILen[2:0];
		1: tUsed = ILen[5:3];
		2: tUsed = ILen[8:6];
		3: tUsed = ILen[11:9];
		4: tUsed = ILen[14:12];
		5: tUsed = ILen[17:15];
		6: tUsed = ILen[20:18];
		7: tUsed = ILen[23:21];
	endcase
	
	case (selOut)
		0: tMod = IMod[2];
		1: tMod = IMod[5];
		2: tMod = IMod[8];
		3: tMod = IMod[11];
		4: tMod = IMod[14];
		5: tMod = IMod[17];
		6: tMod = IMod[20];
		7: tMod = IMod[23];
	endcase
	
	case (selOut)
		0: tCnt = IMod[4:3];
		1: tCnt = IMod[7:6];
		2: tCnt = IMod[10:9];
		3: tCnt = IMod[13:12];
		4: tCnt = IMod[16:15];
		5: tCnt = IMod[19:18];
		6: tCnt = IMod[22:21];
		7: tCnt = iFMod[1:0];
	endcase
	
	//tUsed = tBuf[2:0];
	//if (tBuf[7] == 1'b1)
	//	tLen = tLen + tBuf[9:8];
	
	oBufUsed = tUsed;
	//if (tMod)
	//	oBufUsed = oBufUsed + {1'b0, tCnt};
	
	//	mCnt = tCnt;
	//else
	//	mCnt = 2'd0;
	
	if ((First[7:1] == 7'b1111011) && (Second[5:3] == 3'b000))	//TEST instruction
	begin
		//eCnt = {First[0], ~First[0]};
	//	oBufUsed = {First[0], ~First[0], ~First[0]};
		oBufUsed = oBufUsed + {1'b0, First[0], ~First[0]};
		//if (First[0] == 1'b1)
		//	oBufUsed = oBufUsed + 3'd2;
		//else
		//	oBufUsed = oBufUsed + 3'd1;
	end //else
	//	eCnt = 2'd0;
	
	//oBufUsed = oBufUsed + {1'b0, mCnt} + {1'b0, eCnt};
	//oBufUsed = oBufUsed + {1'b0, mCnt};
	//oBufUsed = oBufUsed + {1'b0, eCnt};
	
	newOut[3:0] = {1'b0, selOut} + {1'b0, oBufUsed};
	
//	case ({selOut[2:1], oBufUsed[2:1]})
//		4'b0000: newOutA = 1'b0;
//		4'b0001: newOutA = 1'b0;
//		4'b0010: newOutA = 1'b0;
//		4'b0011: newOutA = 1'b0;
//		4'b0100: newOutA = 1'b0;
//		4'b0101: newOutA = 1'b0;
//		4'b0110: newOutA = 1'b0;
//		4'b0111: newOutA = 1'b1;
//		4'b1000: newOutA = 1'b0;
//		4'b1001: newOutA = 1'b0;
//		4'b1010: newOutA = 1'b1; //1
//		4'b1011: newOutA = 1'b1; //1
//		4'b1100: newOutA = 1'b0;
//		4'b1101: newOutA = 1'b1;
//		4'b1110: newOutA = 1'b1; //1
//		4'b1111: newOutA = 1'b1;
//	endcase
//	//newOut[3] = newOut[3] | (|{selOut[1:0], oBufUsed[2], oBufUsed[0]}) | (|{oBufUsed[1:0], selOut[2], selOut[0]});
//	
//	case ({selOut[2:1], oBufUsed[2:1]})
//		4'b0000: newOutB = 1'b0;
//		4'b0001: newOutB = 1'b0;
//		4'b0010: newOutB = 1'b0;
//		4'b0011: newOutB = 1'b1;
//		4'b0100: newOutB = 1'b0;
//		4'b0101: newOutB = 1'b0;
//		4'b0110: newOutB = 1'b1;
//		4'b0111: newOutB = 1'b1;
//		4'b1000: newOutB = 1'b0;
//		4'b1001: newOutB = 1'b1;
//		4'b1010: newOutB = 1'b1;
//		4'b1011: newOutB = 1'b1;
//		4'b1100: newOutB = 1'b1;
//		4'b1101: newOutB = 1'b1;
//		4'b1110: newOutB = 1'b1;
//		4'b1111: newOutB = 1'b1;
//	endcase
//	
//	newOut[3] = newOutA | (newOutB & selOut[0] & oBufUsed[0]);
	
	TAdr = (((newOut[3] && (iReq || (reqCnt > 4'd0)) && LenOK) | ~IValid) & RValid) ? RAdr + 3'd1 : RAdr;
end


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

reg	amod;
reg	[9:0]		ToDRomAdr;
assign oDRomAdr = ToDRomAdr;

always @(*)
begin
	amod = Second[7] & Second[6];
	if (Mod == 0)
		ToDRomAdr = {2'b00, First};
	else begin
		casex (First)
			8'b100000xx:	ToDRomAdr = {1'b1, amod, 3'b000, First[1:0], Second[5:3]};
			8'b110100xx:	ToDRomAdr = {1'b1, amod, 3'b001, First[1:0], 3'b000};
			8'b1111011x:	ToDRomAdr = {1'b1, amod, 4'b0100, First[0], Second[5:3]};
			8'b1111111x:	ToDRomAdr = {1'b1, amod, 4'b0110, First[0], Second[5:3]};
			default:			ToDRomAdr = {1'b0, amod, First};
		endcase
	end
end


wire [3:0] inMem = oFAdrW[3:0] - {RAdr, 1'b0};
wire readOK = ((inMem > 4'd2) || ((inMem == 4'd2) && (iFWr == 1'b1))) ? 1'b1 : 1'b0;

always @(posedge iClk)
if (iRst == 1'b1)
begin
	oBuf <= 64'd0;
	oInd <= 2'd0;
	oAck <= 1'b0;
	oDec <= 11'd0;
	oDispCnt <= 2'd0;
	oUsed <= 3'd0;
	oMemReq <= 1'b0;
	oFAdrW <= 4'd0;
	
	IBuf <= 64'd0;
	ILen <= 24'd0;
	IMod <= 24'd0;
	IValid <= 1'b0;
	RValid <= 1'b0;
	ILen7OK <= 1'b0;
	selOut <= 3'd0;
	RAdr <= 3'd0;
	waitRV <= 1'b0;
	didReq <= 1'b0;
	memGet <= 3'd0;
	ignoreMem <= 1'b0;
	reqCnt <= 4'd0;
	
end else begin
	if (iFWr == 1'b1)
	begin
		if ((iJumped == 1'b0) && (ignoreMem == 1'b0))
		begin
			oFAdrW <= oFAdrW + 4'd1;
			
			if (memIndex != 2'd0)
				selOut <= {1'b0, memIndex};
		end
		
		memGet <= memGet + 3'd1;
		if (memGet == 3'd7)
		begin
			didReq <= 1'b0;
			ignoreMem <= 1'b0;
		end
		else if (iJumped == 1'b1)
			ignoreMem <= 1'b1;
	end
	
	if (iJumped == 1'b1)
	begin
		if (memGet == 3'd0)
			ignoreMem <= didReq;
	end
		
	oMemReq <= 1'b0;
	if ((inMem < 4'd8) && (didReq == 3'd0))
	begin
		oMemReq <= 1'b1;
		didReq <= 1'b1;
	end
	
	//----------------------------------------
	
	oBuf[63:48] <= 16'd0;
	oBuf[47:0] <= tBuf;
	oUsed <= oBufUsed;
	oDispCnt <= tCnt;
	oDec <= {Mod, Ops, Dat, Dbw, Seg, Wrd, Prt, Jmp, Ext, One, Inv};
	
	oAck <= 1'b0;
	if (IValid & (~newOut[3] | RValid))
	begin
		if (((iReq == 1'b1) || (reqCnt > 4'd0)) && LenOK)
		begin
			if (iReq == 1'b0)
				reqCnt <= reqCnt - 4'd1;
			oAck <= 1'b1;
			selOut <= newOut[2:0];
		end
	end else
	if (iReq == 1'b1)
		reqCnt <= reqCnt + 4'd1;
	
	if (((newOut[3] && (iReq || (reqCnt > 4'd0)) && LenOK) | ~IValid) & RValid)
	begin
		IBuf <= iFData;
		//ILen <= iFLen;
		IMod <= iFMod;
		ILen[2:0]   <= iFLen[2:0]   + {1'b0, (iFMod[4:3]   & {2{iFMod[2]}})};
		ILen[5:3]   <= iFLen[5:3]   + {1'b0, (iFMod[7:6]   & {2{iFMod[5]}})};
		ILen[8:6]   <= iFLen[8:6]   + {1'b0, (iFMod[10:9]  & {2{iFMod[8]}})};
		ILen[11:9]  <= iFLen[11:9]  + {1'b0, (iFMod[13:12] & {2{iFMod[11]}})};
		ILen[14:12] <= iFLen[14:12] + {1'b0, (iFMod[16:15] & {2{iFMod[14]}})};
		ILen[17:15] <= iFLen[17:15] + {1'b0, (iFMod[19:18] & {2{iFMod[17]}})};
		ILen[20:18] <= iFLen[20:18] + {1'b0, (iFMod[22:21] & {2{iFMod[20]}})};
		ILen[23:21] <= iFLen[23:21]; // + {1'b0, (iFMod[1:0]   & {2{iFMod[23]}})};
		ILen7OK <= 1'b0;
		
		IValid <= 1'b1;
		RValid <= 1'b0;
		if (readOK)
			waitRV <= 1'b1;
	end
	else
	if (RValid & IValid & ~ILen7OK)
	begin
		ILen[23:21] <= ILen[23:21] + {1'b0, (iFMod[1:0] & {2{IMod[23]}})};
		ILen7OK <= 1'b1;
	end
	
	RAdr <= TAdr;
	
	
	if (waitRV == 1'b1)
	begin
		waitRV <= 1'b0;
		RValid <= 1'b1;
		//ILen[23:21] <= ILen[23:21] + {1'b0, (iFMod[1:0] & {2{IMod[23]}})};
	end
	
	if (~RValid & readOK & ~waitRV)
		waitRV <= 1'b1;
	
	if (iJumped == 1'b1)
	begin
		oAck <= 1'b0;
		oFAdrW <= 4'd0;
		
		IValid <= 1'b0;
		RValid <= 1'b0;
		selOut <= 3'd0;
		RAdr <= 3'd0;
		waitRV <= 1'b0;
		reqCnt <= 4'd0;
	end
end

endmodule
