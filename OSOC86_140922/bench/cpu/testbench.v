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


`timescale 1 ns/ 1 ps
module testbench();

//--- clock gen and reset ---------------------------------------
reg				iClk_sig;
reg				iRst_sig;

initial
begin
	iClk_sig = 0;
	iRst_sig = 1;
	#400 iRst_sig = 1;
	#1000 iRst_sig = 0;
end

always
	#10 iClk_sig = ~iClk_sig;

//---------------------------------------------------------------

reg				iRamAck_sig;
reg				iInt_sig;
reg	[7:0]		iInt_T_sig;
reg	[31:0]	iRamData_sig;

wire				clk100_sig;
wire				oHalted_sig;
wire				oAckInt_sig;
wire	[63:0]	cur_Inst_sig;
wire	[207:0]	DUMP_sig;
wire				oRamBW_sig;
wire	[19:0]	oRamAdr_sig;
wire	[1:0]		oRamBurst_sig;
wire	[15:0]	oRamData_sig;
wire	[1:0]		oRamRW_sig;
wire	[15:0]	oTmpOut_sig;

initial
begin
	iRamAck_sig = 1'b0;
	iInt_sig = 1'b0;
	iInt_T_sig = 8'd0;
	iRamData_sig = 32'd0;
end

OSOC86_cpu OSOC86_cpu_inst
(
	.iClk(iClk_sig) ,	// input  iClk_sig
	.iRamAck(iRamAck_sig) ,	// input  iRamAck_sig
	.iRst(iRst_sig) ,	// input  iRst_sig
	.iInt(iInt_sig) ,	// input  iInt_sig
	.iInt_T(iInt_T_sig) ,	// input [7:0] iInt_T_sig
	.iRamData(iRamData_sig) ,	// input [31:0] iRamData_sig
	.oRamBW(oRamBW_sig) ,	// output  oRamBW_sig
	.clk100(clk100_sig) ,	// output  clk100_sig
	.oHalted(oHalted_sig) ,	// output  oHalted_sig
	.oAckInt(oAckInt_sig) ,	// output  oAckInt_sig
	.cur_Inst(cur_Inst_sig) ,	// output [63:0] cur_Inst_sig
	.DUMP(DUMP_sig) ,	// output [207:0] DUMP_sig
	.oRamAdr(oRamAdr_sig) ,	// output [19:0] oRamAdr_sig
	.oRamBurst(oRamBurst_sig) ,	// output [1:0] oRamBurst_sig
	.oRamData(oRamData_sig) ,	// output [15:0] oRamData_sig
	.oRamRW(oRamRW_sig) ,	// output [1:0] oRamRW_sig
	.oTmpOut(oTmpOut_sig) 	// output [15:0] oTmpOut_sig
);

//---------------------------------------------------------------

reg	[7:0]		RAM[0:1048575];

reg	[4:0]		tmpID;
reg	[1:104]	tmpStr;
reg	[1:352]	memFile;

integer file;

integer i;
initial
begin
	for (i=0; i < 1048576; i=i+1)
		RAM[i] = 8'b0;
	
	//--- testing ---
	
	tmpID = 5'h01;
	$sformat(tmpStr, "instlog%h.txt", tmpID);
	file = $fopen(tmpStr, "w");
	$sformat(memFile, "..\\..\\..\\..\\test\\hex\\testmem%h.txt", tmpID);
	$readmemh( memFile, RAM, 983040, 1048575);
	
end

//---------------------------------------------------------------

integer j;
reg	preHALTED;
always @(posedge clk100_sig)
begin
	if (cur_Inst_sig[61] == 1'b1)
		$fdisplay(file, "%h \t%h\t%h\t[%h %h %h %h] [%h %h %h %h] [%h %h %h %h]", DUMP_sig[207:192], cur_Inst_sig[7:0], cur_Inst_sig[15:8], DUMP_sig[191:176], DUMP_sig[175:160], DUMP_sig[159:144], DUMP_sig[143:128], DUMP_sig[127:112], DUMP_sig[111:96], DUMP_sig[95:80], DUMP_sig[79:64], DUMP_sig[63:48], DUMP_sig[47:32], DUMP_sig[31:16], DUMP_sig[15:0]);
	preHALTED <= oHalted_sig;// & ~oStall_sig;
	if ({preHALTED, oHalted_sig} == 2'b01)// && (oStall_sig == 1'b0))
	begin
		for (j=0; j <= 256; j=j+16) 
		$fdisplay(file, "%h:  0x%h%h  0x%h%h  0x%h%h  0x%h%h  0x%h%h  0x%h%h  0x%h%h  0x%h%h", j, RAM[j+1], RAM[j+0], RAM[j+3], RAM[j+2], RAM[j+5], RAM[j+4], RAM[j+7], RAM[j+6], RAM[j+9], RAM[j+8], RAM[j+11], RAM[j+10], RAM[j+13], RAM[j+12], RAM[j+15], RAM[j+14]);
		//$stop;
	end
end

//---------------------------------------------------------------

reg	[8:0]	cnt_int;

initial
	cnt_int = 9'd0;

always @(posedge clk100_sig)
begin
//	iInt_T_sig = 8'd8;
//	if (cnt_int < 9'd511)
//		cnt_int <= cnt_int + 8'd1;
//	if (cnt_int == 9'd329)//9'd355)// 
//		iInt_sig <= 1'b1;
//	if (oAckInt_sig == 1'b1)
		iInt_sig <= 1'b0;
end

//---------------------------------------------------------------

reg	[1:0]	state;
reg	[2:0]	cnt;

initial
begin
	state = 2'd0;
	cnt = 3'd0;
end

reg [19:0] curPC;

always @(posedge clk100_sig)
begin
	iRamAck_sig <= 1'b0;
	
	if (oRamRW_sig[0] == 1'b1)
	begin
		iRamAck_sig <= 1'b1;
		RAM[oRamAdr_sig] <= oRamData_sig[7:0];
		if (oRamBW_sig == 1'b1)
			RAM[oRamAdr_sig+20'd1] <= oRamData_sig[15:8];
	end
	
	if (oRamRW_sig[1] == 1'b1)
	begin
		iRamAck_sig <= 1'b1;
		iRamData_sig[7:0] <= RAM[oRamAdr_sig];
		if (oRamBW_sig == 1'b1)
			iRamData_sig[15:8] <= RAM[oRamAdr_sig+20'd1];
		else
			iRamData_sig[15:8] <= 8'd0;
		iRamData_sig[31:16] <= 16'd0;
	end
	
	case (state)
		2'd0:	if (oRamBurst_sig == 2'd2)
				begin
					cnt <= 3'd0;
					state <= 2'd1;
				end
		2'd1:	begin
					curPC = oRamAdr_sig;
					iRamData_sig[7:0]		<= RAM[curPC + {15'd0, cnt, 2'd0}];
					iRamData_sig[15:8]	<= RAM[curPC + {15'd0, cnt, 2'd1}];
					iRamData_sig[23:16]	<= RAM[curPC + {15'd0, cnt, 2'd2}];
					iRamData_sig[31:24]	<= RAM[curPC + {15'd0, cnt, 2'd3}];
					
					cnt <= cnt + 3'd1;
					iRamAck_sig <= 1'b1;
					state <= 2'd2;
				end
		2'd2:	begin
					curPC = oRamAdr_sig;
					iRamData_sig[7:0]		<= RAM[curPC + {15'd0, cnt, 2'd0}];
					iRamData_sig[15:8]	<= RAM[curPC + {15'd0, cnt, 2'd1}];
					iRamData_sig[23:16]	<= RAM[curPC + {15'd0, cnt, 2'd2}];
					iRamData_sig[31:24]	<= RAM[curPC + {15'd0, cnt, 2'd3}];
					
					cnt <= cnt + 3'd1;
					iRamAck_sig <= 1'b1;
					if (cnt == 3'd7)
						state <= 2'd3;
				end
		2'd3:	begin
					state <= 2'd0;
				end
	endcase
end

endmodule
