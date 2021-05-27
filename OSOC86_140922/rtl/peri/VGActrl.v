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



module VGActrl
	(
		input							iClk_100M,
		input							iRst,
		
		output	reg				oVGA_HS,
		output	reg				oVGA_VS,
		output	reg				oVGA_SYNC,
		output	reg				oVGA_BLANK,
		output	reg				oVGA_CLOCK,
		output	reg	[9:0]		oVGA_R,
		output	reg	[9:0]		oVGA_G,
		output	reg	[9:0]		oVGA_B,
		
		output	reg	[18:0]	oRAMAdr,
		output	reg				oRamRd,
		input				[31:0]		iRAMData,
        input							iRAMAck,
		
		output			[11:0]	oFontAdr,
		input				[7:0]		iFontData
	);

//--- horizontal params ---
localparam	H_FRONT	= 16;
localparam	H_SYNC	= 96;
localparam	H_BACK	= 48;
localparam	H_ACT		= 640;
localparam	H_TOTAL	= 800;

//--- vertical params ---
localparam	V_FRONT	= 11;
localparam	V_SYNC	= 2;
localparam	V_BACK	= 31;
localparam	V_ACT		= 480;
localparam	V_TOTAL	= 524;

reg	[1:0]	ClkDly;

reg	[9:0]	HCnt;
reg	[9:0]	VCnt;

reg	[9:0]	pixX;
reg	[9:0]	pixY;
reg	[9:0]	curX;

reg	[1:0]	state;
reg	[9:0]	rdX;
reg	[9:0]	rdY;
reg	[15:0]	BUF[0:79];

//assign oFontAdr = {iRAMData, pixY[3:0]};
assign oFontAdr = {BUF[pixX[9:3]][7:0], pixY[3:0]};

integer i;
initial
begin
	pixX		= 10'b0;
	pixY		= 10'b0;
	curX		= 10'b0;
	HCnt		= 10'b0;
	VCnt		= 10'b0;
	ClkDly	= 2'b0;

oRAMAdr	= 19'd0;
oRamRd	= 1'b0;

for (i=0; i<80; i=i+1)
	BUF[i] = 16'd0;
end

always @(posedge iClk_100M)

