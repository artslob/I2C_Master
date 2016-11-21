`timescale 1ns / 1ps

module server_client(
	input clk,
	input reset,
	input [1:0] sw,
	output wire [15:0] out
   );
	
	wire sda;
	wire scl;
	wire i2c_clk;
	
	reg [31:0] tmp = 0;
	
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
		.scl(scl),
		.sda(sda)
		);
	
	PmodCDC1 client(
		.scl(scl),
		.sda(sda)
	);
	
	
	always@(posedge i2c_clk) begin
		tmp <= tmp + 1;
		if (tmp >= 20000000) begin
			tmp <= 0;
		end
	end

endmodule
