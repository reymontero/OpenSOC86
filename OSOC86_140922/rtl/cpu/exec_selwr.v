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


module exec_selwr
	(
		input							iClk,
		
		input				[2:0]		iExec,
		input				[3:0]		iFunc,
		input							iBW,
		input							Sgn,
		
		input				[3:0]		iSelOut,
		
		
		input				[16:0]	result,
		input				[15:0]	mulOut,
		input				[15:0]	mulOutHi,
		input				[15:0]	shf_out,
		input							shf_c,
		input							shf_o,
		input				[15:0]	outAX,
		input							outcf,
		input							outaf,
		input				[15:0]	divOut,
		input				[15:0]	indata,
		input				[15:0]	out_cbwd,
		
		input				[15:0]	R1,
		input				[15:0]	R2,
		input				[15:0]	iMem,
		input				[15:0]	iEA,
		
		output	reg	[15:0]	oR1,
		output	reg	[15:0]	oR2,
		output	reg	[16:0]	oALU,
		
		output	reg	[15:0]	oSHF,
		output	reg				oShfCF,
		output	reg				oShfOF,
		
		output	reg	[15:0]	oMUL,
		output						oMulF,
		
		output	reg	[15:0]	oADJ,
		output	reg				oAdjCF,
		output	reg				oAdjAF,
		
		output		[15:0]	OutR,
		output					isZero
	);



reg [15:0] dly_result;
reg [15:0] dly_outAX;
reg [15:0] dly_shf_out;
reg [15:0] dly_mulOut;
reg [15:0] cur_mulOutHi;
reg [15:0] dly_mulOutHi;
reg [15:0] dly_iMem;
reg [15:0] dly_indata;
reg [15:0] dly_EA;
reg [15:0] dly_cbwd;

//reg [2:0] dly_SelOut;
reg [2:0] dly_Exec;
reg [3:0] dly_Func;

reg dly_BW;
reg dly_Sgn;

always @(posedge iClk)
begin
//	case (iSelOut)
//		0:		OutR <= result[15:0];    //alu
//		1:		OutR <= iMem;     		//mem
//		2:		OutR <= mulOut1; // mlt_val_l;		//mul
//		3:		OutR <= mulOut2; //mlt_val_h;    //muh
//		4:		OutR <= 0; //div_val_l;    //div
//		5:		OutR <= 0; //div_val_h;    //dih
//		6:		OutR <= 0; //EA;      		//EA
//		7:		OutR <= outAX; //adj_val;		//adj AL
//		8:		OutR <= 0; //INP;     		//inp
//		9:		OutR <= 0;       		//adj AH
//		10:	OutR <= shf_out; 		//shf
//	endcase

	dly_result <= result[15:0];
	dly_outAX <= outAX;
	dly_shf_out <= shf_out;
	dly_mulOut <= mulOut;
	cur_mulOutHi <= mulOutHi;
	if ((dly_Exec == 3'd4) && (dly_Func[0] == 1'b0))
		dly_mulOutHi <= cur_mulOutHi;
	dly_iMem <= iMem;
	dly_indata <= indata;
	dly_EA <= iEA;
	dly_cbwd <= out_cbwd;
	
	//dly_SelOut <= iSelOut[2:0];
	dly_Exec <= iExec;
	dly_Func <= iFunc;
	
	if (iExec == 3'd4)
	begin
		dly_BW <= iBW;
		dly_Sgn <= Sgn;
	end
end

reg [15:0] tOutR;
assign OutR = tOutR;

reg tIsZero;
assign isZero = tIsZero;

//reg HiWnzero;
//reg HiBnzero;
reg mulflag;
assign oMulF = mulflag;

always @(*)
begin
	case (iSelOut[2:0])
		0:		tOutR = dly_result[15:0];
		1:		tOutR = dly_outAX;
		2:		tOutR = dly_shf_out;
		3:		tOutR = (dly_Func[0] == 1'b0) ? dly_mulOut : dly_mulOutHi;
		4:		tOutR = divOut;
		5:		tOutR = dly_indata;
		6:		tOutR = dly_EA;
		7:		tOutR = dly_cbwd;
	endcase
	tIsZero = (tOutR == 16'd0) ? 1'b1 : 1'b0;
	
	
	//HiWnzero = |dly_mulOutHi[15:0];
	//HiBnzero = |dly_mulOut[15:8];
	mulflag = 1'b0;
	case ({dly_BW, dly_Sgn})
//		2'b00:	mulflag = HiBnzero;
//		2'b01:	mulflag = HiBnzero ^ dly_mulOut[7];
//		2'b10:	mulflag = HiWnzero;
//		2'b11:	mulflag = HiWnzero ^ dly_mulOut[15];
		2'b00:	if (dly_mulOut[15:8] != 8'b0)
						mulflag = 1'b1;
		2'b01:	if (dly_mulOut[15:8] != {8{dly_mulOut[7]}})
						mulflag = 1'b1;
		2'b10:	if (cur_mulOutHi != 16'b0)
						mulflag = 1'b1;
		2'b11:	if (cur_mulOutHi != {16{dly_mulOut[15]}})
						mulflag = 1'b1;
	endcase
end

always @(posedge iClk)
begin
		//oFBW <= iFBW;
		//oFSel <= iFSel;
		
		oR1 <= R1;
		oR2 <= R2;
		oALU <= result;
		
		oSHF <= shf_out;
		oShfCF <= shf_c;
		oShfOF <= shf_o;
		
		oMUL <= mulOut;
		//oMulF <= mulflag;
		
		oADJ <= outAX;
		oAdjCF <= outcf;
		oAdjAF <= outaf;
end

endmodule
