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


module exec
	(
		input							iClk,
		
		input				[2:0]		iSelIn1,
		input				[2:0]		iSelIn2,
		
		input				[2:0]		iExec,
		input				[3:0]		iFunc,
		input							iBW,
		input							iESel,
		
		input				[3:0]		iSelOut,
		//input				[1:0]		iFBW,
		//input				[4:0]		iFSel,
		
		input				[15:0]	iRF1,
		input				[15:0]	iRF2,
		input				[15:0]	iDX,
		input				[15:0]	iMem,
		input				[15:0]	iImm1,
		input				[15:0]	iImm2,
		input				[15:0]	iEA,
		
		input			    			iCarry,
		input							iAux,
		
		input							iStall,
		
		//output	reg	[1:0]		oFBW,
		//output	reg	[4:0]		oFSel,
		
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
		output					isZero,
		
		output	reg				oStallD,
		output	reg				oDivErr
	);


//wire iCarry = f_carry;

reg [15:0] R1;
reg [15:0] R2;

always @(*)
begin
	case (iSelIn1[1:0])
      0:	R1 = iRF1;
      1:	R1 = iMem;
      2:	R1 = iImm2;
      3:	R1 = 16'd2;
      //4:	R1 = (iRF1[7] == 1'b1) ? 16'h00FF : 16'h0000;
      //5:	R1 = 16'd0;
		//6:	R1 = 16'd0;
		//7:	R1 = 16'd0;
	endcase

	case (iSelIn2[1:0])
		0:	R2 = iRF2;
      1:	R2 = iMem;
      2:	R2 = iImm1;
      3:	R2 = 16'd2;
      //4:	R2 = (iRF2[15] == 1'b1) ? 16'hFFFF : 16'h0000;
      //5:	R2 = 16'd0;
      //6:	R2 = 16'd0;
      //7:	R2 = 16'd0;
	endcase
end

reg [16:0] result;

wire sub = iFunc[0];
wire withc = iFunc[1] & ~iFunc[2];
wire AorL = (iFunc[2:0] == 3'b001) | (iFunc[2:0] == 3'b100) | (iFunc[2:0] == 3'b110) | iFunc[3];

wire [15:0] tR1 = R1;
wire [15:0] tR2 = (sub == 1'b0) ? R2 : ~R2;
wire tC = sub ^ (iCarry & withc);

reg	[15:0] lrslt;
reg	[17:0] arslt;

always @(*)
begin
	case (iFunc[1:0])
		2'd0:	lrslt = R1 & R2;
		2'd1:	lrslt = R1 | R2;
		2'd2:	lrslt = R1 ^ R2;
		2'd3:	lrslt = R1 & R2;
	endcase
	
	arslt = {1'b0, tR1, tC} + {1'b0, tR2, tC};
	
	//if (iFunc[3] == 1'b0)
	//begin
		if (AorL == 1'b0)
			result = {(arslt[17] ^ sub), arslt[16:1]};
		else if (iFunc[3] == 1'b0)
			result = {1'b0, lrslt};
	 else begin
		case (iFunc[2:0])
			3'b000:	result = {1'b0, R1} + 17'b1;
			3'b001:	result = {1'b0, R1} - 17'b1;
			3'b010:	result = {1'b0, ~R1};
			3'b011:	result = {1'b1, ~R1} + 17'b1;
			3'b100:	result = {1'b0, R1} & {1'b0, R2};
			3'b101:	result = {1'b0, R1};
			3'b110:	result = {1'b0, R2};
			3'b111:	result = {1'b0, R2} << 2;
		endcase
	end
end


reg [31:0] mlt1;
reg [31:0] mlt2;

reg [15:0] tmp1;
reg [15:0] tmp2;

wire Sgn = iESel;

reg [15:0] mulHi;

reg [15:0] mulOut;
reg [15:0] mulOutHi;
//reg mulflag;

//reg HiWnzero;
//reg HiBnzero;

