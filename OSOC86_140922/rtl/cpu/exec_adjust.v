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


module exec_adjust
	(
		input				[3:0]		iFunc,
		
		input				[15:0]	R1,
		input				[15:0]	R2,
		
		input			    			iCarry,
		input							iAux,
		
		output		[15:0]	oOutAX,
		output					oOutCF,
		output					oOutAF
	);



reg [15:0] outAX;
reg [7:0] tmpAL;
reg outaf;
reg outcf;

assign oOutAX = outAX;
assign oOutCF = outcf;
assign oOutAF = outaf;

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

endmodule
