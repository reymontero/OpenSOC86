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


module exec_mult
	(
		input							iBW,
		input							iESel,
		
		input				[15:0]	R1,
		input				[15:0]	R2,
		
		output			[15:0]	oMulOut,
		output			[15:0]	oMulOutHi
	);

reg [31:0] mlt1;
reg [31:0] mlt2;

reg [15:0] tmp1;
reg [15:0] tmp2;

wire Sgn = iESel;

reg [15:0] mulHi;

reg [15:0] mulOut;
reg [15:0] mulOutHi;

assign oMulOut = mulOut;
assign oMulOutHi = mulOutHi;

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

endmodule
