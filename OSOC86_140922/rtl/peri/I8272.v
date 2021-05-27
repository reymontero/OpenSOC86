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



module I8272
	(
		input						iClk,
		input						iRst,
		
		input		[1:0]	iAdr,
		input		[1:0]	iRW,
		input		[7:0]	iData,
		output	reg	[7:0]	oData,
		output	reg			oAck,
		
		output	reg			oIRQ,
		
		input							iAckRW,
		output			[11:0]	oLBA,
		output	reg	[1:0]		oReqRW
	);

reg	[7:0]	track[0:3];
reg	[7:0]	NCN[0:3];
reg	[7:0]	H[0:3];

reg	[7:0]	PCN;

reg	[7:0]	cmd;
reg	[7:0]	args[0:7];
reg	[3:0]	argcnt;
reg	[2:0]	curcnt;

reg	[7:0]	dout[0:6];
reg	[2:0]	outcnt;

reg	[7:0]	status;
reg	[7:0]	ST0;
reg	[7:0]	ST1;
reg	[7:0]	ST2;
reg	[7:0]	ST3;

reg			NDMA;

reg	[11:0]	LBA;
assign oLBA = LBA;

reg	[1:0]	state;

reg			isEnabled;

integer i;
initial
begin
	for (i=0; i<4; i=i+1)
	begin
		track[i] = 8'd0;
		NCN[i] = 8'd0;
		H[i] = 8'd0;
	end
	
	PCN = 8'd0;
	cmd = 8'd0;
	
	for (i=0; i<8; i=i+1)
		args[i] = 8'd0;
	
	argcnt = 4'd0;
	curcnt = 3'd0;
	
	for (i=0; i<7; i=i+1)
		dout[i] = 8'd0;
	
	outcnt = 3'd0;

	status = 8'd0;
	ST0 = 8'd0;
	ST1 = 8'd0;
	ST2 = 8'd0;
	ST3 = 8'd0;

	NDMA = 1'b0;
	LBA = 12'd0;
	state = 2'd0;
	isEnabled = 1'b0;
	
	oData = 8'd0;
	oAck = 1'b0;
	oIRQ = 1'b0;
	oReqRW = 2'b0;
end

