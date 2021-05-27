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


module FlagCtrl
	(
		input				iClk,
		input				iRst,
		
		input			[1:0]	iFBW,
		input			[4:0]	iFSel,
		
		input						iShfCF,
		input						iShfOF,
		input						iMulF,
		input						iAdjCF,
		input						iAdjAF,
		
		input			[15:0]	iADJ,
		input			[16:0]	ALU,
		input			[15:0]	iMUL,
		input			[15:0]	R1,
		input			[15:0]	R2,
		input			[15:0]	iSHF,
		
		output	reg				f_carry,
		output	reg				f_interrupt,
		output	reg				f_direction,
		output	reg				f_overflow,
		output	reg				f_parity,
		output	reg				f_zero,
		output	reg				f_auxiliary,
		output	reg				f_signed,
		output	reg				f_trap,
		
		output			[15:0]	flgwrd
		
	);

initial
begin
	f_carry		= 1'b0;
	f_interrupt	= 1'b0;
	f_direction	= 1'b0;
	f_overflow	= 1'b0;
	f_parity		= 1'b0;
	f_zero		= 1'b0;
	f_auxiliary	= 1'b0;
	f_signed		= 1'b0;
	f_trap		= 1'b0;
end

assign flgwrd = {4'b1111, f_overflow, f_direction, f_interrupt, f_trap, f_signed, f_zero, 1'b0, f_auxiliary, 1'b0, f_parity, 1'b1, f_carry};

//wire [16:0] ALU = result;

