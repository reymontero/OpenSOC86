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


module Ctrl
	(
		input							iClk,
		input							iRst,
		
		output	reg				oNew,
		
		input				[7:0]		I_OP0,
		input				[7:0]		I_OP1,
		input				[15:0]	imm,
		input				[15:0]	offset,
		input				[2:0]		iUsed,
		input				[8:0]		iUCAdr,
		input							iPipeLine,
		input							iAck,
		
		input							Hazard,
		input							StallM,
		input							StallD,
		input							StallIO,
		input							iJumped,
		input							iDivErr,
		input							iInt,
		input				[7:0]		iInt_T,
		
		input				[15:0]	iFlags,
		input							CXzero,
		
		input				[63:0]	UC,
		
		output	reg	[63:0]	cur_Inst1 /* synthesis ramstyle = "logic" */,
		output	reg	[63:0]	cur_Inst2 /* synthesis ramstyle = "logic" */,
		output	reg	[63:0]	cur_Inst3 /* synthesis ramstyle = "logic" */,
		output	reg	[63:0]	cur_Inst4 /* synthesis ramstyle = "logic" */,
		
		output	reg	[63:0]	cur_Ctrl1 /* synthesis ramstyle = "logic" */,
		output	reg	[63:0]	cur_Ctrl2 /* synthesis ramstyle = "logic" */,
		output	reg	[63:0]	cur_Ctrl3 /* synthesis ramstyle = "logic" */,
		output	reg	[63:0]	cur_Ctrl4 /* synthesis ramstyle = "logic" */,
		
		output	reg				oHalted,
		output	reg				oAckInt,
		
		output			[8:0]		UCAdr
		
		//output						isRep
	);
	


wire	f_overflow	= iFlags[11];
wire	f_direction	= iFlags[10];
wire	f_interrupt	= iFlags[9];
wire	f_trap		= iFlags[8];
wire	f_signed		= iFlags[7];
wire	f_zero		= iFlags[6];
wire	f_auxiliary	= iFlags[4];
wire	f_parity		= iFlags[2];
wire	f_carry		= iFlags[0];

wire Stall = StallM | StallD | StallIO;

localparam inst_nop = 64'd0;
localparam ctrl_nop = {3'b0, 1'b0, 2'b0, 4'b0, 4'b0, 2'b0, 2'b0, 1'b0, 3'b0, 3'b0, 3'b0, 3'b0, 3'b0, 5'b0, 3'b0, 4'b0, 2'b0, 5'd15, 4'b0, 2'b0, 3'b0, 2'b0};

