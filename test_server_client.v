`timescale 1ns / 1ps

module test_server_client;

	// Inputs
	reg clk;
	reg reset;
	reg [1:0] sw;

	// Outputs
	wire [31:0] out;

	// Instantiate the Unit Under Test (UUT)
	server_client serv_cli (
		.clk(clk), 
		.reset(reset), 
		.sw(sw), 
		.out(out)
	);
	
	initial begin
		clk = 0;
		forever begin
			clk = #1 ~clk;
		end
	end

	initial begin
		// Initialize Inputs
		reset = 1;
		sw = 0;
		// Wait 100 ns for global reset to finish
		#10; 
		// Add stimulus here
		reset = 0;
	end
      
endmodule

