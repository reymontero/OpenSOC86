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


// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 64-Bit"
// VERSION		"Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"
// CREATED		"Tue Jul 15 22:56:08 2014"

module cpu_top(
	iClk,
	iRst,
	iRamAck,
	iAck_8237,
	iAck_8253,
	iAck_8259,
	iAck_video,
	iInt,
	iAck_8272,
	iAck_ext,
	iData_8237,
	iData_8253,
	iData_8259,
	iData_8272,
	iData_ext,
	iData_video,
	iInt_T,
	iRamData,
	oRamBW,
	oHalted,
	oBusAdr_8259,
	oAckInt,
	cur_Inst,
	DUMP,
	oBusAdr16,
	oBusAdr_8237,
	oBusAdr_8253,
	oBusAdr_8272,
	oBusAdr_video,
	oBusData16,
	oBusData8,
	oBusRW_8237,
	oBusRW_8253,
	oBusRW_8259,
	oBusRW_8272,
	oBusRW_ext,
	oBusRW_video,
	oRamAdr,
	oRamBurst,
	oRamData,
	oRamRW,
	oTmpOut
);


input wire	iClk;
input wire	iRst;
input wire	iRamAck;
input wire	iAck_8237;
input wire	iAck_8253;
input wire	iAck_8259;
input wire	iAck_video;
input wire	iInt;
input wire	iAck_8272;
input wire	iAck_ext;
input wire	[7:0] iData_8237;
input wire	[7:0] iData_8253;
input wire	[7:0] iData_8259;
input wire	[7:0] iData_8272;
input wire	[15:0] iData_ext;
input wire	[7:0] iData_video;
input wire	[7:0] iInt_T;
input wire	[31:0] iRamData;
output wire	oRamBW;
output wire	oHalted;
output wire	oBusAdr_8259;
output wire	oAckInt;
output wire	[63:0] cur_Inst;
output wire	[207:0] DUMP;
output wire	[15:0] oBusAdr16;
output wire	[4:0] oBusAdr_8237;
output wire	[1:0] oBusAdr_8253;
output wire	[1:0] oBusAdr_8272;
output wire	[6:0] oBusAdr_video;
output wire	[15:0] oBusData16;
output wire	[7:0] oBusData8;
output wire	[1:0] oBusRW_8237;
output wire	[1:0] oBusRW_8253;
output wire	[1:0] oBusRW_8259;
output wire	[1:0] oBusRW_8272;
output wire	[1:0] oBusRW_ext;
output wire	[1:0] oBusRW_video;
output wire	[19:0] oRamAdr;
output wire	[1:0] oRamBurst;
output wire	[15:0] oRamData;
output wire	[1:0] oRamRW;
output wire	[15:0] oTmpOut;

