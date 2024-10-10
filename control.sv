//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Given Code - Incomplete ISDU for SLC-3
// Module Name:    Control - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//    Revised 07-25-2023
//    Xilinx Vivado
//	  Revised 12-29-2023
// 	  Spring 2024 Distribution
// 	  Revised 6-22-2024
//	  Summer 2024 Distribution
//	  Revised 9-27-2024
//	  Fall 2024 Distribution
//------------------------------------------------------------------------------

module control (
	input logic			clk, 
	input logic			reset,

	input logic  [15:0]	ir,
	input logic			ben,

	input logic 		continue_i,
	input logic 		run_i,

	output logic		ld_mar,
	output logic		ld_mdr,
	output logic		ld_ir,
	output logic		ld_pc,
	output logic        ld_led,
	output logic        ld_reg,
	output logic        ld_cc,
	output logic [1:0] ld_adder2mux,
    output logic    ld_adder1mux,
    output logic  [1:0]  ld_aluk,
    output logic    mio_en,
    output logic    ld_reg_mux_u,
						
	output logic		gate_pc,
	output logic		gate_mdr,
						
	output logic [1:0]	ld_pcmux,
	
	//You should add additional control signals according to the SLC-3 datapath design
	//new_signal
	output logic       gate_alu,
	output logic       gate_marmux,
	output logic n,
    output logic z,
    output logic p,
	
    output logic		ld_reg_mux_d,
	output logic		mem_mem_ena, // Mem Operation Enable
	output logic		mem_wr_ena  // Mem Write Enable
);

	enum logic [4:0] {
		halted, 
		pause_ir1,
		pause_ir2, 
		s_18, 
		s_33_1,
		s_33_2,
		s_33_3,
		s_35,
		s_32,
		s_7,
		s_6,
		s_23,
		s_27,
		s_25_1,
		s_25_2,
		s_25_3,
		s_16_1,
		s_16_2,
		s_16_3,
		s_1,
		s_5,
		s_9,
		s_22,
		s_12,
		s_4,
		s_21,
		s_0
	} state, state_nxt;   // Internal state logic


	always_ff @ (posedge clk)
	begin
		if (reset) 
			state <= halted;
		else 
			state <= state_nxt;
	end
   
	always_comb
	begin 
		
		// Default controls signal values so we don't have to set each signal
		// in each state case below (If we don't set all signals in each state,
		// we can create an inferred latch)
		mem_mem_ena = 1'b0;
		mem_wr_ena = 1'b0;

		ld_mar = 1'b0;
		ld_mdr = 1'b0;
		ld_ir = 1'b0;
		ld_pc = 1'b0;
		ld_led = 1'b0;
		ld_reg = 1'b0;

		gate_pc = 1'b0;
		gate_mdr = 1'b0;
		gate_marmux = 1'b0;
		gate_alu = 1'b0;

		ld_pcmux = 2'b00;
		mio_en = 1'b0;
		ld_aluk = 2'b00;

		ld_adder2mux = 	2'b00;
		ld_adder1mux = 1'b0;
		ld_reg_mux_d = 1'b0;
		ld_reg_mux_u = 1'b0;

		ld_cc = 1'b0;

		// n = 1'b0;
		// z = 1'b0;
		// p = 1'b0;

	
		// Assign relevant control signals based on current state
		case (state)
			halted: ; 
			s_18 : 
				begin 
					gate_pc = 1'b1;
					ld_mar = 1'b1;
					ld_pcmux = 2'b00;
					ld_pc = 1'b1;
				end
			s_33_1, s_33_2, s_33_3 : //you may have to think about this as well to adapt to ram with wait-states
				begin
					mem_mem_ena = 1'b1;
					ld_mdr = 1'b1;
					
				end
			s_35 : 
				begin 
					gate_mdr = 1'b1;
					ld_ir = 1'b1;
				end
			pause_ir1: ld_led = 1'b1; 
			pause_ir2: ld_led = 1'b1; 
			// you need to finish the rest of state output logic..... 
            s_32 :
                begin
					// case (ir[7:4])  
					// 	3'b100:
					// 		begin
					// 			n = 1'b1;
					// 			z = 1'b0;
					// 			p = 1'b0;
					// 		end
					// 	3'b010: 
					// 		begin
					// 			z = 1'b1;
					// 			n = 1'b0;
					// 			p = 1'b0;
					// 		end
					// 	3'b001: 
					// 		begin
					// 			p = 1'b1;
					// 			n = 1'b0;
					// 			z = 1'b0;
					// 		end
					// endcase
                end
            s_6 :
                begin
                    gate_marmux = 1'b1;
                    ld_adder2mux = 2'b11;
                    ld_adder1mux = 1'b1;
                    ld_mar = 1'b1;
                    ld_reg_mux_d = 1'b0;
                end 
            s_25_1, s_25_2, s_25_3 :
                begin
                    mem_mem_ena = 1'b1;
                    ld_mdr = 1'b1;
                end
            s_27 :
                begin
                    gate_mdr = 1'b1;
                    ld_reg = 1'b1;
                    ld_cc = 1'b1;
					ld_reg_mux_u = 1'b1;
                end
			s_5:
				begin
					gate_alu = 1'b1;
                    ld_reg = 1'b1;
                    ld_cc = 1'b1;
					ld_aluk = 2'b00; // AND
					ld_reg_mux_u = 1'b1; // 
					ld_reg_mux_d = 1'b0; // IR[8:6] - SR
					
				end
            s_7 :
                begin
                    gate_marmux = 1'b1;
                    ld_adder2mux = 2'b11;
                    ld_adder1mux = 1'b1;
                    ld_mar = 1'b1;
                    ld_reg_mux_d = 1'b0;
                end 
             s_23 :
                begin
                    ld_reg_mux_d = 1'b1;
					ld_adder1mux = 1'b1;
					ld_adder2mux = 2'b10;
					gate_marmux = 1'b1;
					mio_en = 1'b1;
					ld_mdr = 1'b1;
                end
             s_16_1, s_16_2, s_16_3 :
                begin
                    mem_mem_ena = 1'b1;
                    mem_wr_ena = 1'b1;
                    // ld_mar = 1'b1;
                end
             s_0 :
                begin
                    
                end
             s_22 :
                begin
                    ld_pcmux = 2'b01;
					ld_pc = 1'b1;
                end
             s_12 :
                begin
                    gate_alu = 1'b1;
                    ld_pc = 1'b1;
					ld_pcmux = 2'b01;
					ld_reg_mux_d = 1'b0;
					ld_adder2mux = 2'b10;
					ld_adder1mux = 1'b1;
					
                end
             s_4 :
                begin
                    gate_pc = 1'b1;
                    ld_reg = 1'b1;
					ld_reg_mux_u = 1'b0;
                end
             s_21 :
                begin
                    ld_pc = 1'b1;
					ld_adder1mux = 1'b0;
					ld_adder2mux = 2'b00;
					ld_pcmux = 2'b01;
                end

			s_9:
				begin
					ld_reg_mux_u = 1'b1;
					ld_reg_mux_d = 1'b0;
					ld_aluk = 1'b01;
					gate_alu = 1'b1;
					ld_reg = 1'b1;
					ld_cc = 1'b1;	
				end
			
			s_1:
				begin
					ld_reg_mux_d = 1'b0; // b
					ld_aluk = 2'b10; // +
					gate_alu = 1'b1;
					ld_reg = 1'b1;
					ld_reg_mux_u  = 1'b1;//
					ld_cc = 1'b1;
				end
			default : ;
		endcase
	end 


	always_comb
	begin
		// default next state is staying at current state
		state_nxt = state;

		unique case (state)
			halted : 
				if (run_i) 
					state_nxt = s_18;
			s_18 : 
				state_nxt = s_33_1; //notice that we usually have 'r' here, but you will need to add extra states instead 
			s_33_1 :                 //e.g. s_33_2, etc. how many? as a hint, note that the bram is synchronous, in addition, 
				state_nxt = s_33_2;   //it has an additional output register. 
			s_33_2 :
				state_nxt = s_33_3;
			s_33_3 : 
				state_nxt = s_35;
			s_35 : 
				state_nxt = s_32;
			s_32 :
			case (ir[15:12])
			     4'b0001: 
			         state_nxt = s_1;
			     4'b0101:
			         state_nxt = s_5;
			     4'b1001:
			         state_nxt = s_9;
			     4'b0000:
			         state_nxt = s_0;
			     4'b1100:
			         state_nxt = s_12;
			     4'b0100:
			         state_nxt = s_4;
			     4'b0110:
			         state_nxt = s_6;
			     4'b0111:
			         state_nxt = s_7;
			     4'b1101:
			         state_nxt = pause_ir1;
			endcase
				// $cast(state_nxt, {0, ir[15:12]});
			s_1 :
			     state_nxt = s_18;
			s_5 :
			     state_nxt = s_18;
			s_9 :
			     state_nxt = s_18;
			s_6 :
			     state_nxt = s_25_1;
			s_25_1 :
			     state_nxt = s_25_2;
			s_25_2 :
			     state_nxt = s_25_3;
			s_25_3 :
			     state_nxt = s_27;
			s_27 :
			     state_nxt = s_18;
			s_7 :
			     state_nxt = s_23;
			s_23 :
			     state_nxt = s_16_1;
			s_16_1 :
			     state_nxt = s_16_2;
			s_16_2 :
			     state_nxt = s_16_3;
			s_16_3 :
			     state_nxt = s_18;
			s_0 :
			begin
				if (ben == 1) begin
					state_nxt = s_22;
				end else begin
					state_nxt = s_18;
				end
					//change
			end
			s_22 :
			     state_nxt = s_18;
			s_12 :    
			     state_nxt = s_18;
			s_4 :
			     state_nxt = s_21;
			s_21 :
			     state_nxt = s_18; 
			 
			// pause_ir1 and pause_ir2 are only for week 1 such that TAs can see 
			// the values in ir.
			pause_ir1 : 
				if (continue_i) 
					state_nxt = pause_ir2;
			pause_ir2 : 
				if (~continue_i)
					state_nxt = s_18;
			// you need to finish the rest of state transition logic.....
			
			default :;
		endcase
	end
	
endmodule
