module IOBusSim
	(
		input							iClk,
		input				[1:0]		iRW,
		input				[15:0]	iAdr,
		input				[15:0]	iData,
		output	reg				oAck,
		output	reg	[15:0]	oData
	);


always @(posedge iClk)
begin
	oAck <= 1'b0;
	if (iRW[0] == 1'b1)
		oData <= iData;
	if (iRW[1] == 1'b1)
		oAck <= 1'b1;
end

endmodule
