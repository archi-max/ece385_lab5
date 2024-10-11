//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Given Code - SLC-3 core
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015 
//    Revised 06-09-2020
//	  Revised 03-02-2021
//    Xilinx vivado
//    Revised 07-25-2023 
//    Revised 12-29-2023
//    Revised 09-25-2024
//------------------------------------------------------------------------------

module cpu (    
    input   logic        clk,
    input   logic        reset,

    input   logic        run_i,
    input   logic        continue_i,
    output  logic [15:0] hex_display_debug,
    output  logic [15:0] led_o,

    input   logic [15:0] mem_rdata,
    output  logic [15:0] mem_wdata,
    output  logic [15:0] mem_addr,
    output  logic        mem_mem_ena,
    output  logic        mem_wr_ena
);


// Internal connections, follow the datapath block diagram and add the additional needed signals
logic ld_mar; 
logic ld_mdr; 
logic ld_ir; 
logic ld_pc; 
logic ld_led;
logic ld_reg;
logic [1:0] ld_adder2mux;
logic ld_adder1mux;
logic [1:0] ld_aluk;
logic [1:0] ld_pcmux;
logic ld_reg_mux_u;
logic ld_reg_mux_d;
logic mio_en;

logic gate_pc;
logic gate_mdr;
logic gate_marmux;
logic gate_alu;


logic [15:0] mar; 
logic [15:0] mdr;
logic [15:0] ir;
logic [15:0] pc;
logic [15:0] dataout;
logic ben;
logic n;
logic z;
logic p;
logic ld_cc;
logic [2:0] c_val; // nzp signal bus
logic [15:0] alu_o;
logic [2:0] dr;
logic [2:0] sr1;
logic [2:0] sr2;
logic [15:0] sr2_reg_o;


logic [15:0] sr1_o;
logic [15:0] sr2_o;
logic [15:0] adder2mux_o;
logic [15:0] adder1mux_o;
logic [15:0] pcmux_o;
logic [15:0] adder_o;

logic [15:0] mdr_mux_o;

logic signed [15:0] st_11;
logic signed [15:0] st_9; 
logic signed [15:0] st_6;
logic signed [15:0] st_5;


assign mem_addr = mar;
assign mem_wdata = mdr;

always_comb
    begin
     c_val[1] = dataout == 16'b0 ? 1'b1 : 1'b0; // Zero flag
    c_val[2] = dataout[15];  // Negative flag
    c_val[0] = dataout == 16'b0 ? 1'b0 : !dataout[15];   
end


// State machine, you need to fill in the code here as well
// .* auto-infers module input/output connections which have the same name
// This can help visually condense modules with large instantiations, 
// but can also lead to confusing code if used too commonly
control cpu_control (
    .clk  (clk),
    .reset (reset),
    .ir(ir),
    .ben(ben),
    .continue_i(continue_i),
    .run_i(run_i),
    .ld_mar(ld_mar),
    .ld_mdr(ld_mdr),
    .ld_ir(ld_ir),
    .ld_pc(ld_pc),
    .ld_led(ld_led),
    .ld_reg(ld_reg),
    .ld_cc(ld_cc),	
    .mio_en(mio_en),	
    .ld_adder2mux(ld_adder2mux),
    .ld_adder1mux(ld_adder1mux),
    .ld_reg_mux_u(ld_reg_mux_u),	

    .ld_reg_mux_d(ld_reg_mux_d),

    .ld_aluk(ld_aluk),
    
    .gate_pc(gate_pc),
    .gate_mdr(gate_mdr),		
    .ld_pcmux(ld_pcmux),
    .gate_alu(gate_alu),
    .gate_marmux(gate_marmux),
    .n(n),
    .z(z),
    .p(p),
    .mem_mem_ena(mem_mem_ena),
    .mem_wr_ena(mem_wr_ena) 
);


assign led_o = ir;
assign hex_display_debug = ir;


always_comb begin
    ben = ir[11] & n | ir[10] & z | ir[9] & p;
end


module sign_extend(
    input logic [10:0] in_11,  // 11-bit input
    input logic [8:0]  in_9,   // 9-bit input
    input logic [5:0]  in_6,   // 6-bit input
    input logic [4:0]  in_5,   //5-bit input
    output logic signed [15:0] out_16_1, // 16-bit output for 11-bit input
    output logic signed [15:0] out_16_2, // 16-bit output for 9-bit input
    output logic signed [15:0] out_16_3,  // 16-bit output for 6-bit input
    output logic signed [15:0] out_16_4  // 16-bit output for 5-bit input
);

    // Perform sign extension by assigning to signed outputs
    always_comb begin
        out_16_1 = $signed(in_11);
        out_16_2 = $signed(in_9);
        out_16_3 = $signed(in_6);
        out_16_4 = $signed(in_5);
    end

endmodule

module Addr2Mux(
    input logic [15:0] a,
    input logic [15:0] b,
    input logic [15:0] c,
    input logic [15:0] d,
    input logic [1:0] select,
    output logic [15:0] out
);
    always_comb begin
        case (select)
            2'b00: out = a;
            2'b01: out = b;
            2'b11: out = c;
            2'b10: out = d;
            default: out = 16'b0;
        endcase
    end
