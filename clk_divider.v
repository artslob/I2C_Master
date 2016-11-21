`timescale 1ns / 1ps

module clk_divider(
	input reset,
   input wire clk,
	output reg clk_out
	);
	
localparam DELAY = 800;

reg [15:0] count = 0;
reg flag = 0;
	
always@(clk) begin
	if (reset == 1 && flag == 0) begin
		clk_out <= 0;
		flag <= 1;
	end
	else begin
		if (count == DELAY) begin
			count <= 0;
			clk_out <= ~clk;
		end
		else begin
			count <= count + 1;
		end
	end
end

endmodule
