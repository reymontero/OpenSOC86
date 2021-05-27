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



module Video
	(
		input							iClk,
		
		input				[1:0]		iBusRW,
		input				[6:0]		iBusAdr,
		input				[7:0]		iBusData,
		
		output	reg	[7:0]		oBusData,
		output	reg				oBusAck
	);
	
					//read,write
reg	[7:0]	RMisc;		// 3CC, 3C2
reg	[7:0]	RStt0;		// 3C2, ---
reg	[7:0]	RStt1;		// 3?A, ---
reg	[7:0]	FCtrl;		// 3CA, 3?A
reg	[7:0]	VidEn;		// 3C3, 3C3

reg	[7:0]	indSeq;		// 3C4
reg	[7:0]	indCRTC;	// 3?4
reg	[7:0]	indGC;		// 3CE
reg	[7:0]	indAC;		// 3C0
reg			ffAC;

reg	[7:0]	Seq[0:7]; 	//5	// 3C5
reg	[7:0]	CRTC[0:63]; 	//25	// 3?5
reg	[7:0]	GC[0:15]; 	//9	// 3CF
reg	[7:0]	AC[0:63]; 	//21	// 3C0, 3C1

reg	[7:0]		HCharCnt;
reg				C256;
reg	[19:0]	Base;
reg				GfxMode;
reg	[9:0]		VDEE;
reg	[4:0]		MSL;
reg	[7:0]		VPix;
reg	[7:0]		VCharCnt;
	
integer i;
initial
begin
	for (i = 0; i < 8; i=i+1)
		Seq[i] = 8'd0;
	for (i = 0; i < 64; i=i+1)
		CRTC[i] = 8'd0;
	for (i = 0; i < 16; i=i+1)
		GC[i] = 8'd0;
	for (i = 0; i < 64; i=i+1)
		AC[i] = 8'd0;
		
	RMisc = 8'd0;
	RStt0 = 8'd0;
	RStt1 = 8'd9;
	FCtrl = 8'd0;
	VidEn = 8'd0;
	
	indSeq = 8'd0;
	indCRTC = 8'd0;
	indGC = 8'd0;
	indAC = 8'd0;
	ffAC = 1'b0;
	
	HCharCnt = 8'd80;
	C256 = 1'b0;
	Base = 20'hB8000;
	GfxMode = 1'b0;
	VDEE = 10'd199;
	MSL = 5'd0;
	VPix = 8'd200;
	VCharCnt = 8'd25;
end

always @(posedge iClk)
begin
	oBusAck <= 1'b0;
	if (iBusRW[1] == 1'b1) //read
	begin
		case (iBusAdr)

			//general purpose registers
			7'h4C:	oBusData <= RMisc; //misc			//3CC

			7'h42:	oBusData <= RStt0; //status 0		//3C2

			7'h3A, //status 1								//3BA
			7'h5A:	begin										//3DA

							case (RStt1)

								8'h01:	RStt1 <= 8'h08;

								8'h08:	RStt1 <= 8'h09;

								8'h09:	RStt1 <= 8'h01;

								default:	RStt1 <= 8'h09;

							endcase

							oBusData <= RStt1;
							//ffAC.Value = 1;
						end
			7'h4A:	oBusData <= FCtrl; //feature ctrl	//3CA

			7'h43:	oBusData <= VidEn; //video enable	//3C3

			//Sequencer
			7'h44:	oBusData <= indSeq;						//3C4

			7'h45:	oBusData <= Seq[indSeq[2:0]];	//3C5

			//CRT Ctrl
			7'h34,													//3B4
			7'h54:	oBusData <= indCRTC;						//3D4

			7'h35,													//3B5
			7'h55:	oBusData <= CRTC[indCRTC[5:0]];	//3D5

			//Graphics Ctrl
			7'h4E:	oBusData <= indGC;						//3CE

			7'h4F:	oBusData <= GC[indGC[3:0]];		//3CF

			//Attribute Ctrl
			7'h40:	oBusData <= indAC;						//3C0

			7'h41:	oBusData <= AC[indAC[5:0]];		//3C1

			default:
				oBusData <= 8'd0;
				//oBusData.Value = testbench.portRAMread(iBusAdr.Value);

		endcase
		oBusAck <= 1'b1;
	end

	if (iBusRW[0] == 1'b1) //write
	begin
		case (iBusAdr)

			//general purpose registers
			7'h42:	RMisc <= iBusData; //misc				//3C2

			7'h3A, //feature ctrl								//3BA
			7'h5A:	FCtrl <= iBusData;						//3DA

			7'h43:	VidEn <= iBusData; //video enable	//3C3
				
			//Sequencer
			7'h44:	indSeq <= iBusData;		//3C4

			7'h45:									//3C5
					Seq[indSeq[2:0]] <= iBusData;
					//Seq[indSeq] <= iBusData;
					//if (indSeq == 2)
					//	System.Windows.Forms.MessageBox.Show(iBusData.toHex());

			//CRT Ctrl
			7'h34,									//3B4
			7'h54:	indCRTC <= iBusData;		//3D4

			7'h35,									//3B5
			7'h55:	begin							//3D5
							CRTC[indCRTC[5:0]] <= iBusData;
							//CRTC[indCRTC] <= iBusData;
							case (indCRTC[5:0])

								6'd01:	HCharCnt <= iBusData + 1;

								6'd07:	VDEE <= (iBusData[6] << 9) + (iBusData[1] << 8) + VDEE[7:0];

								6'd09:	MSL <= iBusData[4:0];

								6'd12:	VDEE <= (VDEE[9:8] << 8) + iBusData;

							endcase
							VPix <= (VDEE + 1) / (MSL + 1);
							VCharCnt <= (VPix == 480) ? 30 : 25;
						end

			//Graphics Ctrl
			7'h4E:	indGC <= iBusData;	//3CE

			7'h4F:	begin						//3CF
							GC[indGC[3:0]] <= iBusData;
							//GC[indGC] <= iBusData;
							case (indGC[3:0])

								4'd5:	C256 <= (iBusData[6] == 1) ? 1'b1 : 1'b0;

								4'd6:	begin
											case (iBusData[3:2])

												2'd0:	Base <= 20'hA0000;

												2'd1:	Base <= 20'hA0000;

												2'd2:	Base <= 20'hB0000;

												2'd3:	Base <= 20'hB8000;

											endcase
											GfxMode <= (iBusData[0] == 1) ? 1'b1 : 1'b0;
										end
							endcase
						end

			//Attribute Ctrl
			7'h40:	begin									//3C0
							if (ffAC == 0)

								indAC <= iBusData;

							else
								AC[indAC[5:0]] <= iBusData; //[4:0]
							ffAC <= ffAC ^ 1'b1;
						end

			default:	begin end
					//testbench.portRAMwrite((int)iBusAdr.Value, (byte)iBusData.Value);

		endcase
		oBusAck <= 1'b1;
	end

end

endmodule

