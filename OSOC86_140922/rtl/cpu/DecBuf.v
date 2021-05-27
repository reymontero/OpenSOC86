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


module DecBuf
	(
		input							iClk,
		input							iRst,
		
		input							iReq,
		input							iJumped,
		
		output	reg	[47:0]	oBuf,
		output	reg	[2:0]		oLen,
		//output	reg				oMod,
		output	reg				oAck,
		
		output			[9:0]		oDRomAdr,
		
		output	reg				oMemReq,
		
		input				[1:0]		memIndex,
		
		input				[63:0]	iFData,
		input				[31:0]	iFLen,
		
		input							iAckWr,
		input							iAckCnt,
		
		
		output	reg	[3:0]		oFAdrW,
		output			[2:0]		oFAdrR
	);

reg	[63:0]	IBuf;
reg	[31:0]	ILen;
reg				IValid;

reg	[3:0]		WrAdr;
reg	[2:0]		RdAdr;

reg	[2:0]		selOut;

reg	[3:0]		reqCnt;

reg				didMemReq;
reg				preAckCnt;
reg				ignoreMem;

initial
begin
	oBuf = 48'd0;
	oLen = 3'd0;
	oAck = 1'b0;
	oMemReq = 1'b0;
	oFAdrW = 4'd0;

	IBuf = 63'd0;
	ILen = 32'd0;
	
	IValid = 1'b0;
	WrAdr = 4'd0;
	RdAdr = 3'd0;
	selOut = 3'd0;
	reqCnt = 4'd0;
	
	didMemReq = 1'b0;
	preAckCnt = 1'b0;
	
	ignoreMem = 1'b0;
end

wire	[2:0]		inCnt = WrAdr[3:1] - RdAdr;
wire				halfEmpty = ~inCnt[2];
wire				RValid = (inCnt == 3'd0) ? 1'b0 : 1'b1;
wire				outNow = iReq | (reqCnt != 4'd0);

reg	[47:0]	tBuf;			//comb
reg	[2:0]		tUsed;		//comb
reg				tMod;			//comb
reg	[2:0]		TAdr;			//comb
reg	[3:0]		newOut;		//comb
reg				readNext;	//comb

assign oFAdrR = TAdr;

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
		1: tUsed = ILen[6:4];
		2: tUsed = ILen[10:8];
		3: tUsed = ILen[14:12];
		4: tUsed = ILen[18:16];
		5: tUsed = ILen[22:20];
		6: tUsed = ILen[26:24];
		7: tUsed = ILen[30:28];
	endcase
	
	case (selOut)
		0: tMod = ILen[3];
		1: tMod = ILen[7];
		2: tMod = ILen[11];
		3: tMod = ILen[15];
		4: tMod = ILen[19];
		5: tMod = ILen[23];
		6: tMod = ILen[27];
		7: tMod = ILen[31];
	endcase
	
	newOut[3:0] = {1'b0, selOut} + {1'b0, tUsed};
	readNext = (((newOut[3] & outNow) | ~IValid) & RValid);
	
	TAdr = (readNext) ? RdAdr + 3'd1 : RdAdr;
end

reg	[7:0]		First;		//comb
reg	[7:0]		Second;		//comb
reg				amod;			//comb
reg	[9:0]		ToDRomAdr;	//comb
assign oDRomAdr = ToDRomAdr;

always @(*)
begin
	First = tBuf[7:0];
	Second = tBuf[15:8];
	amod = Second[7] & Second[6];
	if (tMod == 1'b0)
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

always @(posedge iClk)
if (iRst == 1'b1)
begin
	oBuf <= 48'd0;
	oLen <= 3'd0;
	oAck <= 1'b0;
	oMemReq <= 1'b0;
	oFAdrW <= 4'd0;

	IBuf <= 63'd0;
	ILen <= 24'd0;
	
	IValid <= 1'b0;
	WrAdr <= 4'd0;
	RdAdr <= 3'd0;
	selOut <= 3'd0;
	reqCnt <= 4'd0;
	
	didMemReq <= 1'b0;
	preAckCnt <= 1'b0;
	
	ignoreMem <= 1'b0;
end
else
begin
	if (iAckWr == 1'b1)
	begin
		if (~ignoreMem)
		begin
			oFAdrW <= oFAdrW + 4'd1;
		
			if (memIndex != 2'd0)
				selOut <= {1'b0, memIndex};
		end
	end
	
		
	oMemReq <= 1'b0;
	if (halfEmpty & ~didMemReq & ~iJumped)
	begin
		oMemReq <= 1'b1;
		didMemReq <= 1'b1;
	end
	
	preAckCnt <= iAckCnt;
	if (preAckCnt & ~iAckCnt)
	begin
		didMemReq <= 1'b0;
		ignoreMem <= 1'b0;
	end
	
	//----------------------------------------
	
	RdAdr <= TAdr;
	WrAdr <= oFAdrW;
	
	oBuf <= tBuf;
	oLen <= tUsed;
	//oMod <= tMod;
	
	oAck <= 1'b0;
	if (IValid & RValid)
	begin
		if (outNow)
		begin
			if (~iReq)
				reqCnt <= reqCnt - 4'd1;
			oAck <= 1'b1;
			selOut <= newOut[2:0];
		end
	end
	else if (iReq)
		reqCnt <= reqCnt + 4'd1;
	
	if (readNext)
	begin
		IBuf <= iFData;
		ILen <= iFLen;
		IValid <= 1'b1;
	end
	
	//----------------------------------------
	
	if (iJumped)
	begin
		oBuf <= 48'd0;
		//oLen <= 3'd0;
		oAck <= 1'b0;
		oMemReq <= 1'b0;
		oFAdrW <= 4'd0;
		
		IBuf <= 63'd0;
		ILen <= 24'd0;
		
		IValid <= 1'b0;
		WrAdr <= 4'd0;
		RdAdr <= 3'd0;
		selOut <= 3'd0;
		reqCnt <= 4'd0;
		
		//didMemReq <= 1'b0;
		//preAckCnt <= 1'b0;
		
		if (didMemReq & ~(preAckCnt & ~iAckCnt))
			ignoreMem <= 1'b1;
	end
end

endmodule