//wire [31:0] mul_result;
//
//AltMultAdd	AltMultAdd_inst (
//	//.aclr0 ( aclr0_sig ),
//	//.clock0 ( iClk ),
//	.dataa_0 ( R1 ),
//	.datab_0 ( R2 ),
//	.signa ( Sgn ),
//	.signb ( Sgn ),
//	.result ( mul_result )
//	);

always @(*)
begin

//	if (Sgn)
//	begin
//		mlt1 = $signed(R1);
//		mlt2 = $signed(R2);
//	end else begin
//		mlt1 = $unsigned(R1);
//		mlt2 = $unsigned(R2);
//	end

	case ({iBW, Sgn})
		2'b00:	mlt1 = {24'b0, R1[7:0]};
		2'b01:	mlt1 = {{24{R1[7]}}, R1[7:0]};
		2'b10:	mlt1 = {16'b0, R1[15:0]};
		2'b11:	mlt1 = {{16{R1[15]}}, R1[15:0]};
	endcase
	
	case ({iBW, Sgn})
		2'b00:	mlt2 = {24'b0, R2[7:0]};
		2'b01:	mlt2 = {{24{R2[7]}}, R2[7:0]};
		2'b10:	mlt2 = {16'b0, R2[15:0]};
		2'b11:	mlt2 = {{16{R2[15]}}, R2[15:0]};
	endcase
	
	{tmp2, tmp1} = mlt1 * mlt2;	//{mulOut2, mulOut1} = {tmp2, tmp1};
	//if (iFunc[0] == 1'b0)
		mulOut = tmp1;
	//else
	//	mulOut = mulHi;
	mulOutHi = tmp2;
	
	
	
	
//	HiWnzero = |tmp2[15:0];
//	HiBnzero = |tmp1[15:8];
	
	//mulflag = 1'b0;
//	case ({iBW, Sgn})
//		2'b00:	mulflag = HiBnzero;
//		2'b01:	mulflag = HiBnzero ^ tmp1[7];
//		2'b10:	mulflag = HiWnzero;
//		2'b11:	mulflag = HiWnzero ^ tmp1[15];
//	endcase
end

//always @(posedge iClk)
//begin
//	if ((iExec == 3'd4) && (iFunc[0] == 1'b0))
//		mulHi <= tmp2;
//end

wire [15:0] iData = R1;
wire [4:0] iAmount = iRF2[4:0]; //R2[4:0];
wire iOneVar = iESel;

reg [4:0] mod9a;
reg [4:0] mod9b;
reg [4:0] mod9;

reg [4:0] mod17a;
reg [4:0] mod17b;
reg [4:0] mod17;

reg [4:0] val;

reg	[4:0]		cnt;

//reg	[15:0]	tmpl16;
//reg	[15:0]	tmpl8;
//reg	[15:0]	tmpl4;
//reg	[15:0]	tmpl2;
reg	[15:0]	tmpl1;

reg	[15:0]	dmyl;
reg	[15:0]	dmyr;

//reg	[15:0]	tmpr16;
//reg	[15:0]	tmpr8;
//reg	[15:0]	tmpr4;
//reg	[15:0]	tmpr2;
reg	[15:0]	tmpr1;

reg	[15:0]	shinl;
reg	[15:0]	shinr;

reg tcl;
reg tcr;

reg	[15:0]	databw;

reg [15:0] shf_out;
reg shf_c;
reg shf_o;

