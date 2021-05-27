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


module memCtrl
	(

		input							iClk,
		input							iRst,
			
		input							iMemReq,

		input						iBurstReq,
		input				[19:0]		iBurstAdr,
		input						iDMABurstReq,
		input				[19:0]		iDMABurstAdr,
		output	reg				oBurstStart,
		output	reg				oBurstAck,
		
		input							iRamAck,
		input				[31:0]	iRamData,
		output	reg	[19:0]	oRamAdr,
		output	reg				oRamBW,
		output	reg	[1:0]		oRamRW,
		output	reg	[15:0]	oRamData,
		output	reg	[1:0]			oRamBurst,
		
		output	reg	[31:0]	oData32,
		output	reg	[1:0]	oIndex32,
		output	reg				oAck32,
		
		//input				[15:0]	EA_Rd,
		//input				[15:0]	EA_Wr,
		//input				[15:0]	EA2,
		
		input				[15:0]	ES,
		input				[15:0]	CS,
		input				[15:0]	SS,
		input				[15:0]	DS,
		
		input				[15:0]	BX,
		input				[15:0]	SP,
		input				[15:0]	BP,
		input				[15:0]	SI,
		input				[15:0]	DI,
		
		input				[15:0]	IP,
		input							iJumped,
		
		//input				[1:0]		setSeg,
		//input							segOR,
		//input				[2:0]		Sel,
		//input				[1:0]		BW,
		//input				[1:0]		RdWr,	//[R=bit1, W=bit0]
		
		//input				[1:0]		Imod,
		//input				[2:0]		rm,
		
		//input				[15:0]	ImmRd,
		//input				[15:0]	ImmWr,
		
		input		[1:0]		RdWr,
		
		input		[1:0]		MOD_Rd,
		input		[2:0]		RM_Rd,
		input		[15:0]	EAImm_Rd,
		input		[15:0]	Imm_Rd,
		input		[1:0]		setSeg_Rd,
		input					segOR_Rd,
		input		[2:0]		Sel_Rd,
		input		[1:0]		BW_Rd,
		
		input		[1:0]		MOD_Wr,
		input		[2:0]		RM_Wr,
		input		[15:0]	EAImm_Wr,
		input		[15:0]	Imm_Wr,
		input		[1:0]		setSeg_Wr,
		input					segOR_Wr,
		input		[2:0]		Sel_Wr,
		input		[1:0]		BW_Wr,
		
		
		
		input				[15:0]	AInt,
		
		output	reg				Stall,
		
		input				[15:0]	iData,
		//output	reg				oAck,
		output	reg	[15:0]	oData,
		
		output			[15:0]	immEA
	);


reg [19:0] PA;


reg [15:0] CSloc;
reg [15:0] IPloc;

reg	[2:0]	state;
reg	[2:0]	cnt;

reg			didReq;
reg			didJmpReq;
reg			didBurstReq;
reg			didDMABurstReq;
reg	[1:0]	didRdWr;

reg	[15:0] didImm_Rd;
reg	[15:0] didSegVal_Rd;
reg	[15:0] didEA_Rd;
reg	[2:0]	didSel_Rd;
reg	[1:0]	didBW_Rd;

reg	[15:0] didImm_Wr;
reg	[15:0] didSegVal_Wr;
reg	[15:0] didEA_Wr;
reg	[2:0]	didSel_Wr;
reg	[1:0]	didBW_Wr;

reg	[15:0] didAInt;
reg	[15:0] didData;


reg	[1:0]	burstFirst;



//reg [1:0] curRdWr;

reg [15:0] curImm;
reg	[15:0] curSegVal;
reg [15:0] curEA;
reg [2:0] curSel;
reg [1:0] curBW;

reg [15:0] curAInt;
reg [15:0] curData;


initial
begin
	PA = 20'b0;
	
	CSloc = 16'hF000;
	IPloc = 16'hFFF0;
	state = 3'b0;
	cnt = 3'b0;
	
	didReq = 1'b0;
	didJmpReq = 1'b0;
	didBurstReq = 1'b0;
	didDMABurstReq = 1'b0;
	didRdWr = 2'b0;
	
	burstFirst = 2'b0;
	oIndex32 = 2'b0;
