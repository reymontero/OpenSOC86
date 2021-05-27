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


module exec_alu
	(
		input				[3:0]		iFunc,

		input				[15:0]	R1,
		input				[15:0]	R2,
		
		input			    			iCarry,
		
		output		[16:0]	oResult
	);

reg [16:0] result;
assign oResult = result;

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

endmodule
