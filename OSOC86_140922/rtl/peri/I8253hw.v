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



module I8253
	(
		input						iClk,
		input						iRst,
		
		input				[1:0]	iRW,
		input				[1:0]	iAdr,
		input				[7:0]	iData,

		output	reg	[7:0]	oData,
		output	reg			oAck,

		input						GATE0,
		input						GATE1,
		input						GATE2,

		output	reg			OUT0,
		output	reg			OUT1,
		output	reg			OUT2
	);

	reg	[15:0]	VAL[0:2];
	reg	[15:0]	CNT[0:2];
	reg	[5:0]		CTRL[0:2];
	reg	[15:0]	LAT[0:2];
	reg				ACT[0:2];

	reg				flipr[0:2];   //??? original chip seems to use same flipflop for read/write
	reg				flipw[0:2];

	reg	[1:0]		IND;
	
	//reg	[6:0]		clkcnt;
	
	integer i;
	initial
	begin
		for (i = 0; i < 3; i=i+1)
		begin
			VAL[i] = 16'b0;
			CNT[i] = 16'b0;
			CTRL[i] = 6'b0;
			LAT[i] = 16'b0;
			ACT[i] = 1'b0;
			flipr[i] = 1'b0;
			flipw[i] = 1'b0;
		end
		ACT[0] = 1'b1;
		
		//clkcnt = 7'd0;
		oData = 8'd0;
		oAck = 1'b0;
		OUT0 = 1'b0;
		OUT1 = 1'b0;
		OUT2 = 1'b0;
	end

	integer j;
	always @(posedge iClk)
	begin			
			OUT0 <= 1'b0;
			OUT1 <= 1'b0;
			OUT2 <= 1'b0;
			for (j=0; j<3; j=j+1)
			begin
				if (ACT[j] == 1'b1)
				begin
					CNT[j] <= CNT[j] - 16'b1;
				end

			end
			
			if ((ACT[0] == 1'b1) && (CNT[0] == 16'b1))
				OUT0 <= 1'b1;
			//if ((ACT[1] == 1'b1) && (CNT[1] == 16'b1))
			//	OUT1 <= 1'b1;
			//if ((ACT[2] == 1'b1) && (CNT[2] == 16'b1))
			//	OUT2 <= 1'b1;
				
			//end
		
		//end

		oAck <= 1'b0;
		if (iRW[1] == 1'b1)
		begin
			case (iAdr)

				2'd0,
				2'd1,
				2'd2:	begin
						IND = iAdr[1:0];
						if (flipr[IND] == 0)
							oData <= LAT[IND][7:0];
						else
							oData <= LAT[IND][15:8];
						if (CTRL[IND][5:4] == 2'd3)
							flipr[IND] <= ~flipr[IND];
					end
				2'd3:	oData <= 8'hFF; //TODO: check what to do on invalid adr

			endcase
			oAck <= 1'b1;
	    end

	    if (iRW[0] == 1'b1)
	    begin
			case (iAdr)

				2'd0,
				2'd1,
				2'd2:	begin
						IND = iAdr[1:0];
						if (flipw[IND] == 0)
							CNT[IND][7:0] <= iData;
						else
							CNT[IND][15:8] <= iData;
						if (CTRL[IND][5:4] == 2'd3)
							flipw[IND] <= ~flipw[IND];
						ACT[IND] <= 1'b1;
					end

				2'd3:	begin
						IND = iData[7:6];
						CTRL[IND] <= iData[5:0];
						case (iData[5:4])

							2'd0:	LAT[IND] <= CNT[IND];

							2'd1:	begin
										flipr[IND] <= 1'b1;
										flipw[IND] <= 1'b1;
									end
							2'd2,
							2'd3:	begin
										flipr[IND] <= 1'b0;
										flipw[IND] <= 1'b0;
									end
						endcase
					end
			endcase
		end

	end

endmodule

