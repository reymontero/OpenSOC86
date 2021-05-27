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


module CacheCtrl
	(
		input							iClk,
		input							iRst,
		
		input				[19:0]	iBus_Adr,    //byte adr
		input				[1:0]		iBus_RW,
		input				[15:0]	iBus_Data,
		input							iBus_BW,
		input				[1:0]		iBus_RWBurst,
		//input				[1:0]		iBus_BLoad,
		//input				[31:0]	iBus_BData,
		
		output	reg	[31:0]	oBus_Data,
		output	reg				oBus_Ack,
		output	reg	[31:0]	oBus_BData,
		output	reg				oBus_BAck,
		//output	reg				oBus_BGrant,
		
		
		output		[7:0]		oCR_Adr1,    //word adr
		output	reg	[7:0]		oCR_Adr2,    //word adr
		output		[3:0]		oCR_BE1,
		output		[31:0]	oCR_Data1,
		output	reg	[31:0]	oCR_Data2,
		output	reg				oCR_Wr1,
		output	reg				oCR_Wr2,
		input				[31:0]	iCR_Data1,
		input				[31:0]	iCR_Data2,
		
		output		[4:0]		oFR_Adr1,
		output	reg	[4:0]		oFR_Adr2,
		output		[11:0]	oFR_Data1,
		output	reg	[11:0]	oFR_Data2,
		output	reg				oFR_Wr1,
		output	reg				oFR_Wr2,
		input				[11:0]	iFR_Data1,
		input				[11:0]	iFR_Data2,
		
		input				[31:0]	iSR_Data,
		input							iSR_Ack,
		
		output	reg	[18:0]	oSR_Adr,    //word adr
		output	reg	[1:0]		oSR_RW,
		output	reg	[31:0]	oSR_Data,
		output	reg	[3:0]		oSR_BE,
		
		input				[31:0]	iDR_Data,
		input							iDR_Ack,
		input							iDR_Busy,
		
		output	reg				oDR_Stb,
		output	reg				oDR_Wr,
		output	reg	[23:0]	oDR_Adr,    //word adr
		output	reg	[31:0]	oDR_Data,
		output	reg	[3:0]		oDR_Mask,
		output	reg	[1:0]		oDR_Load
	);

initial
begin
	oBus_Data = 16'd0;
	oBus_Ack = 1'b0;
	//oCR_Data1 = 32'd0;
	//oCR_Adr1 = 8'd0;
	oCR_Wr1 = 1'b0;
	//oCR_BE1 = 4'd0;
	oCR_Data2 = 32'd0;
	oCR_Adr2 = 8'd0;
	oCR_Wr2 = 1'b0;
	//oFR_Data1 = 12'd0;
	//oFR_Adr1 = 5'd0;
	oFR_Wr1 = 1'b0;
	oFR_Data2 = 12'd0;
	oFR_Adr2 = 5'd0;
	oFR_Wr2 = 1'b0;
	oSR_Adr = 19'd0;
	oSR_RW = 2'd0;
	oSR_Data = 32'd0;
	oSR_BE = 4'd0;
	oDR_Stb = 1'b0;
	oDR_Wr = 1'b0;
	oDR_Adr = 24'd0;
	oDR_Data = 32'd0;
	oDR_Mask = 4'd0;
	oDR_Load = 2'd0;
end

reg	[1:0]	preRW1;
reg	[1:0]	preRW2;
reg	[1:0]	preRW3;

reg	[1:0]	preBurst1;
reg	[1:0]	preBurst2;

initial
begin
	preRW1 = 2'b0;
	preRW2 = 2'b0;
	preRW3 = 2'b0;
end
	
wire	[19:0]	frsAdr		= iBus_Adr[19:0];

wire	[9:0]		frsRowAdr	= iBus_Adr[19:10];
wire	[4:0]		frsRow		= iBus_Adr[9:5];
wire	[7:0]		frsCAdr		= iBus_Adr[9:2];
wire	[1:0]		frsByte		= iBus_Adr[1:0];

wire				wordEdge		= iBus_BW & frsByte[0] & frsByte[1];

reg	[19:0]	nxtAdr;

wire	[9:0]		nxtRowAdr	= nxtAdr[19:10];
wire	[4:0]		nxtRow		= nxtAdr[9:5];
wire	[7:0]		nxtCAdr		= nxtAdr[9:2];