endmodule

module Addr1Mux(
    input logic [15:0] a,
    input logic [15:0] b,
    input logic select,
    output logic [15:0] out
);
    always_comb begin
        case (select)
            2'b1: out = a;
            2'b0: out = b;
            default: out = 16'b0;
        endcase
    end
endmodule


module Sr2Mux(
    input logic [15:0] a,
    input logic [15:0] b,
    input logic select,
    output logic [15:0] out
);
    always_comb begin
        case (select)
            1'b1: out = a;
            1'b0: out = b;
            default: out = 16'b0;
        endcase
    end
endmodule

module Pc_Mux(
    input logic [15:0] a,
    input logic [15:0] b,
    input logic [15:0] c,
    input logic [1:0] select,
    output logic [15:0] out
);
    always_comb begin
        case(select)
            2'b00: out = a;
            2'b01: out = b;
            2'b11: out = c;
        endcase
    end
endmodule

module reg_mux_u(
    input logic [2:0] a,
    input logic [2:0] b,
    input logic select,
    output logic [2:0] out
);
    always_comb begin
        case (select)
            1'b1: out = a;
            1'b0: out = b;
            default: out = 16'b0;
        endcase
    end
endmodule

module reg_mux_d(
    input logic [2:0] a,
    input logic [2:0] b,
    input logic select,
    output logic [2:0] out
);
    always_comb begin
        case (select)
            1'b1: out = a;
            1'b0: out = b;
            default: out = 16'b0;
        endcase
    end
endmodule

module mdr_mux(
    input logic [15:0] a,
    input logic [15:0] b,
    input logic select,
    output logic [15:0] out
);
    always_comb begin
        case (select)
            1'b1: out = a;
            1'b0: out = b;
            default: out = 16'b0;
        endcase
    end
endmodule

module alu_c (
    input logic[1:0] aluk,
    input logic[15:0] A_In, B_In,
    output logic[15:0] out
);
    always_comb
        begin
            unique case (aluk)
                2'b00 : out = A_In & B_In;
                2'b01 : out = ~A_In;
                2'b10 : out = A_In + B_In;
                2'b11 : out = A_In;
            endcase;
        end;
endmodule;

module adder (
    input logic[15:0] A_In, B_In,
    output logic[15:0] out
);
    always_comb
        begin
            out = A_In + B_In;
        end;
endmodule;

module register_single(
    input logic  clk,
    input logic load,
    input logic reset,
    input logic [15:0] data_in,
    output logic [15:0] data_out
);
    always_ff @(posedge clk or posedge reset) begin
            if (reset) begin 
                data_out <= 16'b0;
            end else if (load) begin
                data_out <= data_in;
            end
        end
endmodule;

module register_all(
    input logic clk,
    input logic ld_reg,
    input logic reset,
    input logic [2:0] dr,
    input logic [2:0] sr1,
    input logic [2:0] sr2,
    input logic [15:0] data_in,
    output logic [15:0] sr1_o,
    output logic [15:0] sr2_o
);
    logic r0_load, r1_load, r2_load, r3_load, r4_load, r5_load, r6_load, r7_load;
    logic [15:0] r0_data, r1_data, r2_data, r3_data, r4_data, r5_data, r6_data, r7_data;
    register_single r0(.clk(clk), .load(r0_load), .reset(reset), .data_in(data_in), .data_out(r0_data));
    register_single r1(.clk(clk), .load(r1_load), .reset(reset), .data_in(data_in), .data_out(r1_data));
    register_single r2(.clk(clk), .load(r2_load), .reset(reset), .data_in(data_in), .data_out(r2_data));
    register_single r3(.clk(clk), .load(r3_load), .reset(reset), .data_in(data_in), .data_out(r3_data));
    register_single r4(.clk(clk), .load(r4_load), .reset(reset), .data_in(data_in), .data_out(r4_data));
    register_single r5(.clk(clk), .load(r5_load), .reset(reset), .data_in(data_in), .data_out(r5_data));
    register_single r6(.clk(clk), .load(r6_load), .reset(reset), .data_in(data_in), .data_out(r6_data));
    register_single r7(.clk(clk), .load(r7_load), .reset(reset), .data_in(data_in), .data_out(r7_data));
    
    always_comb begin
        unique case(sr1)
            3'b000 : sr1_o <= r0_data;
            3'b001 : sr1_o <= r1_data;
            3'b010 : sr1_o <= r2_data;
            3'b011 : sr1_o <= r3_data;
            3'b100 : sr1_o <= r4_data;
            3'b101 : sr1_o <= r5_data;
            3'b110 : sr1_o <= r6_data;
            3'b111 : sr1_o <= r7_data;  
        endcase
        
        unique case(sr2)
            3'b000 : sr2_o <= r0_data;
            3'b001 : sr2_o <= r1_data;
            3'b010 : sr2_o <= r2_data;
            3'b011 : sr2_o <= r3_data;
            3'b100 : sr2_o <= r4_data;
            3'b101 : sr2_o <= r5_data;
            3'b110 : sr2_o <= r6_data;
            3'b111 : sr2_o <= r7_data;  
            endcase
        end
        
        always_comb begin
            r0_load <= 1'b0;
            r1_load <= 1'b0;
            r2_load <= 1'b0;
            r3_load <= 1'b0;
            r4_load <= 1'b0;
            r5_load <= 1'b0;
            r6_load <= 1'b0;
            r7_load <= 1'b0;
            if (ld_reg) begin
            unique case(dr)
            3'b000 : r0_load <=1'b1;
            3'b001 : r1_load <= 1'b1;
            3'b010 : r2_load <= 1'b1;
            3'b011 : r3_load <= 1'b1;
            3'b100 : r4_load <= 1'b1;
            3'b101 : r5_load <= 1'b1;
            3'b110 : r6_load <= 1'b1;
            3'b111 : r7_load <= 1'b1;  
        endcase
        end
    end
