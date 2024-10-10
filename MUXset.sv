module four_to1Mux(
    input logic [15:0] a,
    input logic [15:0] b,
    input logic [15:0] c,
    input logic [15:0] d,
    input logic [3:0] select, // abcd
    output logic [15:0] out
);
    always_comb begin
        case (select)
            4'b0001: out = d;
            4'b0010: out = c;
            4'b0100: out = b;
            4'b1000: out = a;
            default: out = 16'b0;
        endcase
    end
endmodule

module three_to1Mux(
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
