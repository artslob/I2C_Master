`timescale 1ns / 1ps

module server_client(
	input clk,
	input reset,
	input [1:0] sw,
	output wire [31:0] out
   );
	
	wire sda;
	wire scl;
	
	PULLUP pull_up_sda (.O(sda));
	PULLUP pull_up_scl (.O(scl));
	
	I2C server(
		.clk(clk),
		.reset(reset),
		.sw(sw),
		.out(out),
		.scl(scl),
		.sda(sda)
		);
	
	PmodCDC1 client(
		.scl(scl),
		.sda(sda)
	);

endmodule
