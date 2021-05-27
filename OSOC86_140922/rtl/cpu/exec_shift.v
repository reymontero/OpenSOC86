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


module exec_shift
	(
		input				[3:0]		iFunc,
		
		input							iBW,
		input							iESel,
		
		input				[15:0]	R1,
		input				[15:0]	iRF2,
		
		input			    			iCarry,
		
		output		[15:0]	oShf_out,
		output					oShf_c,
		output					oShf_o
	);




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

assign oShf_out = shf_out;
assign oShf_c = shf_c;
assign oShf_o = shf_o;

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



endmodule
