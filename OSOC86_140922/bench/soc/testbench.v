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


reg  iRamAck_sig;
reg [31:0] iRamData_sig;

reg  iSR_Ack_sig;
reg  iDR_Ack_sig;
reg  iDR_Busy_sig;
reg [31:0] iDR_Data_sig;
reg [31:0] iSR_Data_sig;

reg  iVGA_RAMAck_sig;
reg [31:0] iVGA_RAMData_sig;

reg  iFloppyAck_sig;

initial
begin
	iRamAck_sig = 1'b0;
	iRamData_sig = 32'd0;
	
	iSR_Ack_sig = 1'b0;
	iDR_Ack_sig = 1'b0;
	iDR_Busy_sig = 1'b0;
	iDR_Data_sig = 32'd0;
	iSR_Data_sig = 32'd0;
	
	iVGA_RAMAck_sig = 1'b0;
	iVGA_RAMData_sig = 32'd0;
	iFloppyAck_sig = 1'b0;
end

wire  oHalted_sig;
wire  clk100_sig;
wire [63:0] cur_Inst_sig;
wire [207:0] DUMP_sig;
wire [15:0] oTmpOut_sig;

wire  oRamBW_sig;
wire [19:0] oRamAdr_sig;
wire [1:0] oRamBurst_sig;
wire [15:0] oRamData_sig;
wire [1:0] oRamRW_sig;

//wire  oDR_Stb_sig;
//wire  oDR_Wr_sig;
//wire [23:0] oDR_Adr_sig;
//wire [31:0] oDR_Data_sig;
//wire [1:0] oDR_Load_sig;
//wire [3:0] oDR_Mask_sig;
//
//wire [18:0] oSR_Adr_sig;
//wire [3:0] oSR_BE_sig;
//wire [31:0] oSR_Data_sig;
//wire [1:0] oSR_RW_sig;

wire  oVGA_RAMRd_sig;
wire  oVGA_HS_sig;
wire  oVGA_VS_sig;
wire  oVGA_SYNC_N_sig;
wire  oVGA_BLANK_N_sig;
wire  oVGA_CLOCK_sig;
wire [9:0] oVGA_B_sig;
wire [9:0] oVGA_G_sig;
wire [9:0] oVGA_R_sig;
wire [18:0] oVGA_RAMAdr_sig;

wire [23:0] oDMAAdr2_sig;
wire [15:0] oDMACnt2_sig;
wire [11:0] oFloppyLBA_sig;
wire [1:0] oFloppyRW_sig;


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

//---------------------------------------------------------------

reg	[7:0]		RAM[0:1048575];
reg	[7:0]		DISK[0:1474559];

reg	[1:0]		vga_state;

//reg	[4:0]		tmpID;
//reg	[1:104]	tmpStr;
//reg	[1:352]	memFile;

integer file;
integer file_vga;
integer file_mem;

integer i;
initial
begin
	for (i=0; i < 1048576; i=i+1)
		RAM[i] = 8'b0;
	
	file = $fopen("runlog.txt", "w");
	//$readmemh( "..\\..\\..\\..\\bin\\ramboot.hex", RAM, 0, 1048575);
	$readmemh( "..\\..\\..\\..\\bin\\pcxtbios.hex", RAM, 1040384, 1048575);
	$readmemh( "..\\..\\..\\..\\bin\\videorom.hex", RAM, 786432, 819199);
	//$readmemh( "C:\\Users\\Roy\\Documents\\Verilog\\pcxtbios.hex", bios_disk, 0, 8191);
	$readmemh( "..\\..\\..\\..\\bin\\dos-boot.hex", DISK, 0, 1474559);
	
	//--- vga ---
	file_vga = $fopen("vgalog.txt", "w");
	vga_state = 2'b00;
	
	//--- mem ---
	file_mem = $fopen("memlog.txt", "w");
end

//---------------------------------------------------------------

reg [15:0] curIP;
reg [15:0] curCS;

initial
begin
	curIP <= 16'h0000;
	curCS <= 16'h0000;
end

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
	
	curIP <= DUMP_sig[207:192];
	curCS <= DUMP_sig[47:32];
end

always @(posedge clk100_sig)
begin
	vga_state <= vga_state + 2'd1;
	if (vga_state == 2'b11)
		$fdisplay(file_vga, "%b", {oVGA_HS_sig, oVGA_VS_sig, oVGA_R_sig[9], oVGA_G_sig[9], oVGA_B_sig[9]});
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
		$fdisplay(file_mem, "W %h %h %h %h %b", curCS, curIP, oRamAdr_sig, oRamData_sig, oRamBW_sig);
	end
	
	if (oRamRW_sig[1] == 1'b1)
	begin
		iRamAck_sig <= 1'b1;
		if (oRamAdr_sig == 20'h00410)
		begin
			iRamData_sig[7:0] <= 8'h41;
			if (oRamBW_sig == 1'b1)
				iRamData_sig[15:8] <= 8'h42;
			else
				iRamData_sig[15:8] <= 8'd0;
		end else begin
			iRamData_sig[7:0] <= RAM[oRamAdr_sig];
			if (oRamBW_sig == 1'b1)
				iRamData_sig[15:8] <= RAM[oRamAdr_sig+20'd1];
			else
				iRamData_sig[15:8] <= 8'd0;
		end
		iRamData_sig[31:16] <= 16'd0;
		$fdisplay(file_mem, "R %h %h %h %h %b", curCS, curIP, oRamAdr_sig, {RAM[oRamAdr_sig+20'd1], RAM[oRamAdr_sig]}, oRamBW_sig);
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

always @(posedge clk100_sig)
begin
	iVGA_RAMAck_sig <= 1'b0;
	if (oVGA_RAMRd_sig == 1'b1)
	begin
		iVGA_RAMAck_sig <= 1'b1;
		iVGA_RAMData_sig <= {RAM[20'hB8000 + {oVGA_RAMAdr_sig, 2'd3}],
									RAM[20'hB8000 + {oVGA_RAMAdr_sig, 2'd2}],
									RAM[20'hB8000 + {oVGA_RAMAdr_sig, 2'd1}],
									RAM[20'hB8000 + {oVGA_RAMAdr_sig, 2'd0}]};
	end
end

reg [1:0] state_disk;
reg [19:0] disk_ramadr;
reg [20:0] disk_drvadr;
reg [15:0] disk_cnt;

initial
begin
	state_disk = 2'd0;
	disk_ramadr = 20'd0;
	disk_drvadr = 21'd0;
	disk_cnt = 16'd0;
end

always @(posedge clk100_sig)
begin
	iFloppyAck_sig <= 1'b0;
	
	case (state_disk)
		2'd0:	if (oFloppyRW_sig[1] == 1'b1)
				begin
					disk_ramadr <= oDMAAdr2_sig[19:0];
					disk_drvadr <= {oFloppyLBA_sig, 9'b0};
					disk_cnt <= oDMACnt2_sig;
					state_disk <= 2'd1;
				end
		2'd1:	begin
					RAM[disk_ramadr] <= DISK[disk_drvadr];
					disk_ramadr <= disk_ramadr + 20'd1;
					disk_drvadr <= disk_drvadr + 21'd1;
					disk_cnt <= disk_cnt - 16'd1;
					if (disk_cnt == 16'd0)
					begin
						state_disk <= 2'd0;
						iFloppyAck_sig <= 1'b1;
					end
				end
		2'd2:	state_disk <= 2'd0;
		2'd3:	state_disk <= 2'd0;
	endcase
end

endmodule
