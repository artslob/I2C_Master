`timescale 1ns / 1ps

module test_Lab2_2;

	// Inputs
	reg clk;
	reg reset;
	reg [1:0] sw;

	// Outputs
	wire [15:0] leds;
	wire scl1;
	wire scl2;

	// Bidirs
	wire sda1;
	wire sda2;

	// Instantiate the Unit Under Test (UUT)
	Lab2 uut (
		.clk(clk), 
		.reset(reset), 
		.sw(sw), 
		.leds(leds), 
		.sda1(sda1), 
		.sda2(sda2), 
		.scl1(scl1), 
		.scl2(scl2)
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
		
		#10000; // 1000ns = 1us
        
		// Add stimulus here
		reset = 0;
	end
      
endmodule

