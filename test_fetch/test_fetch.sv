//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2024 07:44:47 PM
// Design Name: 
// Module Name: test_fetch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_fetch( );
    timeunit 10ns;	// This is the amount of time represented by #1 
	timeprecision 1ns;
	
	logic		clk;
	logic 		reset;
	logic 		run_i;
	logic 		continue_i;
	logic [15:0] sw_i;
	logic [15:0] led_o;
	logic [7:0]  hex_seg_left;
	logic [3:0]  hex_grid_left;
	logic [7:0]  hex_seg_right;
	logic [3:0]  hex_grid_right;
	
	processor_top process(.*);
	initial begin: CLOCK_INITIALIZATION
		clk = 0;
	end
	always begin: CLOCK_GENERATION
		#1 clk = ~clk;
	end
	
	initial begin: TEST_VECTORS
	//Initialization
	   
	   
	   repeat (5) @(posedge clk) begin
       reset = 1;
	   run_i = 0;
	   continue_i = 0;
	   sw_i = 16'b0;
       end
	   
	   
	 //Reset the System
	   repeat (5) @(posedge clk) begin
       reset = 0;
    end

		sw_i = 16'h009C;
	
       
	   repeat (5) @(posedge clk) begin
        run_i = 1;
		end
		repeat (5) @(posedge clk) begin
        run_i = 0;
		end

	repeat (4000) @(posedge clk);

	// #20000;
	 
//   repeat (5) @(posedge clk) begin
//         continue_i = 1;
// 		end
	 
// 	   repeat (5) @(posedge clk) begin
//         continue_i = 0;
// 		end
	 
// 	   repeat (5) @(posedge clk) begin
//         continue_i = 1;
// 		end
	 
// 	   repeat (5) @(posedge clk) begin
//         continue_i = 0;
// 		end

// 		repeat (5) @(posedge clk) begin
//         continue_i = 1;
// 		end
	 
// 	   repeat (5) @(posedge clk) begin
//         continue_i = 0;
// 		end

// 		repeat (5) @(posedge clk) begin
//         continue_i = 1;
// 		end
	 
// 	   repeat (5) @(posedge clk) begin
//         continue_i = 0;
// 		end

// 		repeat (5) @(posedge clk) begin
//         continue_i = 1;
// 		end
	 
// 	   repeat (5) @(posedge clk) begin
//         continue_i = 0;
// 		end
	 

		$finish;
	end
	
endmodule