always @(*)
begin
	case (iAmount[3:0])
		0:  mod9a = 5'd0;
		1:  mod9a = 5'd1;
		2:  mod9a = 5'd2;
		3:  mod9a = 5'd3;
		4:  mod9a = 5'd4;
		5:  mod9a = 5'd5;
		6:  mod9a = 5'd6;
		7:  mod9a = 5'd7;
		8:  mod9a = 5'd8;
		9:  mod9a = 5'd0;
		10: mod9a = 5'd1;
		11: mod9a = 5'd2;
		12: mod9a = 5'd3;
		13: mod9a = 5'd4;
		14: mod9a = 5'd5;
		15: mod9a = 5'd6; 
	endcase
	case (iAmount[3:0])
		0:  mod9b = 5'd7;
		1:  mod9b = 5'd8;
		2:  mod9b = 5'd0;
		3:  mod9b = 5'd1;
		4:  mod9b = 5'd2;
		5:  mod9b = 5'd3;
		6:  mod9b = 5'd4;
		7:  mod9b = 5'd5;
		8:  mod9b = 5'd6;
		9:  mod9b = 5'd7;
		10: mod9b = 5'd8;
		11: mod9b = 5'd0;
		12: mod9b = 5'd1;
		13: mod9b = 5'd2;
		14: mod9b = 5'd3;
		15: mod9b = 5'd4; 
	endcase
	mod9 = (iAmount[4]) ? mod9b : mod9a;

	mod17a = iAmount[3:0]; 
	case (iAmount[3:0])
		0:  mod17b = 5'd16;
		1:  mod17b = 5'd0;
		2:  mod17b = 5'd1;
		3:  mod17b = 5'd2;
		4:  mod17b = 5'd3;
		5:  mod17b = 5'd4;
		6:  mod17b = 5'd5;
		7:  mod17b = 5'd6;
		8:  mod17b = 5'd7;
		9:  mod17b = 5'd8;
		10: mod17b = 5'd9;
		11: mod17b = 5'd10;
		12: mod17b = 5'd11;
		13: mod17b = 5'd12;
		14: mod17b = 5'd13;
		15: mod17b = 5'd14; 
	endcase
	mod17 = (iAmount[4]) ? mod17b : mod17a;
	
	case ({iBW, iFunc[2:0]})
		0:		val = {2'b0, iAmount[2:0]};			//rol
		1:		val = {2'b0, iAmount[2:0]};	//ror
		2:		val = mod9;						//rcl
		3:		val = mod9;				//rcr
		4:		val = {2'b0, iAmount[2:0]};			//shl
		5:		val = {2'b0, iAmount[2:0]};	//shr
		6:		val = {2'b0, iAmount[2:0]};			//sal
		7:		val = {2'b0, iAmount[2:0]};	//sar

		8:		val = {1'b0, iAmount[3:0]};			//rol
		9:		val = {1'b0, iAmount[3:0]};	//ror
		10:	val = mod17;								//rcl
		11:	val = mod17;						//rcr
		12:	val = {1'b0, iAmount[3:0]};			//shl
		13:	val = {1'b0, iAmount[3:0]};	//shr
		14:	val = {1'b0, iAmount[3:0]};			//sal
		15:	val = {1'b0, iAmount[3:0]};	//sar
	endcase
	
	//cnt = val; //(iFunc[1]) ? (5'd16 - iAmount) : iAmount;
	cnt = (iOneVar) ? val : 5'd1;
	
	databw = (iBW) ? iData : {iData[7:0], iData[7:0]};
	
	shinl = (iFunc[2]) ? 16'd0 : ((iFunc[1]) ? {iCarry, databw[15:1]} : databw);
	{tcl, tmpl1, dmyl} = {iCarry, databw, shinl} << cnt[3:0];
	
	shinr = (iFunc[2]) ? ((iFunc[1]) ? {16{databw[15]}} : 16'd0) : ((iFunc[1]) ? {databw[14:0], iCarry} : databw);
	{dmyr, tmpr1, tcr} = {shinr, databw, iCarry} >> cnt[3:0];
	
	case ({iBW, iFunc[0]})
		2'b00: shf_out = {8'd0, tmpl1[7:0]};
		2'b01: shf_out = {8'd0, tmpr1[15:8]};
		2'b10: shf_out = tmpl1;
		2'b11: shf_out = tmpr1;
	endcase
	//shf_out = (iFunc[0]) ? tmpr1 : tmpl1;
	
	case ({iBW, iFunc[0]})
		2'b00: shf_c = tmpl1[8];
		2'b01: shf_c = tmpr1[7];
		2'b10: shf_c = tcl;
		2'b11: shf_c = tcr;
	endcase
	
	case ({iBW, iFunc[2:0]})
		0:		shf_o = iData[7] ^ iData[6];		//rol
		1:		shf_o = iData[7] ^ iData[0];		//ror
		2:		shf_o = iData[7] ^ iData[6];		//rcl
		3:		shf_o = iData[7] ^ iCarry;			//rcr
		4:		shf_o = iData[7] ^ iData[6];		//shl
		5:		shf_o = iData[7];						//shr
		6:		shf_o = iData[7] ^ iData[6];		//sal
		7:		shf_o = 1'b0;							//sar

		8:		shf_o = iData[15] ^ iData[14];	//rol
		9:		shf_o = iData[15] ^ iData[0];		//ror
		10:	shf_o = iData[15] ^ iData[14];	//rcl
		11:	shf_o = iData[15] ^ iCarry;		//rcr
		12:	shf_o = iData[15] ^ iData[14];	//shl
		13:	shf_o = iData[15];					//shr
		14:	shf_o = iData[15] ^ iData[14];	//sal
		15:	shf_o = 1'b0;							//sar
	endcase
end

reg [15:0] outAX;
reg [7:0] tmpAL;
reg outaf;
reg outcf;

wire [15:0] AX = R1;
wire cf = iCarry;
wire af = iAux;

//wire [15:0] tmpM = {5'b0, AX[15:8], 3'd0} + {7'b0, AX[15:8], 1'd0} + {8'b0, AX[7:0]};

always @(*)
begin
	outcf = cf;
	outaf = af;
	tmpAL = AX[7:0];
	casex (iFunc[2:0])
		3'b000:	begin	//DAA
				outAX[15:8] = AX[15:8];
				if ((AX[3:0] > 4'd9) || (af == 1'b1))
				begin
					tmpAL = AX[7:0] + 8'd6;
					outaf = 1'b1;
				end else begin
					tmpAL = AX[7:0];
					outaf = 1'b0;
				end
				if ((AX[7:0] > 8'h99) || (cf == 1'b1))	//TODO: check >99 or 9F
				begin
					outAX[7:0] = tmpAL + 8'h60;
					outcf = 1'b1;
				end else begin
					outAX[7:0] = tmpAL;
					outcf = 1'b0;
				end
			end
		3'b001:	begin	//DAS
				outAX[15:8] = AX[15:8];
				if ((AX[3:0] > 4'd9) || (af == 1'b1))
				begin
					tmpAL = AX[7:0] - 8'd6;
					outaf = 1'b1;
				end else begin
					tmpAL = AX[7:0];
					outaf = 1'b0;
				end
				if ((AX[7:0] > 8'h99) || (cf == 1'b1))	//TODO: check >99 or 9F
				begin
					outAX[7:0] = tmpAL - 8'h60;
					outcf = 1'b1;
				end else begin
					outAX[7:0] = tmpAL;
					outcf = 1'b0;
				end
			end
		3'b010:	begin	//AAA
				if ((AX[3:0] > 4'd9) || (af == 1'b1))
				begin
					outAX[3:0] = AX[3:0] + 4'd6;
					outAX[7:4] = 4'd0;
					outAX[15:8] = AX[15:8] + 8'd1;
					outaf = 1'b1;
					outcf = 1'b1;
				end else begin
					outAX = {AX[15:8], 4'd0, AX[3:0]};
					outaf = 1'b0;
					outcf = 1'b0;
				end
			end
		3'b011:	begin	//AAS
				if ((AX[3:0] > 4'd9) || (af == 1'b1))
				begin
					outAX[3:0] = AX[3:0] - 4'd6;
					outAX[7:4] = 4'd0;
					outAX[15:8] = AX[15:8] - 8'd1;
					outaf = 1'b1;
					outcf = 1'b1;
				end else begin
					outAX = {AX[15:8], 4'd0, AX[3:0]};
					outaf = 1'b0;
					outcf = 1'b0;
				end
			end
		3'b10x:	begin	//AAM
				if (AX[7:0] > 8'd89)
					outAX = {4'd0, (AX[3:0] - 4'd10), 8'd9};
				if (AX[7:0] > 8'd79)
					outAX = {4'd0, (AX[3:0] - 4'd00), 8'd8};
				if (AX[7:0] > 8'd69)
					outAX = {4'd0, (AX[3:0] - 4'd06), 8'd7};
				if (AX[7:0] > 8'd59)
					outAX = {4'd0, (AX[3:0] - 4'd12), 8'd6};
				if (AX[7:0] > 8'd49)
					outAX = {4'd0, (AX[3:0] - 4'd02), 8'd5};
				if (AX[7:0] > 8'd39)
					outAX = {4'd0, (AX[3:0] - 4'd08), 8'd4};
				if (AX[7:0] > 8'd29)
					outAX = {4'd0, (AX[3:0] - 4'd14), 8'd3};
				if (AX[7:0] > 8'd19)
					outAX = {4'd0, (AX[3:0] - 4'd04), 8'd2};
				if (AX[7:0] > 8'd09)
					outAX = {4'd0, (AX[3:0] - 4'd10), 8'd1};
				else
					outAX = {4'd0, (AX[3:0] - 4'd00), 8'd0};
			end
		3'b11x:	begin	//AAD
				//tmpM = {5'b0, AX[15:8], 3'd0} + {7'b0, AX[15:8], 1'd0} + {8'b0, AX[7:0]};
				//outAX = {8'b0, tmpM[7:0]};
				outAX[7:0] = (R1[7:0] * R2[15:8]) + R2[7:0];
				outAX[15:8] = 8'd0;
			end
	endcase
end

//-------------------------------------------------------------------

wire [15:0] Quotient;
wire [15:0] Remain;
wire divAck;
wire divErr;

reg preReq;
wire divReq = ((iExec == 3'd5) && (iFunc[0] == 1'b0)) ? 1'b1 : 1'b0;

reg [15:0] divOut;
reg [15:0] divRem;
reg divBW;
reg divAAM;

Divider Divider_inst
(
	.iClk(iClk) ,	// input  iClk_sig
	.iStall(iStall) ,	// input  iStall_sig
	.iReq(divReq & ~preReq) ,	// input  iReq_sig
	.iSgn(iESel) ,	// input  iSgn_sig
	.iBW(iBW) ,	// input  iBW_sig
	.iNumer({iDX, R2}) ,	// input [31:0] iNumer_sig
	.iDenom(R1) ,	// input [15:0] iDenom_sig
	.oQuotient(Quotient) ,	// output [15:0] oQuotient_sig
	.oRemain(Remain) ,	// output [15:0] oRemain_sig
	.oAck(divAck) ,	// output  oAck_sig
	.oErr(divErr) 	// output  oErr_sig
);

initial
begin
	oStallD = 1'b0;
	preReq = 1'b0;
end

always @(posedge iClk)
begin
	preReq <= divReq & ~iStall;
	if (iExec == 3'd5)
	begin
		divBW <= iBW;
		divAAM <= iFunc[1];
	end
	if (divReq & ~preReq)
		oStallD <= 1'b1;	
	
	oDivErr <= 1'b0;
	if (divAck == 1'b1)
	begin
		oStallD <= 1'b0;
		if ((divAAM == 1'b1) && (divErr == 1'b0))
			divOut <= {Quotient[7:0], Remain[7:0]};
		else if ((divBW == 1'b0) && (divErr == 1'b0))
			divOut <= {Remain[7:0], Quotient[7:0]};
		else
			divOut <= Quotient;
		divRem <= Remain;
		oDivErr <= divErr;
	end
	if ((iExec == 3'd5) && (iFunc == 4'd1))
		divOut <= divRem;
end

//-------------------------------------------------------------------


reg [15:0] TMPIO;
wire [15:0] indata = TMPIO;

always @(posedge iClk)
begin
	//if (iExec == 3'd1)	//input
	//	indata = TMPIO;
	if (iExec == 3'd2)	//output
		TMPIO <= R1;
end


reg [15:0] out_cbwd;

always @(*)
begin
	case (iFunc[0])
		1'b0:	out_cbwd = (R1[7] == 1'b1) ? 16'h00FF : 16'h0000;
		1'b1:	out_cbwd = (R1[15] == 1'b1) ? 16'hFFFF : 16'h0000;
	endcase
end



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
