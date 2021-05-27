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


module exec_cbwd
	(
		input				[3:0]		iFunc,
		
		input				[15:0]	R1,
		
		output		[15:0]	oCBWD
	);


reg [15:0] out_cbwd;
assign oCBWD = out_cbwd;

always @(*)
begin
	case (iFunc[0])
		1'b0:	out_cbwd = (R1[7] == 1'b1) ? 16'h00FF : 16'h0000;
		1'b1:	out_cbwd = (R1[15] == 1'b1) ? 16'hFFFF : 16'h0000;
	endcase
end

endmodule