wire	SYNTHESIZED_WIRE_141;
wire	SYNTHESIZED_WIRE_1;
wire	[47:0] SYNTHESIZED_WIRE_2;
wire	[2:0] SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_142;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;
wire	[7:0] SYNTHESIZED_WIRE_13;
wire	[7:0] SYNTHESIZED_WIRE_14;
wire	[15:0] SYNTHESIZED_WIRE_143;
wire	[15:0] SYNTHESIZED_WIRE_16;
wire	[8:0] SYNTHESIZED_WIRE_17;
wire	[2:0] SYNTHESIZED_WIRE_18;
wire	[15:0] SYNTHESIZED_WIRE_19;
wire	[63:0] SYNTHESIZED_WIRE_20;
wire	[9:0] SYNTHESIZED_WIRE_144;
wire	SYNTHESIZED_WIRE_22;
wire	[3:0] SYNTHESIZED_WIRE_145;
wire	[3:0] SYNTHESIZED_WIRE_146;
wire	[3:0] SYNTHESIZED_WIRE_25;
wire	[1:0] SYNTHESIZED_WIRE_147;
wire	[1:0] SYNTHESIZED_WIRE_148;
wire	[1:0] SYNTHESIZED_WIRE_28;
wire	[1:0] SYNTHESIZED_WIRE_30;
wire	[2:0] SYNTHESIZED_WIRE_31;
wire	[15:0] SYNTHESIZED_WIRE_149;
wire	[15:0] SYNTHESIZED_WIRE_34;
wire	[15:0] SYNTHESIZED_WIRE_35;
wire	[15:0] SYNTHESIZED_WIRE_36;
wire	[8:0] SYNTHESIZED_WIRE_38;
wire	SYNTHESIZED_WIRE_150;
wire	[31:0] SYNTHESIZED_WIRE_40;
wire	[2:0] SYNTHESIZED_WIRE_151;
wire	[3:0] SYNTHESIZED_WIRE_152;
wire	SYNTHESIZED_WIRE_43;
wire	SYNTHESIZED_WIRE_44;
wire	[3:0] SYNTHESIZED_WIRE_47;
wire	[1:0] SYNTHESIZED_WIRE_50;
wire	SYNTHESIZED_WIRE_51;
wire	SYNTHESIZED_WIRE_52;
wire	[63:0] SYNTHESIZED_WIRE_53;
wire	[63:0] SYNTHESIZED_WIRE_54;
wire	[63:0] SYNTHESIZED_WIRE_55;
wire	[63:0] SYNTHESIZED_WIRE_56;
wire	[63:0] SYNTHESIZED_WIRE_57;
wire	[63:0] SYNTHESIZED_WIRE_58;
wire	[63:0] SYNTHESIZED_WIRE_59;
wire	[63:0] SYNTHESIZED_WIRE_60;
wire	[15:0] SYNTHESIZED_WIRE_62;
wire	SYNTHESIZED_WIRE_65;
wire	SYNTHESIZED_WIRE_68;
wire	[63:0] SYNTHESIZED_WIRE_69;
wire	[31:0] SYNTHESIZED_WIRE_70;
wire	[1:0] SYNTHESIZED_WIRE_71;
wire	SYNTHESIZED_WIRE_73;
wire	SYNTHESIZED_WIRE_153;
wire	[31:0] SYNTHESIZED_WIRE_75;
wire	[1:0] SYNTHESIZED_WIRE_76;
wire	SYNTHESIZED_WIRE_77;
wire	SYNTHESIZED_WIRE_78;
wire	SYNTHESIZED_WIRE_79;
wire	SYNTHESIZED_WIRE_80;
wire	[15:0] SYNTHESIZED_WIRE_82;
wire	[15:0] SYNTHESIZED_WIRE_83;
wire	[2:0] SYNTHESIZED_WIRE_84;
wire	[3:0] SYNTHESIZED_WIRE_85;
wire	[15:0] SYNTHESIZED_WIRE_86;
wire	[15:0] SYNTHESIZED_WIRE_87;
wire	[15:0] SYNTHESIZED_WIRE_88;
wire	[15:0] SYNTHESIZED_WIRE_89;
wire	[15:0] SYNTHESIZED_WIRE_90;
wire	[2:0] SYNTHESIZED_WIRE_91;
wire	[2:0] SYNTHESIZED_WIRE_92;
wire	[3:0] SYNTHESIZED_WIRE_93;
wire	SYNTHESIZED_WIRE_154;
wire	SYNTHESIZED_WIRE_98;
wire	SYNTHESIZED_WIRE_99;
wire	[15:0] SYNTHESIZED_WIRE_100;
wire	[15:0] SYNTHESIZED_WIRE_101;
wire	[1:0] SYNTHESIZED_WIRE_102;
wire	[1:0] SYNTHESIZED_WIRE_103;
wire	[15:0] SYNTHESIZED_WIRE_104;
wire	[15:0] SYNTHESIZED_WIRE_105;
wire	[15:0] SYNTHESIZED_WIRE_106;
wire	[15:0] SYNTHESIZED_WIRE_107;
wire	[15:0] SYNTHESIZED_WIRE_108;
wire	[15:0] SYNTHESIZED_WIRE_109;
wire	[15:0] SYNTHESIZED_WIRE_110;
wire	[15:0] SYNTHESIZED_WIRE_112;
wire	[15:0] SYNTHESIZED_WIRE_113;
wire	[15:0] SYNTHESIZED_WIRE_114;
wire	[1:0] SYNTHESIZED_WIRE_115;
wire	[1:0] SYNTHESIZED_WIRE_116;
wire	[1:0] SYNTHESIZED_WIRE_117;
wire	[2:0] SYNTHESIZED_WIRE_118;
wire	[2:0] SYNTHESIZED_WIRE_119;
wire	[2:0] SYNTHESIZED_WIRE_120;
wire	[2:0] SYNTHESIZED_WIRE_121;
wire	[1:0] SYNTHESIZED_WIRE_122;
wire	[1:0] SYNTHESIZED_WIRE_123;
wire	[15:0] SYNTHESIZED_WIRE_124;
wire	[15:0] SYNTHESIZED_WIRE_125;
wire	[15:0] SYNTHESIZED_WIRE_126;
wire	SYNTHESIZED_WIRE_128;
wire	SYNTHESIZED_WIRE_129;
wire	SYNTHESIZED_WIRE_130;
wire	SYNTHESIZED_WIRE_131;
wire	SYNTHESIZED_WIRE_132;
wire	[16:0] SYNTHESIZED_WIRE_133;
wire	[15:0] SYNTHESIZED_WIRE_134;
wire	[1:0] SYNTHESIZED_WIRE_135;
wire	[4:0] SYNTHESIZED_WIRE_136;
wire	[15:0] SYNTHESIZED_WIRE_137;
wire	[15:0] SYNTHESIZED_WIRE_138;
wire	[15:0] SYNTHESIZED_WIRE_139;
wire	[15:0] SYNTHESIZED_WIRE_140;

