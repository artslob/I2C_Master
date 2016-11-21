`timescale 1ns / 1ps

module server_client(
	input clk,
	input reset,
	input [1:0] sw,
	output wire [15:0] out,
	output wire [7:0] id
   );
	
	wire sda;
	wire scl;
	wire i2c_clk;
	
	PULLUP pull_up_sda (.O(sda));
	PULLUP pull_up_scl (.O(scl));
	
	clk_divider div(
		.reset(reset),
		.clk(clk),
		.clk_out(i2c_clk)
		);
	
	I2C server(
		.clk(i2c_clk),
		.reset(reset),
		.sw(sw),
		.out(out),
		.id(id),
		.scl(scl),
		.sda(sda)
		);
	
	PmodCDC1 client(
		.scl(scl),
		.sda(sda)
	);

endmodule
