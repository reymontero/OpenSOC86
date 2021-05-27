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



module I8259
	(
		input						iClk,
		input						iRst,
		
		input				[1:0]	iRW,
		input						iA0,
		input				[7:0]	iData,

		input						iReq0,
		input						iReq1,
		input						iReq2,
		input						iReq3,
		input						iReq4,
		input						iReq5,
		input						iReq6,
		input						iReq7,
		//input				[7:0]	iReq,

		output	reg			oINT,
		output	reg	[7:0]	oINT_T,
		input						iAck,

		output	reg	[7:0]	oData,
		output	reg			oAck
	);

	wire [7:0] iReq = {iReq7, iReq6, iReq5, iReq4, iReq3, iReq2, iReq1, iReq0};
	
	reg	[1:0]	CState;

							// [  7	  6   5	  4	 3   2	 1   0]
	reg	[7:0]	ICW1;	// [ A7   A6  A5	  1 LTIM ADI SNGL IC4]
	reg	[7:0]	ICW2;	// [A15  A14 A13  A12  A11 A10   A9  A8] mcs80 mode
							// [ T7   T6  T5   T4   T3 A10   A9  A8] / 8086 mode
	reg	[7:0]	ICW3;	// [ S7   S6  S5   S4   S3  S2   S1  S0] master device
							// [  0	  0   0	  0	 0 ID2  ID1 ID0] / slave device
	reg	[7:0]	ICW4;	// [  0	  0   0 SFNM  BUF M/S AEOI uPM]

	reg	[7:0]	IMR;	// [ M7   M6  M5   M4   M3  M2   M1  M0] interrupt masks

	reg	[7:0]	OCW3;	// [  0 ESMM SMM	  0	 1   P   RR RIS]

	reg	[7:0]	IRR;	// [ R7   R6  R5   R4   R3  R2   R1  R0] interrupt request
	reg	[7:0]	ISR;	// [ S7   S6  S5   S4   S3  S2   S1  S0] interrupt service

	reg	[2:0]		PRI;
	reg	[15:0]	Ptmp;
	reg	[2:0]		IND;
	reg				SRV;
	reg	[2:0]		curIND;

	reg	[1:0]		state;

	initial
	begin
		CState = 2'b0;
		state = 2'b0;
		
		ICW1 = 8'h13; //8'd0;
		ICW2 = 8'h8; //8'd0;
		ICW3 = 8'h9; //8'd0;
		ICW4 = 8'd0;
		IMR = 8'b10111100; //8'd0;
		OCW3 = 8'd0;
		IRR = 8'd0;
		ISR = 8'd0;
		
		PRI = 3'd0;
		IND = 3'b0;
		SRV = 1'b0;
		
		oINT = 1'b0;
	end

	always @(posedge iClk)
	begin

		IRR <= IRR | iReq;

		Ptmp = (~{IMR, IMR} & {IRR, IRR}) >> PRI;

		casex (Ptmp[7:0])
			8'b00000000:	IND <= 3'd0;
			8'bxxxxxxx1:	IND <= 3'd0;
			8'bxxxxxx10:	IND <= 3'd1;
			8'bxxxxx100:	IND <= 3'd2;
			8'bxxxx1000:	IND <= 3'd3;
			8'bxxx10000:	IND <= 3'd4;
			8'bxx100000:	IND <= 3'd5;
			8'bx1000000:	IND <= 3'd6;
			8'b10000000:	IND <= 3'd7;
		endcase
		
		if (Ptmp == 16'd0)
			SRV <= 1'b0;
		else
			SRV <= 1'b1;

		oAck <= 1'b0;
		case (state)

			2'd0:	if (iAck == 1'b0)
					begin
						oINT <= SRV;
						oINT_T <= ICW2 + IND;
						if (SRV == 1'b1)
						begin
							IRR <= (IRR & ~(8'b1 << IND)); 
							curIND <= IND;
							state <= 2'd1;
						end
					end

			2'd1: if (iAck == 1'b1)
					begin
						oINT <= 1'b0;
						SRV <= 1'b0;
						IRR <= (IRR & ~(8'b1 << curIND));
						state <= 2'd0;
					end
			default: state <= 2'd0;
		endcase

		if (iRW[1] == 1'b1)	//read
		begin
			case (iA0)

				1'b0:	if (OCW3[0] == 1'b0)	//read IRR
							oData <= IRR;
						else			//read ISR
							oData <= ISR;

				1'b1:	oData <= IMR;

			endcase
			oAck <= 1;
		end

		if (iRW[0] == 1'b1)	//write
		begin
			case (iA0)

				1'b0:	case (iData[4:3])

							2'd0:	begin end			//OCW2

							2'd1:	OCW3 <= iData;					//OCW3

							2'd2,
							2'd3:	begin			//ICW1
										ICW1 <= iData;
										ICW2 <= 8'd0;
										ICW3 <= 8'd0;
										ICW4 <= 8'd0;
										IMR <= 8'd0;
										OCW3 <= 8'd0;
										IRR <= 8'd0;
										ISR <= 8'd0;

										CState <= 2'd0;
									end
						endcase
			
				1'b1:	case (CState)

							2'd0:	begin					//ICW2
										ICW2 <= iData;
										case (ICW1[1:0])	 //CHECK

											2'd0:	CState <= 2'd3; //no ICW3 nor ICW4

											2'd1:	CState <= 2'd2;	//no ICW3, get ICW4

											2'd2:	CState <= 2'd1; //get ICW3, no ICW4

											2'd3:	CState <= 2'd1; //get ICW3 and ICW4

										endcase
									end
							2'd1:	begin					//ICW3
										ICW3 <= iData;
										CState <= 2'd2 + ~ICW2[0];	//get ICW4?	 //CHECK
									end
							2'd2:	begin					//ICW4
										ICW4 <= iData;
										CState <= 2'd3;
									end
							2'd3:	begin						//OCW1
										IMR <= iData;
										CState <= 2'd3;
									end
						endcase

			endcase
		end

	end

endmodule