assign	cur_Inst = SYNTHESIZED_WIRE_57;
assign	oTmpOut = SYNTHESIZED_WIRE_149;
assign	SYNTHESIZED_WIRE_154 = 0;




decode	b2v_inst(
	.iClk(iClk),
	.iRst(iRst),
	.iJumped(SYNTHESIZED_WIRE_141),
	.iAck(SYNTHESIZED_WIRE_1),
	.iBuf48(SYNTHESIZED_WIRE_2),
	.iLen(SYNTHESIZED_WIRE_3),
	.oAck(SYNTHESIZED_WIRE_5),
	.I_OP0(SYNTHESIZED_WIRE_13),
	.I_OP1(SYNTHESIZED_WIRE_14),
	.imm(SYNTHESIZED_WIRE_16),
	.offset(SYNTHESIZED_WIRE_19),
	.oUsed(SYNTHESIZED_WIRE_18));


Ctrl	b2v_inst1(
	.iClk(iClk),
	.iRst(iRst),
	.iPipeLine(SYNTHESIZED_WIRE_4),
	.iAck(SYNTHESIZED_WIRE_5),
	.Hazard(SYNTHESIZED_WIRE_6),
	.StallM(SYNTHESIZED_WIRE_142),
	.StallD(SYNTHESIZED_WIRE_8),
	.StallIO(SYNTHESIZED_WIRE_9),
	.iJumped(SYNTHESIZED_WIRE_141),
	.iDivErr(SYNTHESIZED_WIRE_11),
	.iInt(iInt),
	.CXzero(SYNTHESIZED_WIRE_12),
	.I_OP0(SYNTHESIZED_WIRE_13),
	.I_OP1(SYNTHESIZED_WIRE_14),
	.iFlags(SYNTHESIZED_WIRE_143),
	.iInt_T(iInt_T),
	.imm(SYNTHESIZED_WIRE_16),
	.iUCAdr(SYNTHESIZED_WIRE_17),
	.iUsed(SYNTHESIZED_WIRE_18),
	.offset(SYNTHESIZED_WIRE_19),
	.UC(SYNTHESIZED_WIRE_20),
	.oNew(SYNTHESIZED_WIRE_65),
	.oHalted(oHalted),
	.oAckInt(oAckInt),
	.cur_Ctrl1(SYNTHESIZED_WIRE_53),
	.cur_Ctrl2(SYNTHESIZED_WIRE_54),
	.cur_Ctrl3(SYNTHESIZED_WIRE_55),
	.cur_Ctrl4(SYNTHESIZED_WIRE_56),
	.cur_Inst1(SYNTHESIZED_WIRE_57),
	.cur_Inst2(SYNTHESIZED_WIRE_58),
	.cur_Inst3(SYNTHESIZED_WIRE_59),
	.cur_Inst4(SYNTHESIZED_WIRE_60),
	.UCAdr(SYNTHESIZED_WIRE_38));