//											      60,  59:51, 50:48, 47:32, 31:16, 15:8, 7:0
wire	[63:0]	iInst = {3'b011, iPipeLine, iUCAdr, iUsed, offset, imm, I_OP1, I_OP0};

wire	[3:0]	iCON		= UC[59:56];

reg	[63:0]	nxt_Inst0;
reg	[63:0]	nxt_Inst1;
reg	[63:0]	nxt_Inst2;
reg	[63:0]	nxt_Inst3;

reg	[63:0]	nxt_Ctrl3;

assign UCAdr = nxt_Inst2[59:51];

wire NoneActive = ~(nxt_Inst1[61] | nxt_Inst2[61] | nxt_Inst3[61] | cur_Inst1[61] | cur_Inst2[61] | cur_Inst3[61] | cur_Inst4[61]);

reg	[1:0]	cur_Left;


reg			preHazard;
reg			preStall;
reg			HazardStall;


reg	[63:0]	buf_Inst[0:7];
reg	[63:0]	buf_Retire;

reg	[3:0]	buf_save;
reg	[3:0]	buf_req;
reg	[3:0]	new_save;
reg	[3:0]	new_req;
reg	[3:0]	tmp_save;

reg startNew;
reg startRep;
reg startInt;
wire reqNew = (buf_req < 4'd8) ? 1'b1 : 1'b0;

wire buf_PLine = buf_Inst[0][60];
reg		CurPLine;

reg DivInt;
reg ExtInt;
reg [7:0] ExtInt_T;

reg segOverride;
reg [1:0] segSelect;
reg curOverride;

wire [63:0] UCtrl;
wire			ConTrue;

reg		RepPrefix;
reg		curRepPrefix;
reg		RepNow;
reg		RepFlag;

//assign isRep = RepNow | RepPrefix | curRepPrefix;

UCDec UCDec_inst
(
	.iUC(UC),
	.cur_OP0(nxt_Inst3[7:0]), //cur_OP0[Exec]),
	.cur_OP1(nxt_Inst3[15:8]), //cur_OP1[Exec]),
	.segOverride(segOverride),
	.segSelect(segSelect),
	.iFlags(iFlags),
	.CXzero(CXzero),
	.RepPrefix(RepPrefix),
	.oUC(UCtrl),
	.oCond(ConTrue)
);

integer j;
initial
begin
	oNew = 1'b0;
	cur_Inst1 = inst_nop;
	cur_Inst2 = inst_nop;
	cur_Inst3 = inst_nop;
	cur_Inst4 = inst_nop;
	
	cur_Ctrl1 = ctrl_nop;
	cur_Ctrl2 = ctrl_nop;
	cur_Ctrl3 = ctrl_nop;
	cur_Ctrl4 = ctrl_nop;
	
	oHalted = 1'b0;
	oAckInt = 1'b0;
	
	nxt_Inst0 = inst_nop;
	nxt_Inst1 = inst_nop;
	nxt_Inst2 = inst_nop;
	nxt_Inst3 = inst_nop;
	
	nxt_Ctrl3 = 64'd0;
	
	cur_Left = 2'd0;
	
	preHazard = 1'b0;
	preStall = 1'b0;
	HazardStall = 1'b0;
	
	for (j=0; j<8; j=j+1)
		buf_Inst[j] = 64'd0;
	
	buf_save = 4'd0;
	buf_req = 4'd0;
	
	CurPLine = 1'b0;
	
	DivInt = 1'b0;
	ExtInt = 1'b0;
	
	segOverride = 1'b0;
	segSelect = 2'd0;
	curOverride = 1'b0;
	
	RepPrefix = 1'b0;
	curRepPrefix = 1'b0;
	RepNow = 4'd0;
	RepFlag = 1'b0;
end


integer i;
always @(posedge iClk)
if (iRst == 1'b1)
begin
	oNew <= 1'b0;
	cur_Inst1 <= inst_nop;
	cur_Inst2 <= inst_nop;
	cur_Inst3 <= inst_nop;
	cur_Inst4 <= inst_nop;
	
	cur_Ctrl1 <= ctrl_nop;
	cur_Ctrl2 <= ctrl_nop;
	cur_Ctrl3 <= ctrl_nop;
	cur_Ctrl4 <= ctrl_nop;
	
	oHalted <= 1'b0;
	oAckInt <= 1'b0;
	
	nxt_Inst0 <= inst_nop;
	nxt_Inst1 <= inst_nop;
	nxt_Inst2 <= inst_nop;
	nxt_Inst3 <= inst_nop;
	
	nxt_Ctrl3 <= 64'd0;
	
	//cur_Left <= 2'd0;
	
	preHazard <= 1'b0;
	preStall <= 1'b0;
	HazardStall <= 1'b0;
	
	for (i=0; i<8; i=i+1)
		buf_Inst[i] <= 64'd0;
	
	buf_save <= 4'd0;
	buf_req <= 4'd0;
	
	CurPLine <= 1'b0;
	
	segOverride <= 1'b0;
	segSelect <= 2'd0;
	curOverride <= 1'b0;
	
	RepPrefix <= 1'b0;
	curRepPrefix <= 1'b0;
	RepNow <= 1'b0;
	RepFlag <= 1'b0;
end else begin
	
	if (iDivErr == 1'b1)		//int flag???
		DivInt <= 1'b1;
	
	oAckInt <= 1'b0;
	if ((iInt == 1'b1) && (oAckInt == 1'b0) && (segOverride == 1'b0) && (curOverride == 1'b0))
	begin
		if (f_interrupt == 1'b1)
		begin
			ExtInt <= 1'b1;
			ExtInt_T <= iInt_T;
		end //else
			//oAckInt <= 1'b1;		//ack/reset anyway???
	end
	
	startNew = |buf_save & ~iJumped & ~nxt_Inst0[61];
	startNew = startNew & ((~Stall & ~preStall & ~HazardStall & ~Hazard & ~preHazard) & (NoneActive | (buf_PLine & CurPLine)));
	//startNew = startNew & ~reqHalt & ~(|RepNow); // & ~oHalted;
	startNew = startNew & ~oHalted;
	
	startRep = startNew & RepNow;
	startNew = startNew & ~RepNow;
	startInt = startNew & (DivInt | ExtInt) & ~(segOverride | curOverride);
	startNew = startNew & ((~DivInt & ~ExtInt) | segOverride | curOverride);
	
	preHazard <= Hazard;
	preStall <= Stall;
	
	if (preHazard & Stall)
		HazardStall <= 1'b1;
	else if (~preStall)
		HazardStall <= 1'b0;
	
	oNew <= (reqNew) ? 1'b1 : 1'b0;
	
	
	
	if (startNew)
		for (i=0; i<7; i=i+1)
			buf_Inst[i] <= buf_Inst[i+1];
	
	if (iAck)
	begin
		tmp_save = (startNew == 1'b0) ?  buf_save : buf_save - 4'd1;
		buf_Inst[tmp_save] <= iInst;
	end
	
	case ({reqNew, startNew})
		2'b00: new_req = buf_req;
		2'b01: new_req = buf_req - 4'd1;
		2'b10: new_req = buf_req + 4'd1;
		2'b11: new_req = buf_req;
	endcase
	buf_req <= new_req;
	
	case ({iAck, startNew})
		2'b00: new_save = buf_save;
		2'b01: new_save = buf_save - 4'd1;
		2'b10: new_save = buf_save + 4'd1;
		2'b11: new_save = buf_save;
	endcase
	buf_save <= new_save;
	
	
	
	if (startNew)
		CurPLine <= buf_PLine;
	
	
	
	
	if (~Hazard & ~Stall & ~preStall)
	begin
		if (startNew)
			buf_Retire <= {3'b001, buf_Inst[0][60:0]};
		
		if (startNew)
		begin
			if (curRepPrefix)
			begin
				RepPrefix <= 1'b0;
				curRepPrefix <= 1'b0;
			end else if (RepPrefix)
				curRepPrefix <= 1'b1;
			
			if (curOverride)
			begin
				segOverride <= 1'b0;
				curOverride <= 1'b0;
			end else if (segOverride)
				curOverride <= 1'b1;
		end
		
		//nxt_Inst1 <= (startNew) ? buf_Inst[0] : inst_nop;
		nxt_Inst0 <= inst_nop;
		//nxt_Inst1 <= (cur_Left == 2'd0) ? ((startNew) ? buf_Inst[0] : ((startRep) ? buf_Retire : nxt_Inst0)) : {3'b001, cur_Inst1[60], (cur_Inst1[59:51] + 9'd1), cur_Inst1[50:0]};
		
		casex ({cur_Left, startNew, startRep, startInt})
			5'b00000: nxt_Inst1 <= nxt_Inst0;
			5'b00x01: nxt_Inst1 <= {((ExtInt) ? 2'b01 : 2'b10), 2'b10, 9'h13C, 3'd0, 16'h0000, 8'h00, ((ExtInt) ? ExtInt_T : 8'h00), 16'hC0CD};
			5'b00x1x: nxt_Inst1 <= buf_Retire;
			5'b00100: nxt_Inst1 <= buf_Inst[0];
			5'b01xxx,
			5'b1xxxx: nxt_Inst1 <= {3'b001, cur_Inst1[60], (cur_Inst1[59:51] + 9'd1), cur_Inst1[50:0]};
		endcase
		
		if ((cur_Left == 2'd0) && (startRep == 1'b0) && (startInt == 1'b1) && (ExtInt == 1'b0))
			DivInt <= 1'b0;
		if ((cur_Left == 2'd0) && (startRep == 1'b0) && (startInt == 1'b1) && (ExtInt == 1'b1))
		begin
			oAckInt <= 1'b1;
			ExtInt <= 1'b0;
		end
		if ((cur_Left == 2'd0) && (startRep == 1'b1))
			RepNow <= 1'b0;
		
		//nxt_Inst2 <= (cur_Left == 2'd0) ? nxt_Inst1 : {3'b001, cur_Inst1[60], (cur_Inst1[59:51] + 9'd1), cur_Inst1[50:0]};
		nxt_Inst2 <= nxt_Inst1;
		{nxt_Inst3, nxt_Ctrl3} <= {nxt_Inst2, ctrl_nop};
		{cur_Inst1, cur_Ctrl1} <= {nxt_Inst3, ((preHazard) ? nxt_Ctrl3 : (nxt_Inst3[61] ? UCtrl : ctrl_nop))};
		{cur_Inst2, cur_Ctrl2} <= {2'b00, cur_Inst1[61:0], cur_Ctrl1};
		{cur_Inst3, cur_Ctrl3} <= {cur_Inst2, cur_Ctrl2};
		{cur_Inst4, cur_Ctrl4} <= {cur_Inst3, cur_Ctrl3};
		
		
		
		if (~ConTrue)
		begin
			cur_Ctrl1[60] <= 1'b0;			//oWrRF
			cur_Ctrl1[59:58] <= 2'b0;		//oRWMem
			cur_Ctrl1[32:30] <= 3'b0;		//oEXEC
			cur_Ctrl1[15:11] <= 5'd15;		//oFSEL
		end
		
		cur_Left <= 2'd0;
		
		if (nxt_Inst3[61])
		begin
			if (iCON == 4'd12)
			begin
				segOverride <= 1'b1;
				curRepPrefix <= 1'b0;
				curOverride <= 1'b0;
				segSelect <= nxt_Inst3[4:3];
			end
			if (iCON == 4'd13)
				oHalted <= 1'b1;
			
			if (iCON == 4'd3)
				RepNow <= RepPrefix & ~CXzero;
			if (iCON == 4'd10)
			begin
				RepPrefix <= 1'b1;
				curRepPrefix <= 1'b0;
				curOverride <= 1'b0;
				RepFlag <= nxt_Inst3[0];
			end
			if (iCON == 4'd11)
				RepNow <= (f_zero == RepFlag) ? (RepPrefix & ~CXzero) : 1'b0;
			
			cur_Left <= UC[61:60];
		end
		
	end else begin
		if ((Hazard | StallD) & ~preStall)
		begin
			nxt_Inst0 <= nxt_Inst1;
			nxt_Inst1 <= nxt_Inst2;
			nxt_Inst2 <= nxt_Inst3;
			{nxt_Inst3, nxt_Ctrl3} <= {2'b00, cur_Inst1[61:0], cur_Ctrl1};
		end
		
		if (Hazard)
		begin
			{cur_Inst1, cur_Ctrl1} <= {cur_Inst2, cur_Ctrl2};
			{cur_Inst2, cur_Ctrl2} <= {inst_nop, ctrl_nop};
			{cur_Inst3, cur_Ctrl3} <= {inst_nop, ctrl_nop};
			{cur_Inst4, cur_Ctrl4} <= {cur_Inst3, cur_Ctrl3};
		end
		else if (preHazard) // & ~HazardStall)
			{cur_Inst4, cur_Ctrl4} <= {inst_nop, ctrl_nop};
	end
	
	
//	if (nxt_Inst3[61])
//	begin
//		//CurPLine <= nxt_Inst3[60];
//		
//		if (iCON == 4'd13)
//			oHalted <= 1'b1;
//		
//		cur_Left <= UC[61:60];
//	end
	
	
	if (iJumped) // | reqHalt)
	begin
		buf_save <= 4'd0;
		buf_req <= 4'd0;
		oNew <= 1'b0;
		
	end
end

endmodule