if (iRst == 1'b1)
begin
	pixX			<= 10'b0;
	pixY			<= 10'b0;
	curX			<= 10'b0;
	HCnt			<= 10'b0;
	VCnt			<= 10'b0;
	ClkDly		<= 2'b0;
	
    oRAMAdr		<= 19'd0;
    oRamRd		<= 1'b0;

	//oFIFO_Req	<=	1'b0;
	//TextRAM_Wr	<= 1'b0;

end else begin

	oVGA_SYNC	<= 1'b1;
	
	//oFIFO_Req	<=	1'b0;
	//TextRAM_Wr	<=	1'b0;
	
	ClkDly		<= ClkDly + 2'b01;
	oVGA_CLOCK	<= ClkDly[1];
	
	oRamRd <= 1'b0;
	case (state)
		
		2'd0:	begin end
		2'd1:	begin
					oRAMAdr <= {10'b0, rdX[9:1]} + {8'b0, rdY[9:4], 5'b0} + {10'b0, rdY[9:4], 3'b0};
					oRamRd <= 1'b1;
					state <= 2'd2;
				end
		2'd2:	if (iRAMAck == 1'b1)
				begin 
					BUF[rdX] <= iRAMData[15:0];
					BUF[rdX + 7'd1] <= iRAMData[31:16];
				rdX <= rdX + 10'd2; 
					if (rdX == 10'd78)
						state <= 2'd0;
					else 
						state <= 2'd1;
					
				end

		2'd3:	state <= 2'd0;

	endcase
	
	case (ClkDly)

		2'b00: begin
					//oRAMAdr <= 20'hB0000 + pixX[9:3] + {pixY[9:4], 6'b0} + {pixY[9:4], 4'b0};  //TextRAM_Wr <= oFIFO_Req;
					//oRamRd <= 1'b1;
				end
		2'b01: begin end	//TextRAM
		2'b10: begin end	//CharROM
		2'b11: begin
					HCnt	<= HCnt + 10'b1;
					if (HCnt >= H_TOTAL-1)
					begin
						HCnt	<= 10'b0;
						VCnt	<= VCnt + 10'b1;
						if (VCnt >= V_TOTAL-1)
							VCnt	<= 10'b0;
					end
					
					if (HCnt < H_SYNC)
						oVGA_HS	<= 1'b0;
					else
						oVGA_HS	<= 1'b1;
					
					if (VCnt < V_SYNC)
						oVGA_VS	<= 1'b0;
					else
						oVGA_VS	<= 1'b1;
			
					if ((HCnt >= H_SYNC+H_BACK) && (HCnt < H_SYNC+H_BACK+H_ACT) &&
						 (VCnt >= V_SYNC+V_BACK) && (VCnt < V_SYNC+V_BACK+V_ACT))
					begin
						oVGA_BLANK	<= 1'b1;

					end else begin

						oVGA_BLANK	<= 1'b0;
					end
					
					//--- 
					
					if ((HCnt == H_SYNC+H_BACK - 8) &&
					(VCnt >= V_SYNC+V_BACK) && (VCnt < V_SYNC+V_BACK+V_ACT))
					begin
						rdX <= 10'd0;
						if (rdY[3:0] == 4'd0)
							state	<= 2'd1;
					end
					
					if ((HCnt == H_SYNC+H_BACK+H_ACT) && 
					(VCnt >= V_SYNC+V_BACK) && (VCnt < V_SYNC+V_BACK+V_ACT))
					begin
						rdY <= rdY + 10'd1;
					end
					
					if (VCnt < V_SYNC+V_BACK)
					begin
						rdX <= 10'd0;
						rdY <= 10'd0;
					end
					
					//--- 
					
					if ((HCnt >= H_SYNC+H_BACK-1) && (HCnt < H_SYNC+H_BACK+H_ACT-1) &&
						 (VCnt >= V_SYNC+V_BACK)   && (VCnt < V_SYNC+V_BACK+V_ACT))
					begin
						pixX <= pixX + 10'b1;
						curX <= pixX;
						//if ((pixX[2:0] == 3'b000) && (pixY[3:0] == 4'b0000) && (pixY < 10'd400))
						//	oFIFO_Req	<= 1'b1;

					end else begin

						pixX <= 10'b0;
					end
					
					if ((HCnt == H_SYNC+H_BACK+H_ACT) &&
						 (VCnt >= V_SYNC+V_BACK) && (VCnt < V_SYNC+V_BACK+V_ACT))
					begin
						pixY <= pixY + 10'b1;

					end else if (VCnt == V_SYNC+V_BACK+V_ACT)
						pixY <= 10'b0;
					
					if ((HCnt >= H_SYNC+H_BACK) && (HCnt < H_SYNC+H_BACK+H_ACT) &&
						 (VCnt >= V_SYNC+V_BACK) && (VCnt < V_SYNC+V_BACK+V_ACT) &&
					     (pixY < 10'd400))
					begin

						//oVGA_R <= {10{iFontData[3'd7-curX[2:0]]}};
						//oVGA_G <= {10{iFontData[3'd7-curX[2:0]]}};
						//oVGA_B <= {10{iFontData[3'd7-curX[2:0]]}};
						//oVGA_R <= {10{CurCharLine[3'd7-curX[2:0]]}};
						//oVGA_G <= {10{CurCharLine[3'd7-curX[2:0]]}};
						//oVGA_B <= {10{CurCharLine[3'd7-curX[2:0]]}};
						oVGA_R <= {10{iFontData[curX[2:0]]}};
						oVGA_G <= {10{iFontData[curX[2:0]]}};
						oVGA_B <= {10{iFontData[curX[2:0]]}};
					end else begin

						oVGA_R <= 10'b0;
						oVGA_G <= 10'b0;
						oVGA_B <= 10'b0;
					end
				end
	endcase
end

endmodule