end

//-----------------------------------------

reg	[15:0]	EA_Rd;
reg [15:0] EA_dly;
assign immEA = EA_dly;
reg [15:0] segVal_Rd;

initial
begin
	EA_Rd = 16'd0;
	EA_dly = 16'd0;
	segVal_Rd = 16'b0;
end

reg [15:0] EA1_Rd;
reg [15:0] EA2_Rd;
reg	[15:0]	tmpEA_Rd;

always @(posedge iClk)
if (iRst == 1'b1)
begin
	EA_Rd <= 16'd0;
	EA_dly <= 16'd0;
	segVal_Rd <= 16'b0;
end else
begin
	case (setSeg_Rd)
		0:	segVal_Rd <= ES;
		1:	segVal_Rd <= CS;
		2:	segVal_Rd <= SS;
		3:	segVal_Rd <= DS;
	endcase
	
	if ((RM_Rd[2:1] == 2'b00) || ((RM_Rd[2] == 1'b1) && (RM_Rd[0] == 1'b1)))
		EA1_Rd = BX;
	else
		EA1_Rd = BP;
	
	if (RM_Rd[0] == 1'b0)
		EA2_Rd = SI;
	else
		EA2_Rd = DI;
	
	case (RM_Rd)
		0, 1, 2, 3: tmpEA_Rd = EA1_Rd + EA2_Rd;	//BX + SI, BX + DI, BP + SI, BP + DI
		4, 5: 		tmpEA_Rd = EA2_Rd;			//SI, DI
		6, 7: 		tmpEA_Rd = EA1_Rd;			//BP, BX
	endcase
	
	if (((RM_Rd == 3'd6) && (MOD_Rd == 2'd0)) || (MOD_Rd == 2'd3))
		tmpEA_Rd = 0;
	if (((RM_Rd == 3'd2) || (RM_Rd == 3'd3) || ((RM_Rd == 3'd6) && (MOD_Rd != 2'd0))) && (segOR_Rd == 1'b0))
		segVal_Rd <= SS;  //SS      //TODO: check if also when mod==0 and rm==6
	
	EA_Rd <= tmpEA_Rd + EAImm_Rd;
	EA_dly <= EA_Rd;
end

//-----------------------------------------

reg	[15:0]	EA_Wr;
reg [15:0] segVal_Wr;

initial
begin
	EA_Wr = 16'd0;
	segVal_Wr = 16'b0;
end

reg [15:0] EA1_Wr;
reg [15:0] EA2_Wr;
reg	[15:0]	tmpEA_Wr;

always @(posedge iClk)
if (iRst == 1'b1)
begin
	EA_Wr <= 16'd0;
	segVal_Wr <= 16'b0;
end else
begin
	case (setSeg_Wr)
		0:	segVal_Wr <= ES;
		1:	segVal_Wr <= CS;
		2:	segVal_Wr <= SS;
		3:	segVal_Wr <= DS;
	endcase
	
	if ((RM_Wr[2:1] == 2'b00) || ((RM_Wr[2] == 1'b1) && (RM_Wr[0] == 1'b1)))
		EA1_Wr = BX;
	else
		EA1_Wr = BP;
	
	if (RM_Wr[0] == 1'b0)
		EA2_Wr = SI;
	else
		EA2_Wr = DI;
	
	case (RM_Wr)
		0, 1, 2, 3: tmpEA_Wr = EA1_Wr + EA2_Wr;	//BX + SI, BX + DI, BP + SI, BP + DI
		4, 5: 		tmpEA_Wr = EA2_Wr;			//SI, DI
		6, 7: 		tmpEA_Wr = EA1_Wr;			//BP, BX
	endcase
	
	if (((RM_Wr == 3'd6) && (MOD_Wr == 2'd0)) || (MOD_Wr == 2'd3))
		tmpEA_Wr = 0;
	if (((RM_Wr == 3'd2) || (RM_Wr == 3'd3) || ((RM_Wr == 3'd6) && (MOD_Wr != 2'd0))) && (segOR_Wr == 1'b0))
		segVal_Wr <= SS;  //SS      //TODO: check if also when mod==0 and rm==6
	
	EA_Wr <= tmpEA_Wr + EAImm_Wr;
end

//-----------------------------------------


reg [15:0] useSeg;
reg [15:0] useEA;
reg [3:0] Word2nd;


always @(posedge iClk)

if (iRst == 1'b1)
begin
	CSloc <= 16'hF000;
	IPloc <= 16'hFFF0;
	PA <= 20'b0;
	oAck32 <= 1'b0;
	oRamBurst <= 1'b0;
	oRamRW <= 2'b0;
	
	state <= 3'b0;
	cnt <= 3'b0;
	
	didReq <= 1'b0;
	didJmpReq <= 1'b0;
	didBurstReq <= 1'b0;
	didDMABurstReq <= 1'b0;
	didRdWr <= 2'b0;
	
	//didBW <= 2'b0;

	oBurstStart <= 1'b0;
	oBurstAck <= 1'b0;

end else
begin
	oAck32 <= 1'b0;
	oRamBurst <= 1'b0;

	oBurstStart <= 1'b0;
	oBurstAck <= 1'b0;
	
	if (iJumped == 1'b1)
	begin
		CSloc <= CS;
		IPloc <= IP;
	end
	
	if (iMemReq != 1'b0)
	begin
		didReq <= 1'b1;
		if (iJumped == 1'b1)
			didJmpReq <= 1'b1;
	end
	if (iBurstReq != 1'b0)
		didBurstReq <= 1'b1;
	if (iDMABurstReq != 1'b0)
		didDMABurstReq <= 1'b1;
	if (RdWr != 2'b00)
	begin
		didRdWr <= RdWr;
		
		didImm_Rd <= Imm_Rd;
		didSegVal_Rd <= segVal_Rd;
		didEA_Rd <= EA_Rd;
		didSel_Rd <= Sel_Rd;
		didBW_Rd <= BW_Rd;

		didImm_Wr <= Imm_Wr;
		didSegVal_Wr <= segVal_Wr;
		didEA_Wr <= EA_Wr;
		didSel_Wr <= Sel_Wr;
		didBW_Wr <= BW_Wr;

		didAInt <= AInt;
		didData <= iData;
	end
	Stall <= didRdWr[1] | didRdWr[0] | RdWr[1] | RdWr[0] | state[1];

	//oAck <= 1'b0;
	oRamRW <= 2'b0;
	
	case (state)

		3'd0:	begin
					if ((RdWr != 2'b00) || (didRdWr != 2'b00))
					begin
						//curRdWr = (RdWr == 2'b00) ? didRdWr : RdWr;
						
						curImm    = (RdWr == 2'b00) ? ((didRdWr[0]) ? didImm_Wr    : didImm_Rd)    : ((RdWr[0]) ? Imm_Wr    : Imm_Rd);
						curSegVal = (RdWr == 2'b00) ? ((didRdWr[0]) ? didSegVal_Wr : didSegVal_Rd) : ((RdWr[0]) ? segVal_Wr : segVal_Rd);
						curEA     = (RdWr == 2'b00) ? ((didRdWr[0]) ? didEA_Wr     : didEA_Rd)     : ((RdWr[0]) ? EA_Wr     : EA_Rd);
						curSel    = (RdWr == 2'b00) ? ((didRdWr[0]) ? didSel_Wr    : didSel_Rd)    : ((RdWr[0]) ? Sel_Wr    : Sel_Rd);
						curBW     = (RdWr == 2'b00) ? ((didRdWr[0]) ? didBW_Wr     : didBW_Rd)     : ((RdWr[0]) ? BW_Wr     : BW_Rd);
						
						curAInt = (RdWr == 2'b00) ? didAInt : AInt;
						curData = (RdWr == 2'b00) ? didData : iData;
						
						case (curSel)
							0:	{useSeg, useEA} = {curSegVal, curEA};// + Imm)};
							1:	{useSeg, useEA} = {       ES, DI};
							2:	{useSeg, useEA} = {curSegVal, curImm};
							3:	{useSeg, useEA} = {       SS, SP};
							4:	{useSeg, useEA} = {    16'd0, curAInt[15:0]};
							5:	{useSeg, useEA} = {curSegVal, curAInt[15:0]};
							6:	{useSeg, useEA} = {curSegVal, SI};
						endcase
						
						Word2nd = {2'b00, (curBW[1] & curBW[0]), 1'b0};
						PA = {useSeg, Word2nd} + {4'b0, useEA};
						oRamAdr <= PA;
						
						//case (curSel)
						//	0:	PA = {curSegVal, 4'b0} + {4'b0, (curEA)};// + Imm)};
						//	1:	PA = {       ES, 4'b0} + {4'b0, DI};
						//	2:	PA = {curSegVal, 4'b0} + {4'b0, curImm};
						//	3:	PA = {       SS, 4'b0} + {4'b0, SP};
						//	4:	PA =                     {4'b0, curAInt[15:0]};
						//	5:	PA = {curSegVal, 4'b0} + {4'b0, curAInt[15:0]};
						//	6:	PA = {curSegVal, 4'b0} + {4'b0, SI};
						//endcase
						
						//curBW = (RdWr == 2'b00) ? didBW : BW;
						//case (curBW)
						//	0:	oRamAdr <= PA;
						//	1:	oRamAdr <= PA;
						//	2:	oRamAdr <= PA;
						//	3:	oRamAdr <= PA + 20'b10;
						//endcase
						
						oRamBW <= curBW[1] | curBW[0];
						oRamRW <= RdWr | didRdWr;
						oRamData <= curData;
						didRdWr <= 2'b00;
						if ((RdWr[0] == 1'b1) || (didRdWr[0] == 1'b1))
							state <= 3'd3;
						else
							state <= 3'd2;

					end else
					if ((iMemReq == 1'b1) || (didReq == 1'b1))
					begin
						oRamAdr <= {CSloc, 4'b0} + {4'b0, IPloc[15:2], 2'b0};
						burstFirst <= IPloc[1:0];
						oRamBurst <= 2'd2;
						if ((iJumped == 1'b0) && (didJmpReq == 1'b0))
							IPloc <= {IPloc[15:2], 2'b0} + 16'd32;
						cnt <= 3'b0;
						didReq <= 1'b0;
						didJmpReq <= 1'b0;
						state <= 3'd1;
					end
					else if ((iBurstReq == 1'b1) || (didBurstReq == 1'b1))
					begin
						oRamAdr <= iBurstAdr;
						oRamBurst <= 1'b1;
						didBurstReq <= 1'b0;
						oBurstStart <= 1'b1;
						state <= 3'd4;
					end
					else if ((iDMABurstReq == 1'b1) || (didDMABurstReq == 1'b1))
					begin
						oRamAdr <= iDMABurstAdr;
						oRamBurst <= 1'b1;
						didDMABurstReq <= 1'b0;
						oBurstStart <= 1'b1;
						state <= 3'd4;
					end
				end
		3'd1:	begin
					if (iRamAck == 1'b1)
					begin
						oData32 <= iRamData;
						if (cnt == 3'd0)
							oIndex32 <= burstFirst;
						else
							oIndex32 <= 2'b0;
						oAck32 <= 1'b1;
						cnt <= cnt + 3'b1;
						if (cnt == 3'b111)
							state <= 3'd0;
					end
				end
		3'd2:	begin
					if (iRamAck == 1'b1)
					begin
						oData <= iRamData[15:0];
						//oAck <= 1'b1;
						Stall <= 1'b0;
						state <= 3'd0;
					end
				end
		3'd3:	begin
					if (iRamAck == 1'b1)
					begin
						Stall <= 1'b0;
						state <= 3'd0;
					end
				end
		3'd4:	begin
					if (iRamAck == 1'b1)
					begin
						oBurstAck <= 1'b1;
						Stall <= 1'b0;
						state <= 3'd0;
					end
				end
		default:	state <= 3'd0;

	endcase

end

endmodule