reg	[11:0]	curFrsFlagData;
reg	[11:0]	curNxtFlagData;

wire				frsReady		= (preRW2[0] | preRW2[1]);
wire				nxtReady		= (preRW3[0] | preRW3[1]);
wire				burstReady	= (preBurst2[0] | preBurst2[1]);

wire	[9:0]		curFrsRowAdr	= (frsReady) ? iFR_Data1[9:0] : curFrsFlagData[9:0];
wire				curFrsValid		= (frsReady) ? iFR_Data1[10] : curFrsFlagData[10];
wire				curFrsDirty		= (frsReady) ? iFR_Data1[11] : curFrsFlagData[11];

wire	[9:0]		curNxtRowAdr	= (nxtReady) ? iFR_Data1[9:0] : curNxtFlagData[9:0];
wire				curNxtValid		= (nxtReady) ? iFR_Data1[10] : curNxtFlagData[10];
wire				curNxtDirty		= (nxtReady) ? iFR_Data1[11] : curNxtFlagData[11];

wire				curFrsMatch		= (curFrsRowAdr == frsRowAdr) ? 1'b1 : 1'b0;
wire				curNxtMatch		= (curNxtRowAdr == nxtRowAdr) ? 1'b1 : 1'b0;

wire				wrFrsRow		= ~curFrsMatch & curFrsDirty;
wire				rdFrsRow		= ~curFrsMatch | ~curFrsValid;

wire				wrNxtRow		= ~curNxtMatch & curNxtDirty & wordEdge;
wire				rdNxtRow		= (~curNxtMatch | ~curNxtValid) & wordEdge;

wire				burstCache	= curFrsMatch & curFrsValid;

