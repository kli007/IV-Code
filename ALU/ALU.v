`timescale 1s/1ms

module simpleALU(clk, F, Q, A, B, X);
    input wire clk; // clock signal
    input wire [1:0] F, Q;
    input wire [3:0] A, B; 

    output reg [3:0] X; // output of ALU

    always @(*) begin
        case(F)
            2'b00: begin // addition
                X <= A + B;
            end
            2'b01: begin // subtraction
                X <= -A;
            end
            2'b10: begin // multiplication
                X <= A << B;
            end
            2'b11: begin // division
                case(Q)
                    2'b00: begin 
                        X <= A & B;
                    end
                    2'b01: begin 
                        X <= A | B;
                    end
                    2'b10: begin 
                        X <= A ^ B;
                    end
                    2'b11: begin 
                        X <= ~A;
                    end
                endcase
            end
            default: begin
                X <= 4'b0000; // default case
            end
        endcase
    end
endmodule

module tb_simple_ALU;
    reg clk = 0;
    always #5 clk = !clk; // 10 time units clock period
    reg [1:0] F = 0; 
    reg [1:0] Q = 0;
    reg [3:0] A = 0; 
    reg [3:0] B = 0; 
    wire [3:0] X; // output of ALU

    simpleALU alu(clk, F, Q, A, B, X); // instantiate ALU

    initial begin
        $dumpfile("simpleALUTB.vcd");
        $dumpvars(0, tb_simple_ALU);
        $display("Testing simple ALU");
        
        #0 A = 4'b0011; B = 4'b0001; F = 2'b00; Q = 2'b00; // addition
        #20 A = 4'b0011; B = 4'b0001; F = 2'b01; Q = 2'b00; // subtraction
        #20 A = 4'b0011; B = 4'b0001; F = 2'b10; Q = 2'b00; // shift left
        #20 A = 4'b0011; B = 4'b0001; F = 2'b11; Q = 2'b00; // AND operation
        #20 A = 4'b0011; B = 4'b0001; F = 2'b11; Q = 2'b11; // NOT operation
        
        
        #20 $finish; // finish simulation after 50 time units
    end

    always @(posedge clk) begin
        $display("A = %b, B = %b, F = %b, Q = %b, X = %b", A, B, F, Q, X);
    end
endmodule
