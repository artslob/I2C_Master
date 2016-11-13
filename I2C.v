`timescale 1ns / 1ps

module I2C(
	input clk,
	input reset,
	input [1:0] sw,
	output reg [31:0] out,
	output wire scl,
	inout wire sda
	);
	
	localparam STATE_IDLE = 0;
	localparam STATE_START = 1;
	localparam STATE_ADDR = 2;
	localparam STATE_RW = 3;
	localparam STATE_WACK1 = 4;
	localparam STATE_WACK2 = 5;
	localparam STATE_DATA = 6;
	localparam STATE_STOP = 7;
	localparam STATE_GACK1 = 8;
	localparam STATE_GACK2 = 9;
	localparam STATE_SUB_ADDR = 10;
	localparam STATE_START2 = 11;

	reg [7:0] state;
	reg [6:0] addr;
	reg [7:0] sub_addr;
	reg [7:0] count;
	reg [7:0] delay;
	reg [7:0] data;
	reg [7:0] data_count;
	reg rw;
	
	reg scl_enable = 0;
	reg scl_value = 0;
	reg scl_count = 0;
	
	reg sda_enable = 0;
	reg sda_value = 0;
	reg [1:0] sda_count = 0;
	
	assign scl = (scl_enable) ? scl_value : 1;
	
	assign sda = (sda_enable) ? sda_value : 1'bz;
	
	always@(posedge clk) begin
		if (reset == 1) begin
			scl_enable <= 0;
		end 
		else begin
			if (state == STATE_IDLE || state == STATE_START || state == STATE_STOP) begin
				scl_enable <= 0;
			end else begin
				scl_enable <= 1;
			end
		end
	end
	
	always@(negedge clk) begin
		scl_count <= scl_count + 1;
	end
	
	always@(posedge clk) begin
		sda_count <= sda_count + 1;
		if (scl_count == 1) begin
			scl_value <= ~scl_value;
		end
	end
	
	always@(posedge clk) begin
		if (reset == 1) begin
			state <= STATE_IDLE;
			out <= 32'd0;
			addr <= 7'b100_1000;//h90 in 8 bit
			sub_addr <= 8'b0000_0000;
			delay <= 8'd0;
			count <= 8'd0;
			data <= 8'd0;
			sda_enable <= 1;
			sda_value <= 1;
			data_count <= 8'd0;
			rw <= 1'b0;
		end
		else begin
			/* on posedge scl */
			if (sda_count == 0) begin
				case(state)
					STATE_GACK1: begin //8
						if (sda == 0) begin
							if (rw == 1'b0) state <= STATE_SUB_ADDR; //go to 10
							else state <= STATE_DATA;
							count <= 7;
						end
						else state <= STATE_IDLE;
					end
					
					STATE_GACK2: begin //9
						if (delay == 0)begin
							if (sda == 0) begin
								//state <= STATE_DATA; //go to 6
								state <= STATE_START2; //go to 11
								delay <= 1;
							end
							else state <= STATE_IDLE;
						end
					end
					
					STATE_DATA: begin //6
						sda_enable <= 0;	
						data[count] <= sda;
						if (count != 8) begin
							out[data_count * 8 + count] <= sda;
						end
						count <= count - 1;
					end
				endcase
			end
			/* on negedge scl*/
			if (sda_count == 2) begin
				case(state)
					STATE_RW: begin //3
						if (delay == 0) begin
							state <= STATE_GACK1; //go to 8
							sda_enable <= 0;
						end
					end
					
					STATE_GACK2: begin //9
						sda_enable <= 0;
					end
					
					STATE_DATA: begin //6
						if (count == 255) begin
							data_count <= data_count - 1;
							if(data_count == 0) begin
								//sda_enable <= 1;
								//sda_value <= 0;
								state <= STATE_WACK2; //go to 5 - last wack
								sda_enable <= 0;
								delay <= 1;
							end else begin
								sda_enable <= 1;
								sda_value <= 0;
								state <= STATE_WACK1;
							end
						end
					end
					
					STATE_WACK1: begin //4
						state <= STATE_DATA;
						count <= 7;
						sda_enable <= 0;
					end
				endcase
			end
			
			/* between scl */
			if (sda_count == 3) begin
				case(state)
					STATE_IDLE: begin //0
						sda_enable <= 1;
						sda_value <= 1;
						state <= STATE_START;
					end
					
					STATE_START: begin //1
						sda_value <= 0;
						state <= STATE_ADDR;
						count <= 6;
					end
					
					STATE_ADDR: begin //2
						sda_value <= addr[count];				
						count <= count - 1;
						if (count == 0) begin
							delay <= 1;
							state <= STATE_RW;
						end
					end
					
					STATE_RW: begin //3
						sda_value <= rw; //write sub_addr
						data_count <= 3;
						delay <= delay - 1;
					end
					
					STATE_GACK1: begin //8
						sda_enable <= 0;
					end
					
					STATE_SUB_ADDR: begin //10
						sda_enable <= 1;
						sda_value <= sub_addr[count];
						if (count == 0) begin
							state <= STATE_GACK2; //go to 9
							delay <= 1;
						end
						count <= count - 1;
					end
					
					STATE_GACK2: begin //9
						delay <= delay - 1;
						sda_enable <= 0;
					end
					
					STATE_START2: begin //11
						sda_enable <= 1;
						sda_value <= 1;
					end
					
					STATE_WACK1: begin //4
						sda_enable <= 1;
						sda_value <= 0;
					end
					
					STATE_WACK2: begin //5
						sda_enable <= 0;
						delay <= delay - 1;
						if (delay == 0) begin
							state <= STATE_STOP;
							sda_enable <= 1;
							sda_value <= 0;
						end
					end
					
					STATE_STOP: begin //7
						sda_value <= 1;
						rw <= 0;
						state <= STATE_IDLE;
					end
					
				endcase
			end
			
			/* in middle of scl */
			if (sda_count == 1) begin
				case(state)
					STATE_START2: begin //11
						delay <= delay - 1;
						if (delay == 0) begin
							sda_value <= 0;
							state <= STATE_ADDR;
							rw <= 1;
							count <= 6;
						end
					end
				endcase
			end
		end
	end

endmodule

/* this where server receive */
	/*always@(posedge scl) begin
		case(state)
			STATE_GACK2: begin //9
				if (sda == 0) begin
					state <= STATE_SUB_ADDR; //go to 10
					sda_enable <= 1;
					sda_value <= 0;
				end else begin
					state <= STATE_IDLE; //go to 0
				end
				count <= 7;
			end
			
			STATE_DATA: begin //6
				sda_enable <= 0;	
				data[count] <= sda;
				if (4 <= data_count && data_count <= 7 && count != 8) begin
					out[(data_count - 4) * 8 + count] = sda;
				end
				count <= count - 1;
			end
		endcase
	end*/
	
		/*always@(negedge scl) begin
		case(state)
			STATE_DATA: begin //6
				if (count == 255) begin
					data_count <= data_count - 1;
					if(data_count == 0) begin
						sda_enable <= 1;
						sda_value <= 0;
						state <= STATE_WACK2;
					end else begin
						sda_enable <= 1;
						sda_value <= 0;
						state <= STATE_WACK1;
					end
				end
			end
			
			STATE_WACK1: begin //4
				state <= STATE_DATA;
				count <= 7;
				sda_enable <= 0;
			end
			
			STATE_GACK1: begin //8
				sda_enable <= 0;
				state <= STATE_GACK2; //go to 9
			end
		endcase
	end*/