UAdrROM	b2v_inst12(
	.clk(iClk),
	.addr(SYNTHESIZED_WIRE_144),
	.q(SYNTHESIZED_WIRE_17));


RF	b2v_inst13(
	.iClk(iClk),
	.iRst(iRst),
	.wr(SYNTHESIZED_WIRE_22),
	.adrR0(SYNTHESIZED_WIRE_145),
	.adrR1(SYNTHESIZED_WIRE_146),
	.adrW(SYNTHESIZED_WIRE_25),
	.bwsR0(SYNTHESIZED_WIRE_147),
	.bwsR1(SYNTHESIZED_WIRE_148),
	.bwsW(SYNTHESIZED_WIRE_28),
	.Flags(SYNTHESIZED_WIRE_143),
	
	.step(SYNTHESIZED_WIRE_30),
	.used(SYNTHESIZED_WIRE_31),
	.Val(SYNTHESIZED_WIRE_149),
	.oJumped(SYNTHESIZED_WIRE_141),
	.CXzero(SYNTHESIZED_WIRE_51),
	.BP(SYNTHESIZED_WIRE_101),
	.BX(SYNTHESIZED_WIRE_104),
	.CS(SYNTHESIZED_WIRE_105),
	.DI(SYNTHESIZED_WIRE_106),
	.DS(SYNTHESIZED_WIRE_107),
	.DUMP(DUMP),
	.DX(SYNTHESIZED_WIRE_34),
	.ES(SYNTHESIZED_WIRE_110),
	.oIP(SYNTHESIZED_WIRE_114),
	.Out1(SYNTHESIZED_WIRE_35),
	.Out2(SYNTHESIZED_WIRE_36),
	.SI(SYNTHESIZED_WIRE_124),
	.SP(SYNTHESIZED_WIRE_125),
	.SS(SYNTHESIZED_WIRE_126));


RFDly	b2v_inst14(
	.iClk(iClk),
	.iStall(SYNTHESIZED_WIRE_142),
	.iDX(SYNTHESIZED_WIRE_34),
	.iRF1(SYNTHESIZED_WIRE_35),
	.iRF2(SYNTHESIZED_WIRE_36),
	.oDX(SYNTHESIZED_WIRE_82),
	.oRF1(SYNTHESIZED_WIRE_89),
	.oRF2(SYNTHESIZED_WIRE_90));


UDepROM	b2v_inst15(
	.clk(iClk),
	.addr(SYNTHESIZED_WIRE_144),
	.q(SYNTHESIZED_WIRE_4));


UCROM	b2v_inst17(
	.clk(iClk),
	.addr(SYNTHESIZED_WIRE_38),
	.q(SYNTHESIZED_WIRE_20));


IBufRAM	b2v_inst18(
	.we(SYNTHESIZED_WIRE_150),
	.clk(iClk),
	.data(SYNTHESIZED_WIRE_40),
	.read_addr(SYNTHESIZED_WIRE_151),
	.write_addr(SYNTHESIZED_WIRE_152),
	.q(SYNTHESIZED_WIRE_69));


RFHazard	b2v_inst19(
	.iClk(iClk),
	.Active(SYNTHESIZED_WIRE_43),
	.wr(SYNTHESIZED_WIRE_44),
	.adrR0(SYNTHESIZED_WIRE_145),
	.adrR1(SYNTHESIZED_WIRE_146),
	.adrW(SYNTHESIZED_WIRE_47),
	.bwsR0(SYNTHESIZED_WIRE_147),
	.bwsR1(SYNTHESIZED_WIRE_148),
	.bwsW(SYNTHESIZED_WIRE_50),
	.oHazard(SYNTHESIZED_WIRE_6));


