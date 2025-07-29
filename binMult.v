`timescale 1ns/1ps
module binary_multiplier(a0, a1, b0, b1, x0, x1, x2, x3);
    input a0, a1, b0, b1;
    output wire x0, x1, x2, x3;

    assign x0 = a0 & a1 & b0 & b1;
    assign x1 = (a0 & ~a1 &b0) | (a0 & b0 & ~b1);
    assign x2 = (a0 & ~a1 & b1) | (a0 & ~b0 & b1) | (~a0 & a1 & b0) | (a1 & b0 & ~b1);
    assign x3 = a1 & b1;

    endmodule