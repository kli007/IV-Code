`timescale 1ns/1ps
module tb_binary_multipier;

    reg a0, a1, b0, b1;
    wire x0, x1, x2, x3;

    binary_multiplier bm(a0, a1, b0, b1, x0, x1, x2, x3);

    initial begin
        $display("Testing all combinations of number a and b");
        $monitor("a0=%b, a1=%b, b0=%b, b1=%b, x0=%b, x1=%b, x2=%b, x3=%b", a0, a1, b0, b1, x0, x1, x2, x3);

        a0 = 0; a1 = 0; b0 = 0; b1 = 0; #10;
        a0 = 0; a1 = 0; b0 = 0; b1 = 1; #10;
        a0 = 0; a1 = 0; b0 = 1; b1 = 0; #10;
        a0 = 0; a1 = 0; b0 = 1; b1 = 1; #10;
        a0 = 0; a1 = 1; b0 = 0; b1 = 0; #10;
        a0 = 0; a1 = 1; b0 = 0; b1 = 1; #10;
        a0 = 0; a1 = 1; b0 = 1; b1 = 0; #10;
        a0 = 0; a1 = 1; b0 = 1; b1 = 1; #10;
        a0 = 1; a1 = 0; b0 = 0; b1 = 0; #10;
        a0 = 1; a1 = 0; b0 = 0; b1 = 1; #10;
        a0 = 1; a1 = 0; b0 = 1; b1 = 0; #10;
        a0 = 1; a1 = 0; b0 = 1; b1 = 1; #10;
        a0 = 1; a1 = 1; b0 = 0; b1 = 0; #10;
        a0 = 1; a1 = 1; b0 = 0; b1 = 1; #10;
        a0 = 1; a1 = 1; b0 = 1; b1 = 0; #10;
        a0 = 1; a1 = 1; b0 = 1; b1 = 1; #10;

        $finish;
    end
endmodule