CtrlSplit	b2v_inst2(
	.iCXzero(SYNTHESIZED_WIRE_51),
	.iCurZero(SYNTHESIZED_WIRE_52),
	.Ctrl1(SYNTHESIZED_WIRE_53),
	.Ctrl2(SYNTHESIZED_WIRE_54),
	.Ctrl3(SYNTHESIZED_WIRE_55),
	.Ctrl4(SYNTHESIZED_WIRE_56),
	.Inst1(SYNTHESIZED_WIRE_57),
	.Inst2(SYNTHESIZED_WIRE_58),
	.Inst3(SYNTHESIZED_WIRE_59),
	.Inst4(SYNTHESIZED_WIRE_60),
	.EX_BW(SYNTHESIZED_WIRE_77),
	.EX_ESel(SYNTHESIZED_WIRE_78),
	.RH_PLine(SYNTHESIZED_WIRE_43),
	.RH_wr(SYNTHESIZED_WIRE_44),
	.RF_wr(SYNTHESIZED_WIRE_22),
	.MM_segOR_Rd(SYNTHESIZED_WIRE_98),
	.MM_segOR_Wr(SYNTHESIZED_WIRE_99),
	.CXzero(SYNTHESIZED_WIRE_12),
	.EA_Imm_Rd(SYNTHESIZED_WIRE_108),
	.EA_Imm_Wr(SYNTHESIZED_WIRE_109),
	.EA_MOD_Rd(SYNTHESIZED_WIRE_115),
	.EA_MOD_Wr(SYNTHESIZED_WIRE_116),
	.EA_RM_Rd(SYNTHESIZED_WIRE_118),
	.EA_RM_Wr(SYNTHESIZED_WIRE_119),
	.EX_Exec(SYNTHESIZED_WIRE_84),
	.EX_Func(SYNTHESIZED_WIRE_85),
	.EX_Imm1(SYNTHESIZED_WIRE_86),
	.EX_Imm2(SYNTHESIZED_WIRE_87),
	.EX_SelIn1(SYNTHESIZED_WIRE_91),
	.EX_SelIn2(SYNTHESIZED_WIRE_92),
	.EX_SelOut(SYNTHESIZED_WIRE_93),
	.FC_FBW(SYNTHESIZED_WIRE_135),
	.FC_FSel(SYNTHESIZED_WIRE_136),
	.MM_BW_Rd(SYNTHESIZED_WIRE_102),
	.MM_BW_Wr(SYNTHESIZED_WIRE_103),
	.MM_Imm_Rd(SYNTHESIZED_WIRE_112),
	.MM_Imm_Wr(SYNTHESIZED_WIRE_113),
	.MM_RdWr(SYNTHESIZED_WIRE_117),
	.MM_Sel_Rd(SYNTHESIZED_WIRE_120),
	.MM_Sel_Wr(SYNTHESIZED_WIRE_121),
	.MM_setSeg_Rd(SYNTHESIZED_WIRE_122),
	.MM_setSeg_Wr(SYNTHESIZED_WIRE_123),
	.RF_adrR0(SYNTHESIZED_WIRE_145),
	.RF_adrR1(SYNTHESIZED_WIRE_146),
	.RF_adrW(SYNTHESIZED_WIRE_25),
	.RF_bwsR0(SYNTHESIZED_WIRE_147),
	.RF_bwsR1(SYNTHESIZED_WIRE_148),
	.RF_bwsW(SYNTHESIZED_WIRE_28),
	.RF_step(SYNTHESIZED_WIRE_30),
	.RF_used(SYNTHESIZED_WIRE_31),
	.RH_adrW(SYNTHESIZED_WIRE_47),
	.RH_bwsW(SYNTHESIZED_WIRE_50));



IBufINF	b2v_inst21(
	.we(SYNTHESIZED_WIRE_150),
	.clk(iClk),
	.data(SYNTHESIZED_WIRE_62),
	.read_addr(SYNTHESIZED_WIRE_151),
	.write_addr(SYNTHESIZED_WIRE_152),
	.q(SYNTHESIZED_WIRE_70));


DecBuf	b2v_inst3(
	.iClk(iClk),
	.iRst(iRst),
	.iReq(SYNTHESIZED_WIRE_65),
	.iJumped(SYNTHESIZED_WIRE_141),
	.iAckWr(SYNTHESIZED_WIRE_150),
	.iAckCnt(SYNTHESIZED_WIRE_68),
	.iFData(SYNTHESIZED_WIRE_69),
	.iFLen(SYNTHESIZED_WIRE_70),
	.memIndex(SYNTHESIZED_WIRE_71),
	.oAck(SYNTHESIZED_WIRE_1),
	.oMemReq(SYNTHESIZED_WIRE_153),
	.oBuf(SYNTHESIZED_WIRE_2),
	.oDRomAdr(SYNTHESIZED_WIRE_144),
	.oFAdrR(SYNTHESIZED_WIRE_151),
	.oFAdrW(SYNTHESIZED_WIRE_152),
	.oLen(SYNTHESIZED_WIRE_3));


