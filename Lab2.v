`timescale 1ns / 1ps

module Lab2(
	input clk,
	input reset,
	input [1:0] sw,
	output reg [15:0] leds
   );
	
	wire [31:0] out;
	wire i2c_clk;
	wire sda;
	wire scl;
		
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
	
	always@* begin
		case(sw)
			0: leds <= 0;
			1: begin
				leds[11:0] <= out[31:20];
				leds[15:12] <= 0;
			end
			
			2: begin
				leds[11:0] <= out[15:4];
				leds[15:12] <= 0;
			end
			
			3: begin
				if (out[31:20] >= 0) leds[0] <= 1;
				else leds[0] <= 0;
				if (out[15:4] >= 0) leds[1] <= 1;
				else leds[1] <= 0;
			end
		endcase
	end

endmodule
