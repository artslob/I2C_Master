`timescale 1ns / 1ps

module test_server_client;

	// Inputs
	reg clk;
	reg reset;
	reg [1:0] sw;

	// Outputs
	wire [15:0] out;

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
			clk = #5 ~clk;
		end
	end

	initial begin
		// Initialize Inputs
		reset = 1;
		sw = 1;
		
		#10000; //10000 ns = 10 us
		
		reset = 0;
	end
      
endmodule

