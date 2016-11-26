`timescale 1ns / 1ps

module Lab2(
	input clk,
	input reset,
	input [1:0] sw,
	output reg [15:0] leds,
	inout wire sda,
	output wire scl
   );
	
	wire [15:0] out;
	wire [7:0] id;
	wire i2c_clk;
	
	reg [31:0] counter = 0;
		
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
	
	always@(posedge i2c_clk) begin
		counter <= counter + 1;
		case(sw)
			0: begin
				leds[7:0] <= id[7:0];
				leds[15:8] <= 8'h00;
			end
			
			1: begin
				leds[15:0] <= out[15:0];
			end
			
			2: begin
				if (counter >= 2000000) begin
					leds <= leds + 1;
					counter <= 0;
				end
			end
			
			3: begin
				leds <= 16'hFFFF;
			end
		endcase
	end

endmodule
