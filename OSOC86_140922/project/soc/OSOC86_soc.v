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
// CREATED		"Fri Sep 12 23:02:25 2014"

module OSOC86_soc(
	iClk,
	iRst,
	iVGA_RAMAck,
	iFloppyAck,
	iRamAck,
	iRamData,
	iVGA_RAMData,
	oHalted,
	clk100,
	oVGA_RAMRd,
	oVGA_HS,
	oVGA_VS,
	oVGA_SYNC_N,
	oVGA_BLANK_N,
	oVGA_CLOCK,
	oRamBW,
	cur_Inst,
	DUMP,
	oDMAAdr2,
	oDMACnt2,
	oFloppyLBA,
	oFloppyRW,
	oRamAdr,
	oRamBurst,
	oRamData,
	oRamRW,
	oTmpOut,
	oVGA_B,
	oVGA_G,
	oVGA_R,
	oVGA_RAMAdr
);


input wire	iClk;
input wire	iRst;
input wire	iVGA_RAMAck;
input wire	iFloppyAck;
input wire	iRamAck;
input wire	[31:0] iRamData;
input wire	[31:0] iVGA_RAMData;
output wire	oHalted;
output wire	clk100;
output wire	oVGA_RAMRd;
output wire	oVGA_HS;
output wire	oVGA_VS;
output wire	oVGA_SYNC_N;
output wire	oVGA_BLANK_N;
output wire	oVGA_CLOCK;
output wire	oRamBW;
output wire	[63:0] cur_Inst;
output wire	[207:0] DUMP;
output wire	[23:0] oDMAAdr2;
output wire	[15:0] oDMACnt2;
output wire	[11:0] oFloppyLBA;
output wire	[1:0] oFloppyRW;
output wire	[19:0] oRamAdr;
output wire	[1:0] oRamBurst;
output wire	[15:0] oRamData;
output wire	[1:0] oRamRW;
output wire	[15:0] oTmpOut;
output wire	[9:0] oVGA_B;
output wire	[9:0] oVGA_G;
output wire	[9:0] oVGA_R;
output wire	[18:0] oVGA_RAMAdr;

wire	SYNTHESIZED_WIRE_52;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;
wire	[7:0] SYNTHESIZED_WIRE_8;
wire	[7:0] SYNTHESIZED_WIRE_9;
wire	[7:0] SYNTHESIZED_WIRE_10;
wire	[7:0] SYNTHESIZED_WIRE_11;
wire	[15:0] SYNTHESIZED_WIRE_12;
wire	[7:0] SYNTHESIZED_WIRE_13;
wire	[7:0] SYNTHESIZED_WIRE_14;
wire	[15:0] SYNTHESIZED_WIRE_16;
wire	[15:0] SYNTHESIZED_WIRE_17;
wire	[1:0] SYNTHESIZED_WIRE_18;
wire	[4:0] SYNTHESIZED_WIRE_20;
wire	[7:0] SYNTHESIZED_WIRE_53;
wire	[1:0] SYNTHESIZED_WIRE_22;
wire	[1:0] SYNTHESIZED_WIRE_24;
wire	[1:0] SYNTHESIZED_WIRE_26;
wire	SYNTHESIZED_WIRE_28;
wire	SYNTHESIZED_WIRE_29;
wire	SYNTHESIZED_WIRE_54;
wire	SYNTHESIZED_WIRE_35;
wire	SYNTHESIZED_WIRE_37;
wire	[1:0] SYNTHESIZED_WIRE_39;
wire	[6:0] SYNTHESIZED_WIRE_41;
wire	[1:0] SYNTHESIZED_WIRE_43;
wire	[7:0] SYNTHESIZED_WIRE_45;
wire	[11:0] SYNTHESIZED_WIRE_47;
wire	[1:0] SYNTHESIZED_WIRE_49;
wire	[1:0] SYNTHESIZED_WIRE_51;

assign	clk100 = SYNTHESIZED_WIRE_52;
assign	SYNTHESIZED_WIRE_54 = 0;




cpu_top	b2v_inst(
	.iClk(SYNTHESIZED_WIRE_52),
	.iRst(iRst),
	.iRamAck(iRamAck),
	.iAck_8237(SYNTHESIZED_WIRE_1),
	.iAck_8253(SYNTHESIZED_WIRE_2),
	.iAck_8259(SYNTHESIZED_WIRE_3),
	.iAck_video(SYNTHESIZED_WIRE_4),
	.iInt(SYNTHESIZED_WIRE_5),
	.iAck_8272(SYNTHESIZED_WIRE_6),
	.iAck_ext(SYNTHESIZED_WIRE_7),
	.iData_8237(SYNTHESIZED_WIRE_8),
	.iData_8253(SYNTHESIZED_WIRE_9),
	.iData_8259(SYNTHESIZED_WIRE_10),
	.iData_8272(SYNTHESIZED_WIRE_11),
	.iData_ext(SYNTHESIZED_WIRE_12),
	.iData_video(SYNTHESIZED_WIRE_13),
	.iInt_T(SYNTHESIZED_WIRE_14),
	.iRamData(iRamData),
	.oRamBW(oRamBW),
	.oHalted(oHalted),
	.oBusAdr_8259(SYNTHESIZED_WIRE_28),
	.oAckInt(SYNTHESIZED_WIRE_37),
	.cur_Inst(cur_Inst),
	.DUMP(DUMP),
	.oBusAdr16(SYNTHESIZED_WIRE_16),
	.oBusAdr_8237(SYNTHESIZED_WIRE_20),
	.oBusAdr_8253(SYNTHESIZED_WIRE_24),
	.oBusAdr_8272(SYNTHESIZED_WIRE_49),
	.oBusAdr_video(SYNTHESIZED_WIRE_41),
	.oBusData16(SYNTHESIZED_WIRE_17),
	.oBusData8(SYNTHESIZED_WIRE_53),
	.oBusRW_8237(SYNTHESIZED_WIRE_22),
	.oBusRW_8253(SYNTHESIZED_WIRE_26),
	.oBusRW_8259(SYNTHESIZED_WIRE_39),
	.oBusRW_8272(SYNTHESIZED_WIRE_51),
	.oBusRW_ext(SYNTHESIZED_WIRE_18),
	.oBusRW_video(SYNTHESIZED_WIRE_43),
	.oRamAdr(oRamAdr),
	.oRamBurst(oRamBurst),
	.oRamData(oRamData),
	.oRamRW(oRamRW),
	.oTmpOut(oTmpOut));


