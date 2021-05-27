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


module FontROM
	(
		input [11:0] addr,
		input clk, 
		output reg [7:0] q
	);

reg [7:0] rom[0:4095];

initial
begin
	$readmemb("rom_font_bin.txt", rom);
end

always @ (posedge clk)
begin
	q <= rom[addr];
end

endmodule
