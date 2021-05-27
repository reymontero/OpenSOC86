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


module DecStream
	(
		input							iClk,
		input							iRst,
		
		input							iJumped,
		
		input				[31:0]	iData,
		input				[1:0]		memIndex,
		input							iAck,
		
		input							iMemReq,
		
		output			[31:0]	oData,
		output			[15:0]	oLen,
		output			[1:0]		oMemIndex,
		//output						oWr,
		
		output						oAckWr,
		output	reg				oAckCnt
	);

reg	[31:0]	buf1;
reg				vld1;
reg	[1:0]		ind1;

reg				didMemReq;
reg				preAck;
reg				ignoreMem;

initial
begin
	buf1 = 32'd0;
	vld1 = 1'b0;
	ind1 = 2'd0;
	
	didMemReq = 1'b0;
	preAck = 1'b0;
	ignoreMem = 1'b0;
	
	oAckCnt = 1'b0;
end

wire [2:0] Len0;
wire [2:0] Len1;
wire [2:0] Len2;
wire [2:0] Len3;

wire		Mod0;
wire		Mod1;
wire		Mod2;
wire		Mod3;

assign oData = buf1;
assign oLen = {Mod3, Len3, Mod2, Len2, Mod1, Len1, Mod0, Len0};
assign oMemIndex = ind1;
assign oAckWr = vld1 & iAck & ~ignoreMem;

LenDec LenDec_inst0
(
	.iClk(iClk),
	.iOP0(buf1[7:0]),
	.iOP1(buf1[15:8]),
	.oLen(Len0),
	.oMod(Mod0)
);

LenDec LenDec_inst1
(
	.iClk(iClk),
	.iOP0(buf1[15:8]),
	.iOP1(buf1[23:16]),
	.oLen(Len1),
	.oMod(Mod1)
);

LenDec LenDec_inst2
(
	.iClk(iClk),
	.iOP0(buf1[23:16]),
	.iOP1(buf1[31:24]),
	.oLen(Len2),
	.oMod(Mod2)
);

LenDec LenDec_inst3
(
	.iClk(iClk),
	.iOP0(buf1[31:24]),
	.iOP1(iData[7:0]),
	.oLen(Len3),
	.oMod(Mod3)
);

always @(posedge iClk)
if (iRst == 1'b1)
begin
	buf1 <= 32'd0;
	vld1 <= 1'b0;
	ind1 <= 2'd0;
	
	didMemReq <= 1'b0;
	preAck <= 1'b0;
	ignoreMem <= 1'b0;
	
	oAckCnt <= 1'b0;
end
else
begin
	oAckCnt <= iAck;
	
	preAck <= iAck;
	if (preAck & ~iAck)
	begin
		didMemReq <= 1'b0;
		ignoreMem <= 1'b0;
	end
	
	if (iMemReq)
		didMemReq <= 1'b1;
	
	if (iAck & ~ignoreMem)
	begin
		buf1 <= iData;
		vld1 <= 1'b1;
		ind1 <= memIndex;
	end
	
	if (iJumped)
	begin
		buf1 <= 32'd0;
		vld1 <= 1'b0;
		ind1 <= 2'd0;
		
		if ((didMemReq | iMemReq) & ~(preAck & ~iAck))
			ignoreMem <= 1'b1;
	end
end

endmodule
