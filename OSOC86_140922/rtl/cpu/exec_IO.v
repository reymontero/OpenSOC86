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


module exec_IO
	(
		input							iClk,
		
		input				[2:0]		iExec,
		
		//input				[15:0]	R1,
		//output	reg	[15:0]	oIO
		
		//input				[1:0]		RdWr,
		input							BW,
		
		input				[15:0]	iData,
		input				[15:0]	iAdr,
		
		output	reg	[15:0]	oData,
		output	reg				Stall,
		
		input				[7:0]		iData_8237,
		input							iAck_8237,
		output	reg	[1:0]		oBusRW_8237,
		output			[4:0]		oBusAdr_8237,
		
		input				[7:0]		iData_8253,
		input							iAck_8253,
		output	reg	[1:0]		oBusRW_8253,
		output			[1:0]		oBusAdr_8253,
		
		input				[7:0]		iData_8259,
		input							iAck_8259,
		output	reg	[1:0]		oBusRW_8259,
		output						oBusAdr_8259,
		
		input				[7:0]		iData_8272,
		input							iAck_8272,
		output	reg	[1:0]		oBusRW_8272,
		output			[1:0]		oBusAdr_8272,
		
		input				[7:0]		iData_video,
		input							iAck_video,
		output	reg	[1:0]		oBusRW_video,
		output			[6:0]		oBusAdr_video,
		
		input				[15:0]	iData_ext,
		input							iAck_ext,
		output	reg	[1:0]		oBusRW_ext,
		output	reg	[15:0]	oBusAdr16,
		output	reg	[15:0]	oBusData16,
		output			[7:0]		oBusData8
	);



//reg [15:0] TMPIO;
//wire [15:0] indata = oIO;

//always @(posedge iClk)
//begin
	//if (iExec == 3'd1)	//input
	//	indata = TMPIO;
//	if (iExec == 3'd2)	//output
//		oIO <= R1;
//end

wire	[1:0]		RdWr = {((iExec == 3'd1) ? 1'b1 : 1'b0), ((iExec == 3'd2) ? 1'b1 : 1'b0)};

reg state;

reg	[7:0]	X6X[0:7];

assign oBusAdr_8237 = {oBusAdr16[7], oBusAdr16[3:0]};
assign oBusAdr_8253 = oBusAdr16[1:0];
assign oBusAdr_8259 = oBusAdr16[0];
assign oBusAdr_8272 = oBusAdr16[1:0];
assign oBusAdr_video = oBusAdr16[6:0];

assign oBusData8 = oBusData16[7:0];

wire busAck = iAck_8237 | iAck_8253 | iAck_8259 | iAck_8272 | iAck_video | iAck_ext;
integer i;
initial
begin
	state = 1'b0;
	
	oData = 16'd0;
	Stall = 1'b0;
	
	oBusAdr16 = 16'd0;
	oBusData16 = 16'd0;

	for (i=0; i<8; i=i+1)
		X6X[i] = 8'd0;
end

always @(posedge iClk)
begin
	oBusRW_8237 <= 2'b00;
	oBusRW_8253 <= 2'b00;
	oBusRW_8259 <= 2'b00;
	oBusRW_8272 <= 2'b00;
	oBusRW_video <= 2'b00;
	oBusRW_ext <= 2'b00;

	case (state)

		1'b0:	begin
					oBusAdr16 <= iAdr;
					oBusData16 <= iData;
					
					if (RdWr[1] == 1'b1)
					begin
						Stall <= 1'b1;
						state <= 1'b1;
					end
				
					casex (iAdr)

						16'b00x000xxxx:	oBusRW_8237 <= RdWr;		//8237 dma		port 00x

						16'b00010000xx:	oBusRW_8253 <= RdWr;		//8253 timer	port 04x

						16'b000010000x:	oBusRW_8259 <= RdWr;		//8259 pic		port 02x
						16'b111011xxxx,									//     
						16'b111100xxxx,									//     
						16'b111101xxxx:	oBusRW_video <= RdWr;	//     video	port 3Bx - 3Dx

						16'b1111110xxx:	oBusRW_8272 <= RdWr;		//8272 floppy	port 3F0 - 3F7
					 //16'b1111111xxx:								//     mouse	port 3F8 - 3FF
						16'b0001100xxx:	begin

											if (RdWr[0] == 1'b1)
												X6X[iAdr[2:0]] <= iData[7:0];
											if (iAdr[2:0] == 3'b010)
												oData <= 8'h02;
											else
												oData <= {8'b0, X6X[iAdr[2:0]]};
											Stall <= 1'b0;
											state <= 1'b0;
										end
						default:		begin
											oBusRW_ext <= RdWr;
											//oData <= 8'hFF;
											//Stall <= 1'b0;
											//state <= 1'b0;
										end
					endcase
				end
		1'b1:	begin
					if (busAck == 1'b1)
					begin
						if (iAck_8237 == 1'b1)
							oData <= iData_8237;
						else if (iAck_8253 == 1'b1)
							oData <= iData_8253;
						else if (iAck_8259 == 1'b1)
							oData <= iData_8259;
						else if (iAck_8272 == 1'b1)
							oData <= iData_8272;
						else if (iAck_video == 1'b1)
							oData <= iData_video;
						else if (iAck_ext == 1'b1)
							oData <= iData_ext;
						
						Stall <= 1'b0;
						state <= 1'b0;
					end
				end
	endcase
end

endmodule