endmodule





            
        

four_to1Mux datapath(.a(pc),
.b(mdr), .c(alu_o),.d(adder_o),.select({gate_pc,gate_mdr, gate_alu, gate_marmux}), .out(dataout));

sign_extend extension_all (
    .in_11   (ir[10:0]),  // 11-bit input
    .in_9    (ir[8:0]),   // 9-bit input
    .in_6    (ir[5:0]),   // 6-bit input
    .in_5    (ir[4:0]),
    .out_16_1 (st_11), // 16-bit output for 11-bit input
    .out_16_2 (st_9), // 16-bit output for 9-bit input
    .out_16_3 (st_6), // 16-bit output for 6-bit input
    .out_16_4 (st_5)
);

load_reg #(.DATA_WIDTH(16)) ir_reg (
    .clk    (clk),
    .reset  (reset),

    .load   (ld_ir),
    .data_i (dataout),

    .data_q (ir)
);

load_reg #(.DATA_WIDTH(1)) n_reg (
    .clk    (clk),
    .reset  (reset),

    .load   (ld_cc),
    .data_i (c_val[2]),

    .data_q (n)
);

load_reg #(.DATA_WIDTH(1)) z_reg (
    .clk    (clk),
    .reset  (reset),

    .load   (ld_cc),
    .data_i (c_val[1]),

    .data_q (z)
);

load_reg #(.DATA_WIDTH(1)) p_reg (
    .clk    (clk),
    .reset  (reset),

    .load   (ld_cc),
    .data_i (c_val[0]),

    .data_q (p)
);

load_reg #(.DATA_WIDTH(16)) pc_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_pc),
    .data_i(pcmux_o),

    .data_q(pc)
);
load_reg #(.DATA_WIDTH(16)) MDR (
    .clk(clk),
    .reset(reset),

    .load(ld_mdr),
    .data_i(mdr_mux_o),

    .data_q(mdr)
);
load_reg #(.DATA_WIDTH(16)) MAR (
    .clk(clk),
    .reset(reset),

    .load(ld_mar),
    .data_i(dataout),

    .data_q(mar)
);

register_all reg_real (
    .clk(clk),
    .reset(reset),
    .ld_reg(ld_reg),
    .dr(dr),
    .sr1(sr1),
    .sr2(ir[2:0]), // sr2 <- IR[2:0]
    .data_in(dataout),
    .sr1_o(sr1_o),
    .sr2_o(sr2_reg_o) 
);

Addr2Mux adder2mux_real (
    .a(st_11),
    .b(st_9),
    .c(st_6),
    .d(16'b0),
    .select(ld_adder2mux),
    .out(adder2mux_o)
);

Addr1Mux adder1mux_real (
    .a(sr1_o),
    .b(pc),
    .select(ld_adder1mux),
    .out(adder1mux_o)
);

Sr2Mux sr2mux_real (
    .a(st_5),
    .b(sr2_reg_o),
    .select(ir[5]), //  ld_sr2mux <-IR[5] 
    .out(sr2_o)
);

Pc_Mux pc_mux_real (
    .a(pc + 1),
    .b(adder_o),
    .c(dataout),
    .select(ld_pcmux),
    .out(pcmux_o)
);

reg_mux_u reg_mux_u_real (
    .a(ir[11:9]),
    .b(3'b111),
    .select(ld_reg_mux_u),
    .out(dr)
);

reg_mux_d reg_mux_d_real (
    .a(ir[11:9]),
    .b(ir[8:6]),
    .select(ld_reg_mux_d),
    .out(sr1)
);

mdr_mux mdr_mux_real (
    .a(dataout),
    .b(mem_rdata),
    .select(mio_en),
    .out(mdr_mux_o)
);

alu_c alu_c_real (
    .aluk(ld_aluk),
    .A_In(sr1_o), 
    .B_In(sr2_o),
    .out(alu_o)
);

adder adder_real (
    .A_In(adder2mux_o), 
    .B_In(adder1mux_o),
    .out(adder_o)
);





endmodule