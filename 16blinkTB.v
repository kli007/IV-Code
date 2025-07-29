`timescale 1ns/1ps
module tb_chain_blink;
    reg clk = 0;
    always #5 clk = !clk;
    reg rst = 0;
    reg frz = 0; // freeze signal
    wire [16:0] LED;
    chainBlink cb(LED, clk, rst, frz);

    initial begin
        $dumpfile("16blinkTB.vcd");
        $dumpvars(0, tb_chain_blink);
        $display("Testing chain blink");
       
        #45 rst = 1; // reset the system
        #5 rst = 0; // release reset

        #40 frz = 1; 
        #50 frz = 0; // release freeze

        #100 $finish; // finish 1 cycle simulation after 160 time units
    end
 
    always @(posedge clk) begin
        $display("LED = %4b, Freeze = %b, Reset = %b, Time = %0t", LED, frz, rst, $time);
    end

endmodule