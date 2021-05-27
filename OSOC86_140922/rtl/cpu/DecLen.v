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


module DecLen
	(
		input							iClk,
		
		input				[31:0]	iData,
		input				[1:0]		iIndex,
		input							iAck,
		
		input							iJumped,
		
		output	reg	[31:0]	oData,
		output	reg	[1:0]		oIndex,
		output	reg	[11:0]	oLen,
		output	reg	[11:0]	oModInf,
		output	reg				oAck
	);

wire [7:0] First_0 = iData[7:0];
wire [7:0] First_1 = iData[15:8];
wire [7:0] First_2 = iData[23:16];
wire [7:0] First_3 = iData[31:24];

wire [2:0] tmpUsed_0;
wire [2:0] tmpUsed_1;
wire [2:0] tmpUsed_2;
wire [2:0] tmpUsed_3;

wire Mod_0;
wire Mod_1;
wire Mod_2;
wire Mod_3;

wire [1:0] DispCnt_0;
wire [1:0] DispCnt_1;
wire [1:0] DispCnt_2;
wire [1:0] DispCnt_3;

InstLen InstLen_inst0
(
	.iBuf0(First_0),
	.oUsed(tmpUsed_0),
	.oMod(Mod_0),
	.oDispCnt(DispCnt_0)
);

InstLen InstLen_inst1
(
	.iBuf0(First_1),
	.oUsed(tmpUsed_1),
	.oMod(Mod_1),
	.oDispCnt(DispCnt_1)
);

InstLen InstLen_inst2
(
	.iBuf0(First_2),
	.oUsed(tmpUsed_2),
	.oMod(Mod_2),
	.oDispCnt(DispCnt_2)
);

InstLen InstLen_inst3
(
	.iBuf0(First_3),
	.oUsed(tmpUsed_3),
	.oMod(Mod_3),
	.oDispCnt(DispCnt_3)
);

always @(posedge iClk)
begin
	oData <= iData;
	oIndex <= iIndex;
	oLen <= {tmpUsed_3, tmpUsed_2, tmpUsed_1, tmpUsed_0};
	oModInf <= {Mod_3, DispCnt_3, Mod_2, DispCnt_2, Mod_1, DispCnt_1, Mod_0, DispCnt_0};
	oAck <= iAck;
end

endmodule
