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
// CREATED		"Wed Jul 02 23:04:24 2014"

module OSOC86_cpu(
	iClk,
	iRamAck,
	iRst,
	iInt,
	iInt_T,
	iRamData,
	oRamBW,
	clk100,
	oHalted,
	oAckInt,
	cur_Inst,
	DUMP,
	oRamAdr,
	oRamBurst,
	oRamData,
	oRamRW,
	oTmpOut
);


input wire	iClk;
input wire	iRamAck;
input wire	iRst;
input wire	iInt;
input wire	[7:0] iInt_T;
input wire	[31:0] iRamData;
output wire	oRamBW;
output wire	clk100;
output wire	oHalted;
output wire	oAckInt;
output wire	[63:0] cur_Inst;
output wire	[207:0] DUMP;
output wire	[19:0] oRamAdr;
output wire	[1:0] oRamBurst;
output wire	[15:0] oRamData;
output wire	[1:0] oRamRW;
output wire	[15:0] oTmpOut;

wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_13;
wire	SYNTHESIZED_WIRE_6;
wire	[15:0] SYNTHESIZED_WIRE_7;
wire	[15:0] SYNTHESIZED_WIRE_9;
wire	[15:0] SYNTHESIZED_WIRE_10;
wire	[1:0] SYNTHESIZED_WIRE_11;

assign	clk100 = SYNTHESIZED_WIRE_12;
assign	SYNTHESIZED_WIRE_13 = 0;




cpu_top	b2v_inst(
	.iClk(SYNTHESIZED_WIRE_12),
	.iRst(iRst),
	.iRamAck(iRamAck),
	.iAck_8237(SYNTHESIZED_WIRE_13),
	.iAck_8253(SYNTHESIZED_WIRE_13),
	.iAck_8259(SYNTHESIZED_WIRE_13),
	.iAck_video(SYNTHESIZED_WIRE_13),
	.iInt(iInt),
	.iAck_8272(SYNTHESIZED_WIRE_13),
	.iAck_ext(SYNTHESIZED_WIRE_6),
	
	
	
	
	.iData_ext(SYNTHESIZED_WIRE_7),
	
	.iInt_T(iInt_T),
	.iRamData(iRamData),
	.oRamBW(oRamBW),
	.oHalted(oHalted),
	
	.oAckInt(oAckInt),
	.cur_Inst(cur_Inst),
	.DUMP(DUMP),
	.oBusAdr16(SYNTHESIZED_WIRE_9),
	
	
	
	
	.oBusData16(SYNTHESIZED_WIRE_10),
	
	
	
	
	
	.oBusRW_ext(SYNTHESIZED_WIRE_11),
	
	.oRamAdr(oRamAdr),
	.oRamBurst(oRamBurst),
	.oRamData(oRamData),
	.oRamRW(oRamRW),
	.oTmpOut(oTmpOut));


PLL	b2v_inst1(
	.inclk0(iClk),
	.c0(SYNTHESIZED_WIRE_12));



IOBusSim	b2v_inst3(
	.iClk(SYNTHESIZED_WIRE_12),
	.iAdr(SYNTHESIZED_WIRE_9),
	.iData(SYNTHESIZED_WIRE_10),
	.iRW(SYNTHESIZED_WIRE_11),
	.oAck(SYNTHESIZED_WIRE_6),
	.oData(SYNTHESIZED_WIRE_7));


endmodule
