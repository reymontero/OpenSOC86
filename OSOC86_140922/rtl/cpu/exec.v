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
// CREATED		"Tue Jul 15 22:53:31 2014"

module exec(
	iClk,
	iBW,
	iESel,
	iCarry,
	iAux,
	iStall,
	iAck_8237,
	iAck_8253,
	iAck_8259,
	iAck_video,
	iAck_8272,
	iAck_ext,
	iData_8237,
	iData_8253,
	iData_8259,
	iData_8272,
	iData_ext,
	iData_video,
	iDX,
	iEA,
	iExec,
	iFunc,
	iImm1,
	iImm2,
	iMem,
	iRF1,
	iRF2,
	iSelIn1,
	iSelIn2,
	iSelOut,
	oShfCF,
	oShfOF,
	oMulF,
	oAdjCF,
	oAdjAF,
	isZero,
	oStallD,
	oDivErr,
	oStallIO,
	oBusAdr_8259,
	oADJ,
	oALU,
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
	oMUL,
	oR1,
	oR2,
	oSHF,
	OutR
);


input wire	iClk;
input wire	iBW;
input wire	iESel;
input wire	iCarry;
input wire	iAux;
input wire	iStall;
input wire	iAck_8237;
input wire	iAck_8253;
input wire	iAck_8259;
input wire	iAck_video;
input wire	iAck_8272;
input wire	iAck_ext;
input wire	[7:0] iData_8237;
input wire	[7:0] iData_8253;
input wire	[7:0] iData_8259;
input wire	[7:0] iData_8272;
input wire	[15:0] iData_ext;
input wire	[7:0] iData_video;
input wire	[15:0] iDX;
input wire	[15:0] iEA;
input wire	[2:0] iExec;
input wire	[3:0] iFunc;
input wire	[15:0] iImm1;
input wire	[15:0] iImm2;
input wire	[15:0] iMem;
input wire	[15:0] iRF1;
input wire	[15:0] iRF2;
input wire	[2:0] iSelIn1;
input wire	[2:0] iSelIn2;
input wire	[3:0] iSelOut;
output wire	oShfCF;
output wire	oShfOF;
output wire	oMulF;
output wire	oAdjCF;
output wire	oAdjAF;
output wire	isZero;
output wire	oStallD;
output wire	oDivErr;
output wire	oStallIO;
output wire	oBusAdr_8259;
output wire	[15:0] oADJ;
output wire	[16:0] oALU;
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
output wire	[15:0] oMUL;
output wire	[15:0] oR1;
output wire	[15:0] oR2;
output wire	[15:0] oSHF;
output wire	[15:0] OutR;

wire	[15:0] SYNTHESIZED_WIRE_26;
wire	[15:0] SYNTHESIZED_WIRE_27;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_13;
wire	SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_15;
wire	[15:0] SYNTHESIZED_WIRE_16;
wire	[15:0] SYNTHESIZED_WIRE_17;
wire	[15:0] SYNTHESIZED_WIRE_18;
wire	[15:0] SYNTHESIZED_WIRE_19;
wire	[15:0] SYNTHESIZED_WIRE_20;
wire	[15:0] SYNTHESIZED_WIRE_21;
wire	[16:0] SYNTHESIZED_WIRE_24;
wire	[15:0] SYNTHESIZED_WIRE_25;





exec_selrd	b2v_inst(
	.iImm1(iImm1),
	.iImm2(iImm2),
	.iMem(iMem),
	.iRF1(iRF1),
	.iRF2(iRF2),
	.iSelIn1(iSelIn1),
	.iSelIn2(iSelIn2),
	.oR1(SYNTHESIZED_WIRE_26),
	.oR2(SYNTHESIZED_WIRE_27));


exec_alu	b2v_inst12(
	.iCarry(iCarry),
	.iFunc(iFunc),
	.R1(SYNTHESIZED_WIRE_26),
	.R2(SYNTHESIZED_WIRE_27),
	.oResult(SYNTHESIZED_WIRE_24));


exec_mult	b2v_inst13(
	.iBW(iBW),
	.iESel(iESel),
	.R1(SYNTHESIZED_WIRE_26),
	.R2(SYNTHESIZED_WIRE_27),
	.oMulOut(SYNTHESIZED_WIRE_18),
	.oMulOutHi(SYNTHESIZED_WIRE_19));