always @(posedge iClk)
begin
	oIRQ <= 1'b0;
	if ((iAdr[1:0] == 2'd2) && (iRW[0] == 1'b1))
	begin

		if (iData[2] == 1'b1)  //enable
		begin

			if (isEnabled == 1'b0)
			begin
				ST0 <= 8'hC0;
				oIRQ <= 1'b1;
			end
		end
		isEnabled <= iData[2];
	end

	oAck <= 1'b0;
	if ((iAdr[1:0] == 2'd0) && (iRW[1] == 1'b1))
	begin
		oData <= status;
		oAck <= 1'b1;
	end
	
	oReqRW <= 2'b0;
	if (iAckRW == 1'b1)
		oIRQ <= 1'b1;

	case (state)

		2'd0:	begin
					status	<= 8'd128;
					if ((iAdr[1:0] == 2'b1) && (iRW[0] == 1'b1))
					begin
						cmd		<= iData;
						curcnt	<= 3'd0;
						state		<= 2'd1;
						case (iData[4:0])

							5'd2:		{argcnt, outcnt} <= {4'd8, 3'd7};	 //read track		0MS0 0010 0000 0HDD

							5'd3:		{argcnt, outcnt} <= {4'd2, 3'd0};	 //specify			0000 0011 [SRT][HUT] [HLT][ND]

							5'd4:		{argcnt, outcnt} <= {4'd1, 3'd1};	 //sense drv stat	0000 0100 0000 0HDD

							5'd5:		{argcnt, outcnt} <= {4'd8, 3'd7};	 //write data		TM00 0101 0000 0HDD

							5'd6:		{argcnt, outcnt} <= {4'd8, 3'd7};	 //read data			TMS0 0110 0000 0HDD

							5'd7:		{argcnt, outcnt} <= {4'd1, 3'd0};	 //recalibrate		0000 0111 0000 00DD

							5'd8:		begin
										{argcnt, outcnt} <= {4'd0, 3'd2};	 //sense int stat	0000 1000

										state <= 2'd2;
									end
							5'd9:		{argcnt, outcnt} <= {4'd8, 3'd7};	 //write del data	TM00 1001 0000 0HDD

							5'd10:	{argcnt, outcnt} <= {4'd1, 3'd7};	//read id			0M00 1010 0000 0HDD

							5'd12:	{argcnt, outcnt} <= {4'd8, 3'd7};	//read del data		TMS0 1100 0000 0HDD

							5'd13:	{argcnt, outcnt} <= {4'd5, 3'd7};	//format track		0M00 1101 0000 0HDD

							5'd15:	{argcnt, outcnt} <= {4'd2, 3'd0};	//seek				0000 1111 0000 0HDD [NCN]

							5'd17:	{argcnt, outcnt} <= {4'd8, 3'd7};	//scan equal		TMS1 0001 0000 0HDD

							5'd25:	{argcnt, outcnt} <= {4'd8, 3'd7};	//scan low			TMS1 1001 0000 0HDD

							5'd29:	{argcnt, outcnt} <= {4'd8, 3'd7};	//scan high			TMS1 1101 0000 0HDD

							default:	begin
										{argcnt, outcnt} <= {4'd0, 3'd1};	//invalid

										state <= 2'd2;
									end
						endcase
					end
				end
		2'd1:	if ((iAdr[1:0] == 2'd1) && (iRW[0] == 1))
				begin

					args[curcnt] <= iData;
					curcnt <= curcnt + 1;
					argcnt <= argcnt - 1;
					if (argcnt == 1)
						state <= 2;
				end

		2'd2:	begin
			state <= 3;
			status <= 8'd208; //192;
			case (cmd[4:0])

				5'd2:		begin end	 //read track

				5'd3:		begin	 //specify
								NDMA <= args[1][0];
								state <= 0;
								status <= 8'd128;
							end
				5'd4:		begin end	 //sense drv stat

				5'd5:		begin	 //write data
								LBA <= (args[1] * 2 + args[2]) * 18 + args[3] - 1; //(C * 2 + H) * 18 + R - 1 , 80 cylinders, 2 heads, 18 sectors
							
							end
				5'd6:		begin	 //read data
								LBA <= (args[1] * 2 + args[2]) * 18 + args[3] - 1; //(C * 2 + H) * 18 + R - 1 , 80 cylinders, 2 heads, 18 sectors
								oReqRW <= 2'b10;
								//readdisk();
								ST0 <= 8'h00;
								//I8259.doirq(6);
								//oIRQ <= 1'b1;
                        
								dout[0] <= 8'h00;
								dout[1] <= ST1;
								dout[2] <= ST2;
								dout[3] <= args[1];
								dout[4] <= args[2];
								dout[5] <= args[3];
								dout[6] <= args[4];
							end
				5'd7:		begin	 //recalibrate
								track[args[0][1:0]] <= 0;
								state <= 0;
								status <= 8'd128;
								ST0 <= 8'hC0;
								//I8259.doirq(6);
								oIRQ <= 1'b1;
							end
				5'd8:		begin	 //sense int stat
								dout[0] <= ST0;
								dout[1] <= PCN;
							end
				5'd9:		begin end	 //write del data

				5'd10:	begin end	//read id

				5'd12:	begin end	//read del data


				5'd13:	begin end	//format track

				5'd15:	begin	//seek
								H[args[0][1:0]] <= args[0][2];
								NCN[args[0][1:0]] <= args[1];
								state <= 0;
								status <= 8'd128;
								ST0 <= 8'hC0;
								//I8259.doirq(6);
								oIRQ <= 1'b1;
							end
				5'd17:	begin end	//scan equal

				5'd25:	begin end	//scan low

				5'd29:	begin end	//scan high

				default:	begin end

			endcase
			curcnt = 0;
			end

		2'd3:	if ((iAdr[1:0] == 2'd1) && (iRW[1] == 1))
				begin
					oData <= dout[curcnt];
					oAck <= 1;
					curcnt <= curcnt + 1;
					outcnt <= outcnt - 1;
					if (outcnt == 1)
					begin
						state <= 0;
						status <= 8'd128;
					end
				end

	endcase

end

endmodule

