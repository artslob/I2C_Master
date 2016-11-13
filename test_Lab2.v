`timescale 1ns / 1ps

module test_Lab2;

	// Inputs
	reg clk;
	reg reset;
	reg [1:0] sw;

	// Outputs
	wire [15:0] leds;

	// Instantiate the Unit Under Test (UUT)
	Lab2 uut (
		.clk(clk), 
		.reset(reset), 
		.sw(sw), 
		.leds(leds)
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
		sw = 0;

		// Wait 100 ns for global reset to finish
		#1000;
        
		// Add stimulus here
		reset = 0;
	end
      
endmodule