PLL	b2v_inst1(
	.inclk0(iClk),
	.c0(SYNTHESIZED_WIRE_52));


IOBusExt	b2v_inst10(
	.iClk(SYNTHESIZED_WIRE_52),
	.iAdr(SYNTHESIZED_WIRE_16),
	.iData(SYNTHESIZED_WIRE_17),
	.iRW(SYNTHESIZED_WIRE_18),
	.oAck(SYNTHESIZED_WIRE_7),
	.oData(SYNTHESIZED_WIRE_12));


I8237	b2v_inst2(
	.iClk(SYNTHESIZED_WIRE_52),
	
	
	
	
	.iAdr(SYNTHESIZED_WIRE_20),
	.iData(SYNTHESIZED_WIRE_53),
	.iRW(SYNTHESIZED_WIRE_22),
	.oAck(SYNTHESIZED_WIRE_1),
	
	
	
	
	.oData(SYNTHESIZED_WIRE_8),
	
	
	.oMemAdr2(oDMAAdr2),
	
	
	
	.oMemCnt2(oDMACnt2)
	);


I8253	b2v_inst3(
	.iClk(SYNTHESIZED_WIRE_52),
	.iRst(iRst),
	
	
	
	.iAdr(SYNTHESIZED_WIRE_24),
	.iData(SYNTHESIZED_WIRE_53),
	.iRW(SYNTHESIZED_WIRE_26),
	.oAck(SYNTHESIZED_WIRE_2),
	.OUT0(SYNTHESIZED_WIRE_29),
	
	
	.oData(SYNTHESIZED_WIRE_9));


I8259	b2v_inst4(
	.iClk(SYNTHESIZED_WIRE_52),
	.iRst(iRst),
	.iA0(SYNTHESIZED_WIRE_28),
	.iReq0(SYNTHESIZED_WIRE_29),
	.iReq1(SYNTHESIZED_WIRE_54),
	.iReq2(SYNTHESIZED_WIRE_54),
	.iReq3(SYNTHESIZED_WIRE_54),
	.iReq4(SYNTHESIZED_WIRE_54),
	.iReq5(SYNTHESIZED_WIRE_54),
	.iReq6(SYNTHESIZED_WIRE_35),
	.iReq7(SYNTHESIZED_WIRE_54),
	.iAck(SYNTHESIZED_WIRE_37),
	.iData(SYNTHESIZED_WIRE_53),
	.iRW(SYNTHESIZED_WIRE_39),
	.oINT(SYNTHESIZED_WIRE_5),
	.oAck(SYNTHESIZED_WIRE_3),
	.oData(SYNTHESIZED_WIRE_10),
	.oINT_T(SYNTHESIZED_WIRE_14));


Video	b2v_inst5(
	.iClk(SYNTHESIZED_WIRE_52),
	.iBusAdr(SYNTHESIZED_WIRE_41),
	.iBusData(SYNTHESIZED_WIRE_53),
	.iBusRW(SYNTHESIZED_WIRE_43),
	.oBusAck(SYNTHESIZED_WIRE_4),
	.oBusData(SYNTHESIZED_WIRE_13));



VGActrl	b2v_inst7(
	.iClk_100M(SYNTHESIZED_WIRE_52),
	.iRst(iRst),
	.iRAMAck(iVGA_RAMAck),
	.iFontData(SYNTHESIZED_WIRE_45),
	.iRAMData(iVGA_RAMData),
	.oVGA_HS(oVGA_HS),
	.oVGA_VS(oVGA_VS),
	.oVGA_SYNC(oVGA_SYNC_N),
	.oVGA_BLANK(oVGA_BLANK_N),
	.oVGA_CLOCK(oVGA_CLOCK),
	.oRamRd(oVGA_RAMRd),
	.oFontAdr(SYNTHESIZED_WIRE_47),
	.oRAMAdr(oVGA_RAMAdr),
	.oVGA_B(oVGA_B),
	.oVGA_G(oVGA_G),
	.oVGA_R(oVGA_R));


FontROM	b2v_inst8(
	.clk(SYNTHESIZED_WIRE_52),
	.addr(SYNTHESIZED_WIRE_47),
	.q(SYNTHESIZED_WIRE_45));


I8272	b2v_inst9(
	.iClk(SYNTHESIZED_WIRE_52),
	.iRst(iRst),
	.iAckRW(iFloppyAck),
	.iAdr(SYNTHESIZED_WIRE_49),
	.iData(SYNTHESIZED_WIRE_53),
	.iRW(SYNTHESIZED_WIRE_51),
	.oAck(SYNTHESIZED_WIRE_6),
	.oIRQ(SYNTHESIZED_WIRE_35),
	.oData(SYNTHESIZED_WIRE_11),
	.oLBA(oFloppyLBA),
	.oReqRW(oFloppyRW));


endmodule
