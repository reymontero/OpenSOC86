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


module CtrlSplit
	(
		input				[63:0]	Inst1,
		input				[63:0]	Inst2,
		input				[63:0]	Inst3,
		input				[63:0]	Inst4,
		
		input				[63:0]	Ctrl1,
		input				[63:0]	Ctrl2,
		input				[63:0]	Ctrl3,
		input				[63:0]	Ctrl4,
		
		//input							iAct,
		
		//input			[2:0]		iRF_used,
		//input			[1:0]		iRF_step,
		
		input							iCXzero,
		input							iCurZero,
		
		output		[2:0]		EX_SelIn1,
		output		[2:0]		EX_SelIn2,
		output		[2:0]		EX_Exec,
		output		[3:0]		EX_Func,
		output					EX_BW,
		output					EX_ESel,
		output		[3:0]		EX_SelOut,
		
		output		[1:0]		FC_FBW,
		output		[4:0]		FC_FSel,
		
		output					RH_PLine,
		output					RH_wr,
		output		[1:0]		RH_bwsW,
		output		[3:0]		RH_adrW,
		
		output		[1:0]		RF_bwsR0,
		output		[3:0]		RF_adrR0,
		output		[1:0]		RF_bwsR1,
		output		[3:0]		RF_adrR1,
		output					RF_wr,
		output		[1:0]		RF_bwsW,
		output		[3:0]		RF_adrW,
		output		[2:0]		RF_used,
		output		[1:0]		RF_step,
		
		//output		[2:0]		RF_RM,
		
		output		[15:0]	EX_Imm1,
		output		[15:0]	EX_Imm2,
		
		output		[1:0]		MM_RdWr,
		
		output		[1:0]		EA_MOD_Rd,
		output		[2:0]		EA_RM_Rd,
		output		[15:0]	EA_Imm_Rd,
		output		[15:0]	MM_Imm_Rd,
		output		[1:0]		MM_setSeg_Rd,
		output					MM_segOR_Rd,
		output		[2:0]		MM_Sel_Rd,
		output		[1:0]		MM_BW_Rd,
		
		output		[1:0]		EA_MOD_Wr,
		output		[2:0]		EA_RM_Wr,
		output		[15:0]	EA_Imm_Wr,
		output		[15:0]	MM_Imm_Wr,
		output		[1:0]		MM_setSeg_Wr,
		output					MM_segOR_Wr,
		output		[2:0]		MM_Sel_Wr,
		output		[1:0]		MM_BW_Wr,
		
		output					CXzero
		
		//output					hackAB
	);
	
//assign hackAB = (Inst1[7:0] == 8'hAB) ? 1'b1 : 1'b0;

assign RF_used = Inst1[50:48]; //iRF_used;
assign RF_step = Inst1[63:62]; //iRF_step;

assign RF_adrR0 = Ctrl1[57:54];
assign RF_adrR1 = Ctrl1[53:50];
assign RF_bwsR0 = Ctrl1[49:48];
assign RF_bwsR1 = Ctrl1[47:46];

//assign Ctrl1[45] = oLDM;
//assign Ctrl1[44:42] = oLDMT;
//assign Ctrl1[41:39] = oLDMBW;

assign EX_SelIn1 = Ctrl3[38:36];
assign EX_SelIn2 = Ctrl3[35:33];
assign EX_Exec = Ctrl3[32:30];
assign EX_Func = Ctrl3[29:25];
assign {EX_ESel, EX_BW} = Ctrl3[24:22];
assign EX_SelOut = Ctrl4[21:18];

assign FC_FBW = Ctrl4[17:16];
assign FC_FSel = Ctrl4[15:11];

assign RH_PLine = Inst1[60] & Inst1[61]; //iAct;

assign RH_wr = Ctrl1[60];
assign RH_bwsW = Ctrl1[6:5];
assign RH_adrW = Ctrl1[10:7];

assign RF_wr = Ctrl4[60];
assign RF_adrW = Ctrl4[10:7];
assign RF_bwsW = Ctrl4[6:5];

//assign RF_RM = Inst1[10:8];

//assign EA_MOD = Inst1[15:14];
//assign EA_RM = Inst1[10:8];

assign EX_Imm1 = Inst3[31:16];
assign EX_Imm2 = Inst3[47:32];
//assign MM_ImmRd = Inst1[47:32];
//assign MM_ImmWr = Inst3[47:32];

////assign Ctrl1[1:0] = oSTRM;
//assign Ctrl1[4:2] = oDST_M;
//assign Ctrl1[1:0] = oSTBW_M;

//assign MM_Sel = Ctrl4[4:2] | Ctrl2[44:42];
//assign MM_BW = Ctrl4[1:0] | Ctrl2[41:39];

//assign MM_setSeg = 2'd3;
//assign MM_segOR = 1'b0;

assign MM_RdWr = {Ctrl2[59], Ctrl4[58]};

assign EA_MOD_Rd = Inst1[15:14];
assign EA_RM_Rd = Inst1[10:8];
assign EA_Imm_Rd = Inst1[47:32];
assign MM_Imm_Rd = Inst2[47:32];
assign MM_setSeg_Rd = (Ctrl1[61]) ? Ctrl1[63:62] : 2'd3;
assign MM_segOR_Rd = Ctrl1[61];
assign MM_Sel_Rd = Ctrl2[44:42];
assign MM_BW_Rd = Ctrl2[41:39];

assign EA_MOD_Wr = Inst3[15:14];
assign EA_RM_Wr = Inst3[10:8];
assign EA_Imm_Wr = Inst3[47:32];
assign MM_Imm_Wr = Inst4[47:32];
assign MM_setSeg_Wr = (Ctrl3[61]) ? Ctrl3[63:62] : 2'd3;
assign MM_segOR_Wr = Ctrl3[61];
assign MM_Sel_Wr = Ctrl4[4:2];
assign MM_BW_Wr = Ctrl4[1:0];


assign CXzero = ((RF_wr == 1'b1) && (RF_adrW == 4'd1) && (RF_bwsW == 2'd01)) ? iCurZero : iCXzero;	//TODO: may go wrong when only CL or CH written


endmodule
