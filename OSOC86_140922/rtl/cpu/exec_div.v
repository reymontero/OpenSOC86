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


module exec_div
	(
		input							iClk,
		
		input				[2:0]		iExec,
		input				[3:0]		iFunc,
		input							iBW,
		input							iESel,
		
		input				[15:0]	R1,
		input				[15:0]	R2,
		
		input				[15:0]	iDX,
		
		input							iStall,
		
		output	reg	[15:0]	divOut,
		output	reg	[15:0]	divRem,
		
		output	reg				oStallD,
		output	reg				oDivErr
	);




wire [15:0] Quotient;
wire [15:0] Remain;
wire divAck;
wire divErr;

reg preReq;
wire divReq = ((iExec == 3'd5) && (iFunc[0] == 1'b0)) ? 1'b1 : 1'b0;

//reg [15:0] divOut;
//reg [15:0] divRem;
reg divBW;
reg divAAM;

Divider Divider_inst
(
	.iClk(iClk) ,	// input  iClk_sig
	.iStall(iStall) ,	// input  iStall_sig
	.iReq(divReq & ~preReq) ,	// input  iReq_sig
	.iSgn(iESel) ,	// input  iSgn_sig
	.iBW(iBW) ,	// input  iBW_sig
	.iNumer({iDX, R2}) ,	// input [31:0] iNumer_sig
	.iDenom(R1) ,	// input [15:0] iDenom_sig
	.oQuotient(Quotient) ,	// output [15:0] oQuotient_sig
	.oRemain(Remain) ,	// output [15:0] oRemain_sig
	.oAck(divAck) ,	// output  oAck_sig
	.oErr(divErr) 	// output  oErr_sig
);

initial
begin
	oStallD <= 1'b0;
	preReq <= 1'b0;
end

always @(posedge iClk)
begin
	preReq <= divReq & ~iStall;
	if (iExec == 3'd5)
	begin
		divBW <= iBW;
		divAAM <= iFunc[1];
	end
	if (divReq & ~preReq)
		oStallD <= 1'b1;	
	
	oDivErr <= 1'b0;
	if (divAck == 1'b1)
	begin
		oStallD <= 1'b0;
		if ((divAAM == 1'b1) && (divErr == 1'b0))
			divOut <= {Quotient[7:0], Remain[7:0]};
		else if ((divBW == 1'b0) && (divErr == 1'b0))
			divOut <= {Remain[7:0], Quotient[7:0]};
		else
			divOut <= Quotient;
		divRem <= Remain;
		oDivErr <= divErr;
	end
	if ((iExec == 3'd5) && (iFunc == 4'd1))
		divOut <= divRem;
end

endmodule