DecStream	b2v_inst4(
	.iClk(iClk),
	.iRst(iRst),
	.iJumped(SYNTHESIZED_WIRE_141),
	.iAck(SYNTHESIZED_WIRE_73),
	.iMemReq(SYNTHESIZED_WIRE_153),
	.iData(SYNTHESIZED_WIRE_75),
	.memIndex(SYNTHESIZED_WIRE_76),
	.oAckWr(SYNTHESIZED_WIRE_150),
	.oAckCnt(SYNTHESIZED_WIRE_68),
	.oData(SYNTHESIZED_WIRE_40),
	.oLen(SYNTHESIZED_WIRE_62),
	.oMemIndex(SYNTHESIZED_WIRE_71));


exec	b2v_inst5(
	.iClk(iClk),
	.iBW(SYNTHESIZED_WIRE_77),
	.iESel(SYNTHESIZED_WIRE_78),
	.iCarry(SYNTHESIZED_WIRE_79),
	.iAux(SYNTHESIZED_WIRE_80),
	.iStall(SYNTHESIZED_WIRE_142),
	.iAck_8237(iAck_8237),
	.iAck_8253(iAck_8253),
	.iAck_8259(iAck_8259),
	.iAck_video(iAck_video),
	.iAck_8272(iAck_8272),
	.iAck_ext(iAck_ext),
	.iData_8237(iData_8237),
	.iData_8253(iData_8253),
	.iData_8259(iData_8259),
	.iData_8272(iData_8272),
	.iData_ext(iData_ext),
	.iData_video(iData_video),
	.iDX(SYNTHESIZED_WIRE_82),
	.iEA(SYNTHESIZED_WIRE_83),
	.iExec(SYNTHESIZED_WIRE_84),
	.iFunc(SYNTHESIZED_WIRE_85),
	.iImm1(SYNTHESIZED_WIRE_86),
	.iImm2(SYNTHESIZED_WIRE_87),
	.iMem(SYNTHESIZED_WIRE_88),
	.iRF1(SYNTHESIZED_WIRE_89),
	.iRF2(SYNTHESIZED_WIRE_90),
	.iSelIn1(SYNTHESIZED_WIRE_91),
	.iSelIn2(SYNTHESIZED_WIRE_92),
	.iSelOut(SYNTHESIZED_WIRE_93),
	.oShfCF(SYNTHESIZED_WIRE_128),
	.oShfOF(SYNTHESIZED_WIRE_129),
	.oMulF(SYNTHESIZED_WIRE_130),
	.oAdjCF(SYNTHESIZED_WIRE_131),
	.oAdjAF(SYNTHESIZED_WIRE_132),
	.isZero(SYNTHESIZED_WIRE_52),
	.oStallD(SYNTHESIZED_WIRE_8),
	.oDivErr(SYNTHESIZED_WIRE_11),
	.oStallIO(SYNTHESIZED_WIRE_9),
	.oBusAdr_8259(oBusAdr_8259),
	.oADJ(SYNTHESIZED_WIRE_134),
	.oALU(SYNTHESIZED_WIRE_133),
	.oBusAdr16(oBusAdr16),
	.oBusAdr_8237(oBusAdr_8237),
	.oBusAdr_8253(oBusAdr_8253),
	.oBusAdr_8272(oBusAdr_8272),
	.oBusAdr_video(oBusAdr_video),
	.oBusData16(oBusData16),
	.oBusData8(oBusData8),
	.oBusRW_8237(oBusRW_8237),
	.oBusRW_8253(oBusRW_8253),
	.oBusRW_8259(oBusRW_8259),
	.oBusRW_8272(oBusRW_8272),
	.oBusRW_ext(oBusRW_ext),
	.oBusRW_video(oBusRW_video),
	.oMUL(SYNTHESIZED_WIRE_137),
	.oR1(SYNTHESIZED_WIRE_139),
	.oR2(SYNTHESIZED_WIRE_140),
	.oSHF(SYNTHESIZED_WIRE_138),
	.OutR(SYNTHESIZED_WIRE_149));