wire				useSRAM		= (iBus_Adr[19:17] == 3'b101) ? 1'b1 : 1'b0;

//-------------------------------------------------------------------

reg	[4:0]	state;

localparam [4:0]
	STATE_IDLE		= 5'd0,
	
	STATE_DR_WR0	= 5'd1,
	STATE_DR_WR1	= 5'd2,
	STATE_DR_WR2	= 5'd3,
	
	STATE_DR_PR1	= 5'd4,
	STATE_DR_PR2	= 5'd5,
	STATE_DR_PR3	= 5'd6,
	
	STATE_DR_RD1	= 5'd7,
	STATE_DR_RD2	= 5'd8,
	STATE_DR_RD3	= 5'd9,
	STATE_DR_RD4	= 5'd10,
	STATE_DR_RD5	= 5'd11,
	
	STATE_BRDC1		= 5'd12,
	STATE_BRDC2		= 5'd13,
	STATE_BRDC3		= 5'd14,
	
	STATE_BRDR1		= 5'd15,
	STATE_BRDR2		= 5'd16,
	STATE_BRDR3		= 5'd17,
	
	STATE_BWRC1		= 5'd18,
	STATE_BWRC2		= 5'd19,
	STATE_BWRC3		= 5'd20,
	
	STATE_BWRR1		= 5'd21,
	STATE_BWRR2		= 5'd22,
	STATE_BWRR3		= 5'd23;
	
	//STATE_BURST1	= 4'd12,
	//STATE_BURST2	= 4'd13,
	//STATE_BURST3	= 4'd14,
	//STATE_BURST4	= 4'd15;
	
	//STATE_RESERVED	= 4'd15;
	
//-------------------------------------------------------------------

reg		sel1FrsNxt;
reg		sel2FrsNxt;
reg		sel2Burst;
reg		selBurstCR;

	//--- CACHE PORT 1 --------------------------------------------------
assign oCR_Data1 = (iBus_Adr[0]) ? {iBus_Data[7:0], iBus_Data[15:0], iBus_Data[15:8]} : {iBus_Data[15:0], iBus_Data[15:0]};
assign oCR_Adr1 = (sel1FrsNxt == 1'b0) ? frsCAdr : nxtCAdr;
wire [3:0] inBE32 = {2'b0, iBus_BW, 1'b1} << iBus_Adr[1:0];
assign oCR_BE1 = (sel1FrsNxt == 1'b0) ? inBE32 : 4'b0001;

	//--- FLAGS PORT 1 --------------------------------------------------
assign oFR_Data1 = (sel1FrsNxt == 1'b0) ? {2'b11, frsRowAdr} : {2'b11, nxtRowAdr};
assign oFR_Adr1 = (sel1FrsNxt == 1'b0) ? frsRow : nxtRow;


reg	[1:0]	inRW;

reg		selCrSr;
reg	[15:0]	crData16;	//comb
reg	[15:0]	srData16;	//comb
reg		wait4SRAck;

reg	FWrValid;


initial
begin
	sel1FrsNxt = 1'b0;
	sel2FrsNxt = 1'b0;
	sel2Burst = 1'b0;
	selBurstCR = 1'b0;
	selCrSr = 1'b0;
	
	inRW = 2'b0;
	
	FWrValid = 1'b0;
end

always @(posedge iClk)
begin
	oCR_Wr2 <= 1'b0;
	oFR_Wr1 <= 1'b0;
	oFR_Wr2 <= 1'b0;
	oDR_Stb <= 1'b0;
	oDR_Load <= 2'b00;
	
	oBus_BAck <= 1'b0;

	nxtAdr <= frsAdr + 20'd1;
	
	sel1FrsNxt <= 1'b0;
	if ((iBus_RW != 2'b00) || (preRW3[0] & wordEdge))
		sel1FrsNxt <= 1'b1;
	
	preRW1 <= (useSRAM == 1'b0) ? iBus_RW : 2'b00;
	preRW2 <= preRW1;
	preRW3 <= preRW2;
	
	if (iBus_RW[0] | iBus_RW[1])
		selCrSr <= useSRAM;
	if (iBus_RW[0] | iBus_RW[1])
		wait4SRAck <= useSRAM;
	else if (iSR_Ack == 1'b1)
		wait4SRAck <= 1'b0;
	
	preBurst1 <= iBus_RWBurst;
	preBurst2 <= preBurst1;
	
	oBus_Ack <= ((frsReady & curFrsMatch & curFrsValid & ~wordEdge) |
					 (nxtReady & curFrsMatch & curFrsValid & curNxtMatch & curNxtValid & wordEdge) |
					 (wait4SRAck & iSR_Ack) ) ? 1'b1 : 1'b0;
	
	if (frsReady | burstReady)
		curFrsFlagData <= iFR_Data1;
	if (nxtReady)
		curNxtFlagData <= iFR_Data1;
		
	
	oCR_Wr1 <= ((preRW2[0] & curFrsMatch & curFrsValid) | (preRW3[0] & curNxtMatch & curNxtValid & wordEdge)) ? 1'b1 : 1'b0;
	oFR_Wr1 <= ((preRW2[0] & curFrsMatch & curFrsValid) | (preRW3[0] & curNxtMatch & curNxtValid & wordEdge)) ? 1'b1 : 1'b0;
	
	oCR_Adr2[2:0] <= 3'd0;
	
	//--- BUS OUTPUT PORT -----------------------------------------------
	case ({iBus_BW, frsByte})
		3'b000:	crData16 = {8'd0, iCR_Data1[7:0]};
		3'b001:	crData16 = {8'd0, iCR_Data1[15:8]};
		3'b010:	crData16 = {8'd0, iCR_Data1[23:16]};
		3'b011:	crData16 = {8'd0, iCR_Data1[31:24]};
		3'b100:	crData16 = iCR_Data1[15:0];
		3'b101:	crData16 = iCR_Data1[23:8];
		3'b110:	crData16 = iCR_Data1[31:16];
		3'b111:	crData16 = {iCR_Data1[7:0], iCR_Data1[31:24]};	//TODO: fix
	endcase
	case ({iBus_BW, frsByte})
		3'b000:	srData16 = {8'd0, iSR_Data[7:0]};
		3'b001:	srData16 = {8'd0, iSR_Data[15:8]};
		3'b010:	srData16 = {8'd0, iSR_Data[23:16]};
		3'b011:	srData16 = {8'd0, iSR_Data[31:24]};
		3'b100:	srData16 = iSR_Data[15:0];
		3'b101:	srData16 = iSR_Data[23:8];
		3'b110:	srData16 = iSR_Data[31:16];
		3'b111:	srData16 = {iSR_Data[7:0], iSR_Data[31:24]};    //TODO: fix
	endcase
	if (preRW2[1] | selCrSr)
		oBus_Data <= (selCrSr == 1'b0) ? crData16 : srData16;
	else if (preRW3[1] & wordEdge)
		oBus_Data[15:8] <= (selCrSr == 1'b0) ? crData16[15:8] : srData16[15:8];		//TODO: FIX
	oBus_BData <= (selBurstCR == 1'b0) ? iCR_Data2 : iDR_Data;
	
	//--- CACHE PORT 2 --------------------------------------------------
	oCR_Data2 <= iDR_Data;
	oCR_Adr2[7:3] <= (sel2FrsNxt == 1'b0) ? frsRow : nxtRow;
	
	//--- FLAGS PORT 2 --------------------------------------------------
	oFR_Data2 <= (sel2FrsNxt == 1'b0) ? {1'b0, FWrValid, frsRowAdr} : {1'b0, FWrValid, nxtRowAdr};
	oFR_Adr2 <= (sel2FrsNxt == 1'b0) ? frsRow : nxtRow;
	
	//--- DRAM PORT -----------------------------------------------------
	//if (selBurst)
	//	oDR_Adr <= {6'd0, iBus_Adr[19:2]};
	//else
		oDR_Adr <= (sel2Burst == 1'b1) ? {6'b0, frsRowAdr, frsRow, 3'b0} : ((sel2FrsNxt == 1'b0) ? {6'b0, curFrsRowAdr, frsRow, 3'b0} : {6'b0, curNxtRowAdr, nxtRow, 3'b0});
	oDR_Data <= iCR_Data2;
	oDR_Mask <= 4'b1111;
	
	//--- SRAM PORT -----------------------------------------------------
	oSR_Adr <= {4'b0, iBus_Adr[16:2]};
	oSR_BE <= {2'b0, iBus_BW, 1'b1} << iBus_Adr[1:0];
	oSR_Data <= (iBus_Adr[0]) ? {iBus_Data[7:0], iBus_Data[15:0], iBus_Data[15:8]} : {iBus_Data[15:0], iBus_Data[15:0]};
	oSR_RW <= (useSRAM == 1'b1) ? iBus_RW : 2'b00;
	
	//-------------------------------------------------------------------
	case (state)
		STATE_IDLE:
			begin
				//doBurst <= 1'b0;
				//selBurst <= 1'b0;
				sel2Burst = 1'b0;
				
				if (preBurst2 != 2'b00)
				begin
					if (preBurst2[1] == 1'b1)
					begin
						sel2Burst = 1'b1;
						if (burstCache)
						begin
							selBurstCR <= 1'b0;
							state <= STATE_BRDC1;
						end else begin
							selBurstCR <= 1'b1;
							state <= STATE_BRDR1;
						end
					end else begin
						if (burstCache)
						begin
							state <= STATE_BWRC1;
						end else begin
							state <= STATE_BWRR1;
						end
					end
				//	if (mvCurRow)
				//	begin
				//		state <= STATE_DR_WR1;
				//		doBurst <= 1'b1;
				//	end else
				//		state <= STATE_BURST1;
				end
				else
				if (preRW2 != 2'b00)
				begin
					inRW <= preRW2;
					if (wrFrsRow)
						state <= STATE_DR_WR0;
					else if (rdFrsRow)
						state <= STATE_DR_PR1;
					sel2FrsNxt <= 1'b0;
				end
				else
				if (preRW3 != 2'b00)
				begin
					inRW <= preRW3;
					if (wrNxtRow)
						state <= STATE_DR_WR0;
					else if (rdNxtRow)
						state <= STATE_DR_PR1;
					sel2FrsNxt <= 1'b1;
				end
			end
		
	//-------------------------------------------------------------------
		STATE_DR_WR0:
			begin
				state <= STATE_DR_WR1;
			end
		STATE_DR_WR1:
			begin
				oCR_Adr2[2:0] <= oCR_Adr2[2:0] + 3'd1;
				case (oCR_Adr2[2:0])
					3'd0:	oDR_Load <= 2'b00;
					3'd1:	oDR_Load <= 2'b11;
					default: oDR_Load <= 2'b01;
				endcase
				oDR_Stb <= (oCR_Adr2[2:0] == 3'd1) ? 1'b1 : 1'b0;
				oDR_Wr <= 1'b1;
				if (oCR_Adr2[2:0] == 3'd7)
					state <= STATE_DR_WR2;
			end
		STATE_DR_WR2:
			begin
				oDR_Load <= 2'b01;
				state <= STATE_DR_PR1;
				FWrValid <= 1'b0;
			end
		
		
		STATE_DR_PR1:
			begin
				if (iDR_Busy == 1'b0)
				begin
					
					oFR_Wr2 <= 1'b1;
					state <= STATE_DR_PR2;
				end
			end
		STATE_DR_PR2:
			begin
				state <= STATE_DR_PR3;
			end
		STATE_DR_PR3:
			begin
				//if (doBurst)
				//	state <= STATE_BURST1;
				//else
				if (sel2FrsNxt == 1'b0)
					curFrsFlagData <= iFR_Data2;
				else
					curNxtFlagData <= iFR_Data2;
				
					state <= STATE_DR_RD1;
			end
		
	//-------------------------------------------------------------------
		STATE_DR_RD1:
			begin
				oDR_Stb <= 1'b1;
				oDR_Wr <= 1'b0;
				state <= STATE_DR_RD2;
			end
		STATE_DR_RD2:
			begin
				if (iDR_Ack == 1'b1)
				begin
					oCR_Adr2[2:0] <= 3'd0;
					oCR_Wr2 <= 1'b1;
					state <= STATE_DR_RD3;
					FWrValid <= 1'b1;
				end
			end
		STATE_DR_RD3:
			begin
				oCR_Adr2[2:0] <= oCR_Adr2[2:0] + 3'd1;
				oCR_Wr2 <= 1'b1;
				if (oCR_Adr2[2:0] == 3'd6)
				begin
					oFR_Wr2 <= 1'b1;
					state <= STATE_DR_RD4;
				end
			end
		STATE_DR_RD4:
			begin
				state <= STATE_DR_RD5;
			end
		STATE_DR_RD5:
			begin
				preRW1 <= inRW;
				sel1FrsNxt <= 1'b1;
				state <= STATE_IDLE;
			end
		
	//-------------------------------------------------------------------
		STATE_BRDC1:
			begin
				state <= STATE_BRDC2;
			end
		STATE_BRDC2:
			begin
				oCR_Adr2[2:0] <= oCR_Adr2[2:0] + 3'd1;
				case (oCR_Adr2[2:0])
					3'd0:	oBus_BAck <= 1'b0;
					default: oBus_BAck <= 1'b1;
				endcase
				if (oCR_Adr2[2:0] == 3'd7)
					state <= STATE_BRDC3;
			end
		STATE_BRDC3:
			begin
				oBus_BAck <= 1'b1;
				state <= STATE_IDLE;
			end
		
	//-------------------------------------------------------------------
		STATE_BRDR1:
			begin
				oDR_Stb <= 1'b1;
				oDR_Wr <= 1'b0;
				state <= STATE_BRDR2;
			end
		STATE_BRDR2:
			begin
				if (iDR_Ack == 1'b1)
				begin
					oBus_BAck <= 1'b1;
					state <= STATE_BRDR3;
				end
			end
		STATE_BRDR3:
			begin
				oCR_Adr2[2:0] <= oCR_Adr2[2:0] + 3'd1;
				oBus_BAck <= 1'b1;
				if (oCR_Adr2[2:0] == 3'd6)
					state <= STATE_IDLE;
			end
			
	//-------------------------------------------------------------------
		STATE_BWRC1:
			begin
				state <= STATE_IDLE;
			end
		
	//-------------------------------------------------------------------
		STATE_BWRR1:
			begin
				state <= STATE_IDLE;
			end
		
	
//		STATE_BURST1:
//			begin
//				selBurst <= 1'b1;
//				//oBus_BGrant <= 1'b1;
//				state <= STATE_BURST2;
//			end
//		STATE_BURST2:
//			begin
//				oDR_Stb <= 1'b1;
//				oDR_Wr <= 1'b0;
//				brstCnt <= 3'd0;
//				state <= STATE_BURST3;
//			end
//		STATE_BURST3:
//			begin
//				if (iDR_Ack == 1'b1)
//				begin
//					brstCnt <= brstCnt + 3'd1;
//					if (brstCnt == 3'd7)
//						state <= STATE_BURST4;
//				end
//			end
//		STATE_BURST4:
//			begin
//				selBurst <= 1'b0;
//				//oBus_BGrant <= 1'b0;
//				state <= STATE_IDLE;
//			end
			
	//-------------------------------------------------------------------
		default: state <= STATE_IDLE;
	endcase
end

endmodule
