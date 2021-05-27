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


module IBufRAM
	(
		input [31:0] data,
		input [3:0] write_addr,
		input we,
		input [2:0] read_addr,
		input clk,
		output reg [63:0] q
	);

reg [31:0] ram[0:15];
reg [63:0] out_data;

always @ (posedge clk)
begin
	if (we)
		ram[write_addr] <= data;
	
	out_data = {ram[{read_addr, 1'b1}], ram[{read_addr, 1'b0}]};
	q <= out_data;
end

endmodule
