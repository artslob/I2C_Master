`timescale 1ns / 1ps

module clk_divider(
	input reset,
   input wire clk,
	output reg clk_out
	);
	
localparam DELAY_L = 1000;
localparam DELAY_H = 2000;

reg [15:0] count = 0;
	
always@(posedge clk) begin
	count <= count + 1;
	if (count <= DELAY_L) begin
		clk_out <= 0;
	end
	else if (count <= DELAY_H) begin
		clk_out <= 1;
	end
	else begin
		count <= 0;
	end
end

endmodule
