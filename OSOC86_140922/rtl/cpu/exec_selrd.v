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


module exec_selrd
	(
		input				[2:0]		iSelIn1,
		input				[2:0]		iSelIn2,
		
		input				[15:0]	iRF1,
		input				[15:0]	iRF2,
		input				[15:0]	iMem,
		input				[15:0]	iImm1,
		input				[15:0]	iImm2,
		
		output			[15:0]	oR1,
		output			[15:0]	oR2
	);


//wire iCarry = f_carry;

reg [15:0] R1;
reg [15:0] R2;

assign oR1 = R1;
assign oR2 = R2;

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

endmodule
