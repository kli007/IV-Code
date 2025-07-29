`timescale 1ns/1ps
module bitAdder(a, b, c_in, sum, c_out);
    input a, b, c_in;
    output sum, c_out;
    wire x0, x1, x2, x3, nx0, nx1, nx2, nx3, y0, y1, w0, w1, w2, v0, a_not, b_not, c_in_not;

    or sum, y0, y1;
        or y0, nx0, nx1;
            not nx0, x0;
                nand x0, a_not, b_not, c_in;
                    not a_not, a;
                    not b_not, b;
            not nx1, x1;
                nand x1, a_not, b, c_in_not;
                    not c_in_not, c_in;
        or y1, nx2, nx3;
            not nx2, x2;
                nand x2, a, b_not, c_in_not;
            not nx3, x3;
                nand x3, a, b, c_in;
    not c_out, v0;
        nor v0, w0, w1, w2;
            and w0, a, b;
            and w1, a, c_in;
            and w2, b, c_in;
endmodule




    