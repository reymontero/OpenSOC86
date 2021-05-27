module IOBusExt
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
	oData <= 16'hFFFF;
	if (iRW[1] == 1'b1)
		oAck <= 1'b1;
end

endmodule