exec_shift	b2v_inst14(
	.iBW(iBW),
	.iESel(iESel),
	.iCarry(iCarry),
	.iFunc(iFunc),
	.iRF2(iRF2),
	.R1(SYNTHESIZED_WIRE_26),
	.oShf_c(SYNTHESIZED_WIRE_12),
	.oShf_o(SYNTHESIZED_WIRE_13),
	.oShf_out(SYNTHESIZED_WIRE_25));


exec_adjust	b2v_inst15(
	.iCarry(iCarry),
	.iAux(iAux),
	.iFunc(iFunc),
	.R1(SYNTHESIZED_WIRE_26),
	.R2(SYNTHESIZED_WIRE_27),
	.oOutCF(SYNTHESIZED_WIRE_14),
	.oOutAF(SYNTHESIZED_WIRE_15),
	.oOutAX(SYNTHESIZED_WIRE_21));


exec_div	b2v_inst16(
	.iClk(iClk),
	.iBW(iBW),
	.iESel(iESel),
	.iStall(iStall),
	.iDX(iDX),
	.iExec(iExec),
	.iFunc(iFunc),
	.R1(SYNTHESIZED_WIRE_26),
	.R2(SYNTHESIZED_WIRE_27),
	.oStallD(oStallD),
	.oDivErr(oDivErr),
	.divOut(SYNTHESIZED_WIRE_16)
	);


exec_IO	b2v_inst17(
	.iClk(iClk),
	.BW(iBW),
	.iAck_8237(iAck_8237),
	.iAck_8253(iAck_8253),
	.iAck_8259(iAck_8259),
	.iAck_8272(iAck_8272),
	.iAck_video(iAck_video),
	.iAck_ext(iAck_ext),
	.iAdr(SYNTHESIZED_WIRE_27),
	.iData(SYNTHESIZED_WIRE_26),
	.iData_8237(iData_8237),
	.iData_8253(iData_8253),
	.iData_8259(iData_8259),
	.iData_8272(iData_8272),
	.iData_ext(iData_ext),
	.iData_video(iData_video),
	.iExec(iExec),
	.Stall(oStallIO),
	.oBusAdr_8259(oBusAdr_8259),
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
	.oData(SYNTHESIZED_WIRE_17));


exec_cbwd	b2v_inst18(
	.iFunc(iFunc),
	.R1(SYNTHESIZED_WIRE_26),
	.oCBWD(SYNTHESIZED_WIRE_20));


exec_selwr	b2v_inst19(
	.iClk(iClk),
	.iBW(iBW),
	.Sgn(iESel),
	.shf_c(SYNTHESIZED_WIRE_12),
	.shf_o(SYNTHESIZED_WIRE_13),
	.outcf(SYNTHESIZED_WIRE_14),
	.outaf(SYNTHESIZED_WIRE_15),
	.divOut(SYNTHESIZED_WIRE_16),
	.iEA(iEA),
	.iExec(iExec),
	.iFunc(iFunc),
	.iMem(iMem),
	.indata(SYNTHESIZED_WIRE_17),
	.iSelOut(iSelOut),
	.mulOut(SYNTHESIZED_WIRE_18),
	.mulOutHi(SYNTHESIZED_WIRE_19),
	.out_cbwd(SYNTHESIZED_WIRE_20),
	.outAX(SYNTHESIZED_WIRE_21),
	.R1(SYNTHESIZED_WIRE_26),
	.R2(SYNTHESIZED_WIRE_27),
	.result(SYNTHESIZED_WIRE_24),
	.shf_out(SYNTHESIZED_WIRE_25),
	.oShfCF(oShfCF),
	.oShfOF(oShfOF),
	.oMulF(oMulF),
	.oAdjCF(oAdjCF),
	.oAdjAF(oAdjAF),
	.isZero(isZero),
	.oADJ(oADJ),
	.oALU(oALU),
	.oMUL(oMUL),
	.oR1(oR1),
	.oR2(oR2),
	.oSHF(oSHF),
	.OutR(OutR));


endmodule
