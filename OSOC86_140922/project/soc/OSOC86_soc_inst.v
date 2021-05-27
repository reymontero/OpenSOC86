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


// Generated by Quartus II 64-Bit Version 13.0 (Build Build 232 06/12/2013)
// Created on Fri Sep 12 23:02:42 2014

OSOC86_soc OSOC86_soc_inst
(
	.iClk(iClk_sig) ,	// input  iClk_sig
	.iRst(iRst_sig) ,	// input  iRst_sig
	.iVGA_RAMAck(iVGA_RAMAck_sig) ,	// input  iVGA_RAMAck_sig
	.iFloppyAck(iFloppyAck_sig) ,	// input  iFloppyAck_sig
	.iRamAck(iRamAck_sig) ,	// input  iRamAck_sig
	.iRamData(iRamData_sig) ,	// input [31:0] iRamData_sig
	.iVGA_RAMData(iVGA_RAMData_sig) ,	// input [31:0] iVGA_RAMData_sig
	.oHalted(oHalted_sig) ,	// output  oHalted_sig
	.clk100(clk100_sig) ,	// output  clk100_sig
	.oVGA_RAMRd(oVGA_RAMRd_sig) ,	// output  oVGA_RAMRd_sig
	.oVGA_HS(oVGA_HS_sig) ,	// output  oVGA_HS_sig
	.oVGA_VS(oVGA_VS_sig) ,	// output  oVGA_VS_sig
	.oVGA_SYNC_N(oVGA_SYNC_N_sig) ,	// output  oVGA_SYNC_N_sig
	.oVGA_BLANK_N(oVGA_BLANK_N_sig) ,	// output  oVGA_BLANK_N_sig
	.oVGA_CLOCK(oVGA_CLOCK_sig) ,	// output  oVGA_CLOCK_sig
	.oRamBW(oRamBW_sig) ,	// output  oRamBW_sig
	.cur_Inst(cur_Inst_sig) ,	// output [63:0] cur_Inst_sig
	.DUMP(DUMP_sig) ,	// output [207:0] DUMP_sig
	.oDMAAdr2(oDMAAdr2_sig) ,	// output [23:0] oDMAAdr2_sig
	.oDMACnt2(oDMACnt2_sig) ,	// output [15:0] oDMACnt2_sig
	.oFloppyLBA(oFloppyLBA_sig) ,	// output [11:0] oFloppyLBA_sig
	.oFloppyRW(oFloppyRW_sig) ,	// output [1:0] oFloppyRW_sig
	.oRamAdr(oRamAdr_sig) ,	// output [19:0] oRamAdr_sig
	.oRamBurst(oRamBurst_sig) ,	// output [1:0] oRamBurst_sig
	.oRamData(oRamData_sig) ,	// output [15:0] oRamData_sig
	.oRamRW(oRamRW_sig) ,	// output [1:0] oRamRW_sig
	.oTmpOut(oTmpOut_sig) ,	// output [15:0] oTmpOut_sig
	.oVGA_B(oVGA_B_sig) ,	// output [9:0] oVGA_B_sig
	.oVGA_G(oVGA_G_sig) ,	// output [9:0] oVGA_G_sig
	.oVGA_R(oVGA_R_sig) ,	// output [9:0] oVGA_R_sig
	.oVGA_RAMAdr(oVGA_RAMAdr_sig) 	// output [18:0] oVGA_RAMAdr_sig
);