always @(posedge iClk)
if (iRst == 1'b1)
begin
	f_carry		<= 1'b0;
	f_interrupt	<= 1'b0;
	f_direction	<= 1'b0;
	f_overflow	<= 1'b0;
	f_parity		<= 1'b0;
	f_zero		<= 1'b0;
	f_auxiliary	<= 1'b0;
	f_signed		<= 1'b0;
	f_trap		<= 1'b0;
end else begin
	case (iFSel)
		0,     //add
		2:     //adc
			if (iFBW == 1'b0)
			begin
				f_carry <= ALU[8];
				calczero8(ALU);
				calcsigned8(ALU);
				calcparity(ALU);
				calcoverflowadd8(ALU, R1, R2);
				calcauxiliary(ALU, R1, R2);

			end else begin

				f_carry <= ALU[16];
				calczero16(ALU);
				calcsigned16(ALU);
				calcparity(ALU);
				calcoverflowadd16(ALU, R1, R2);
				calcauxiliary(ALU, R1, R2);
			end

		3,     //ssb
		5,     //sub
		7:     //cmp
			if (iFBW == 1'b0)
			begin
				f_carry <= ALU[8];
				calczero8(ALU);
				calcsigned8(ALU);
				calcparity(ALU);
				calcoverflowsub8(ALU, R1, R2);
				calcauxiliary(ALU, R1, R2);

			end else begin

				f_carry <= ALU[16];
				calczero16(ALU);
				calcsigned16(ALU);
				calcparity(ALU);
				calcoverflowsub16(ALU, R1, R2);
				calcauxiliary(ALU, R1, R2);
			end
			
		11:    //neg
			if (iFBW == 1'b0)
			begin
				f_carry <= ALU[8];
				calczero8(ALU);
				calcsigned8(ALU);
				calcparity(ALU);
				//calcoverflowsub8(ALU, R1, R2);
				calcauxiliaryincdec(ALU, R1);
				f_overflow <= (ALU[7:0] == 8'h80) ? 1'b1 : 1'b0;
			end else begin

				f_carry <= ALU[16];
				calczero16(ALU);
				calcsigned16(ALU);
				calcparity(ALU);
				//calcoverflowsub16(ALU, R1, R2);
				calcauxiliaryincdec(ALU, R1);
				f_overflow <= (ALU[15:0] == 16'h8000) ? 1'b1 : 1'b0;
			end

		1,     //or
		4,     //and
		6,     //xor
		12:    //test
			if (iFBW == 1'b0)
			begin
				f_carry <= 1'b0;
				f_overflow <= 1'b0;
				f_zero <= (ALU[7:0] == 8'b0) ? 1'b1 : 1'b0;	//calczero8(ALU);
				f_signed <= (ALU[7] == 1'b1) ? 1'b1 : 1'b0;	//calcsigned8(ALU);
				calcparity(ALU);

			end else begin

				f_carry <= 1'b0;
				f_overflow <= 1'b0;
				f_zero <= (ALU[15:0] == 16'b0) ? 1'b1 : 1'b0;	//calczero16(ALU);
				f_signed <= (ALU[15] == 1'b1) ? 1'b1 : 1'b0;		//calcsigned16(ALU);
				calcparity(ALU);
			end

		8:     //inc
			if (iFBW == 1'b0)
			begin
				//f_carry <= ALU[8];
				calczero8(ALU);
				calcsigned8(ALU);
				calcparity(ALU);
				calcoverflowinc8(ALU, R1);
				calcauxiliaryincdec(ALU, R1);

			end else begin

				//f_carry <= ALU[16];
				calczero16(ALU);
				calcsigned16(ALU);
				calcparity(ALU);
				calcoverflowinc16(ALU, R1);
				calcauxiliaryincdec(ALU, R1);
			end

		9:     //dec
			if (iFBW == 1'b0)
			begin
				//f_carry <= ALU[8];
				calczero8(ALU);
				calcsigned8(ALU);
				calcparity(ALU);
				calcoverflowdec8(ALU, R1);
				calcauxiliaryincdec(ALU, R1);

			end else begin

				//f_carry <= ALU[16];
				calczero16(ALU);
				calcsigned16(ALU);
				calcparity(ALU);
				calcoverflowdec16(ALU, R1);
				calcauxiliaryincdec(ALU, R1);
			end

		10,    //not
		13,    //mov1
		14,    //mov2
		15:    //sl2/---
			begin end
		18: begin   //mul
				f_carry <= iMulF;
				f_overflow <= iMulF;
				if (iFBW == 1'b0)
				begin
					calczero8(iMUL);
					calcsigned8(iMUL);
					calcparity(iMUL);
				end else begin
					calczero16(iMUL);
					calcsigned16(iMUL);
					calcparity(iMUL);
				end
			end
		19: begin   //div
				//--- todo
			end
		20: begin   //adj
				f_carry <= iAdjCF;
				calczero8(iADJ);
				calcsigned8(iADJ);
				calcparity(iADJ);
				f_auxiliary <= iAdjAF;
			end
		21: begin	//shf/rot
				f_carry <= iShfCF;
				f_overflow <= iShfOF;
				if (iFBW == 1'b0)
				begin
					calczero8(iSHF);
					calcsigned8(iSHF);
					calcparity(iSHF);
				end else begin
					calczero16(iSHF);
					calcsigned16(iSHF);
					calcparity(iSHF);
				end
			end

		22:	f_carry <= ~f_carry;
		23:	f_carry <= 1'b0;
		24:	f_interrupt <= 1'b0;
		25:	f_direction <= 1'b0;
		26:	f_carry <= 1'b1;
		27:	f_interrupt <= 1'b1;
		28:	f_direction <= 1'b1;
		29:	begin	//half flags
					f_signed		<= ALU[7];
					f_zero		<= ALU[6];
					f_auxiliary	<= ALU[4];
					f_parity		<= ALU[2];
					f_carry		<= ALU[0];
				end
		30:	begin	//flags
					f_overflow	<= ALU[11];
					f_direction	<= ALU[10];
					f_interrupt	<= ALU[9];
					f_trap		<= ALU[8];
					f_signed		<= ALU[7];
					f_zero		<= ALU[6];
					f_auxiliary	<= ALU[4];
					f_parity		<= ALU[2];
					f_carry		<= ALU[0];
				end
		default: begin
				end
	endcase
end

task calczero8;
input	[15:0]	val;
begin
	f_zero <= (val[7:0] == 8'b0) ? 1'b1 : 1'b0;
end
endtask

task calczero16;
input	[15:0]	val;
begin
	f_zero <= (val[15:0] == 16'b0) ? 1'b1 : 1'b0;
end
endtask

task calcsigned8;
input	[15:0]	val;
begin
	f_signed <= (val[7] == 1'b1) ? 1'b1 : 1'b0;
end
endtask

task calcsigned16;
input	[15:0]	val;
begin
	f_signed <= (val[15] == 1'b1) ? 1'b1 : 1'b0;
end
endtask

task calcparity;
input	[15:0]	val;
begin
	f_parity <= ^~val[7:0];
end
endtask

//task calcparity16;
//input	[15:0]	val;
//begin
//	f_parity <= ^~val[15:0];
//end
//endtask

task calcoverflowadd8;
input	[15:0]	dst;
input	[15:0]	src1;
input	[15:0]	src2;
begin
	f_overflow <= (~src1[7] & ~src2[7] & dst[7]) | (src1[7] & src2[7] & ~dst[7]);
end
endtask

task calcoverflowadd16;
input	[15:0]	dst;
input	[15:0]	src1;
input	[15:0]	src2;
begin
	f_overflow <= (~src1[15] & ~src2[15] & dst[15]) | (src1[15] & src2[15] & ~dst[15]);
end
endtask

task calcoverflowinc8;
input	[15:0]	dst;
input	[15:0]	src1;
begin
	f_overflow <= (~src1[7] & dst[7]);
end
endtask

task calcoverflowinc16;
input	[15:0]	dst;
input	[15:0]	src1;
begin
	f_overflow <= (~src1[15] & dst[15]);
end
endtask

task calcauxiliary;
input	[15:0]	dst;
input	[15:0]	src1;
input	[15:0]	src2;
begin
	f_auxiliary <= (dst[4] ^ src1[4] ^ src2[4]);
end
endtask

task calcauxiliaryincdec;
input	[15:0]	dst;
input	[15:0]	src1;
begin
	f_auxiliary <= (dst[4] ^ src1[4]);
end
endtask

task calcoverflowsub8;
input	[15:0]	dst;
input	[15:0]	src1;
input	[15:0]	src2;
begin
	f_overflow <= (~src1[7] & src2[7] & dst[7]) | (src1[7] & ~src2[7] & ~dst[7]);
end
endtask

task calcoverflowsub16;
input	[15:0]	dst;
input	[15:0]	src1;
input	[15:0]	src2;
begin
	f_overflow <= (~src1[15] & src2[15] & dst[15]) | (src1[15] & ~src2[15] & ~dst[15]);
end
endtask

task calcoverflowdec8;
input	[15:0]	dst;
input	[15:0]	src1;
begin
	f_overflow <= (src1[7] & ~dst[7]);
end
endtask

task calcoverflowdec16;
input	[15:0]	dst;
input	[15:0]	src1;
begin
	f_overflow <= (src1[15] & ~dst[15]);
end
endtask


endmodule
