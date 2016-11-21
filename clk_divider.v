`timescale 1ns / 1ps

module clk_divider(
	input reset,
   input wire clk,
	output reg clk_out
	);
	
localparam DELAY = 800;

reg [15:0] count = 800;
	
always@(clk) begin
	if (count == DELAY) begin
		count <= 0;
		clk_out <= clk;
	end
	else begin
		count <= count + 1;
	end
end

endmodule