memCtrl	b2v_inst6(
	.iClk(iClk),
	.iRst(iRst),
	.iMemReq(SYNTHESIZED_WIRE_153),
	.iBurstReq(SYNTHESIZED_WIRE_154),
	.iDMABurstReq(SYNTHESIZED_WIRE_154),
	.iRamAck(iRamAck),
	.iJumped(SYNTHESIZED_WIRE_141),
	.segOR_Rd(SYNTHESIZED_WIRE_98),
	.segOR_Wr(SYNTHESIZED_WIRE_99),
	.AInt(SYNTHESIZED_WIRE_100),
	.BP(SYNTHESIZED_WIRE_101),
	.BW_Rd(SYNTHESIZED_WIRE_102),
	.BW_Wr(SYNTHESIZED_WIRE_103),
	.BX(SYNTHESIZED_WIRE_104),
	.CS(SYNTHESIZED_WIRE_105),
	.DI(SYNTHESIZED_WIRE_106),
	.DS(SYNTHESIZED_WIRE_107),
	.EAImm_Rd(SYNTHESIZED_WIRE_108),
	.EAImm_Wr(SYNTHESIZED_WIRE_109),
	.ES(SYNTHESIZED_WIRE_110),
	
	.iData(SYNTHESIZED_WIRE_149),
	
	.Imm_Rd(SYNTHESIZED_WIRE_112),
	.Imm_Wr(SYNTHESIZED_WIRE_113),
	.IP(SYNTHESIZED_WIRE_114),
	.iRamData(iRamData),
	.MOD_Rd(SYNTHESIZED_WIRE_115),
	.MOD_Wr(SYNTHESIZED_WIRE_116),
	.RdWr(SYNTHESIZED_WIRE_117),
	.RM_Rd(SYNTHESIZED_WIRE_118),
	.RM_Wr(SYNTHESIZED_WIRE_119),
	.Sel_Rd(SYNTHESIZED_WIRE_120),
	.Sel_Wr(SYNTHESIZED_WIRE_121),
	.setSeg_Rd(SYNTHESIZED_WIRE_122),
	.setSeg_Wr(SYNTHESIZED_WIRE_123),
	.SI(SYNTHESIZED_WIRE_124),
	.SP(SYNTHESIZED_WIRE_125),
	.SS(SYNTHESIZED_WIRE_126),
	
	
	.oRamBW(oRamBW),
	.oAck32(SYNTHESIZED_WIRE_73),
	.Stall(SYNTHESIZED_WIRE_142),
	.immEA(SYNTHESIZED_WIRE_83),
	.oData(SYNTHESIZED_WIRE_88),
	.oData32(SYNTHESIZED_WIRE_75),
	.oIndex32(SYNTHESIZED_WIRE_76),
	.oRamAdr(oRamAdr),
	.oRamBurst(oRamBurst),
	.oRamData(oRamData),
	.oRamRW(oRamRW));


XLATdly	b2v_inst7(
	.iClk(iClk),
	.iData(SYNTHESIZED_WIRE_149),
	.oData(SYNTHESIZED_WIRE_100));


FlagCtrl	b2v_inst8(
	.iClk(iClk),
	.iRst(iRst),
	.iShfCF(SYNTHESIZED_WIRE_128),
	.iShfOF(SYNTHESIZED_WIRE_129),
	.iMulF(SYNTHESIZED_WIRE_130),
	.iAdjCF(SYNTHESIZED_WIRE_131),
	.iAdjAF(SYNTHESIZED_WIRE_132),
	.ALU(SYNTHESIZED_WIRE_133),
	.iADJ(SYNTHESIZED_WIRE_134),
	.iFBW(SYNTHESIZED_WIRE_135),
	.iFSel(SYNTHESIZED_WIRE_136),
	.iMUL(SYNTHESIZED_WIRE_137),
	.iSHF(SYNTHESIZED_WIRE_138),
	.R1(SYNTHESIZED_WIRE_139),
	.R2(SYNTHESIZED_WIRE_140),
	.f_carry(SYNTHESIZED_WIRE_79),
	
	
	
	
	
	.f_auxiliary(SYNTHESIZED_WIRE_80),
	
	
	.flgwrd(SYNTHESIZED_WIRE_143));


endmodule
