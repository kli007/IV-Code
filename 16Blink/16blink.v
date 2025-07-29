`timescale 1ns/1ps
//need to create clock for 7 segment
module chainBlink(LED, seg, placement, clk, rst, frz);
    input clk, rst, frz;
    output reg [15:0]LED;
    output reg [0:6]seg;
    output reg [3:0]placement = 1110;
    
    reg [24:0]counter = 00_000_000; 
    reg [15:0]LEDcounter = 00_000; 
    reg [15:0]num = 0000;
    reg [15:0]state; // 4 bits for 16 states
    reg [1:0]digit; // 2 bits for 4 digits
    reg [3:0]cNumber;
    
    always @(posedge clk) begin
        counter <= counter + 1;
        if (counter == 25_000_000) begin
            if (rst == 1) begin // reset condition
                state <= 16'b0000000000000001; // reset state
                counter <= 0;
            end 
            else begin
                if (frz == 1) begin // freeze condition
                    state <=  LED; // maintain current state CHECK HERE
                end
                else begin
                    case(state) //16 states of led
                        16'b0000000000000001: begin//LED state 1
                            LED <= 16'b0000000000000001; 
                            state <= 16'b0000000000000010;
                            num <= 0001;
                        end
                        16'b0000000000000010: begin//LED state 2
                            LED <= 16'b0000000000000010; 
                            state <= 16'b0000000000000100;
                            num <= 0002;
                        end
                        16'b0000000000000100: begin//LED state 3
                            LED <= 16'b0000000000000100; 
                            state <= 16'b0000000000001000;
                            num <= 0003;
                        end
                        16'b0000000000001000: begin//LED state 4
                            LED <= 16'b0000000000001000; 
                            state <= 16'b0000000000010000;
                            num <= 0004;
                        end
                        16'b0000000000010000: begin//LED state 5
                            LED <= 16'b0000000000010000; 
                            state <= 16'b0000000000100000; 
                            num <= 0005;
                        end
                        16'b0000000000100000: begin//LED state 6
                            LED <= 16'b0000000000100000; 
                            state <= 16'b0000000001000000;
                            num <= 0006;
                        end
                        16'b0000000001000000: begin//LED state 7
                            LED <= 16'b0000000001000000; 
                            state <= 16'b0000000010000000;
                            num <= 0007;
                        end
                        16'b0000000010000000: begin//LED state 8
                            LED <= 16'b0000000010000000; 
                            state <= 16'b0000000100000000;
                            num <= 0008;
                        end
                        16'b0000000100000000: begin//LED state 9
                            LED <= 16'b0000000100000000; 
                            state <= 16'b0000001000000000;
                            num <= 0009;
                        end
                        16'b0000001000000000: begin//LED state 10
                            LED <= 16'b0000001000000000; 
                            state <= 16'b0000010000000000;
                            num <= 0010;
                        end
                        16'b0000010000000000: begin//LED state 11
                            LED <= 16'b0000010000000000; 
                            state <= 16'b0000100000000000;
                            num <= 0011;
                        end
                        16'b0000100000000000: begin//LED state 12
                            LED <= 16'b0000100000000000; 
                            state <= 16'b0001000000000000;
                            num <= 0012;
                        end
                        16'b0001000000000000: begin//LED state 13
                            LED <= 16'b0001000000000000; 
                            state <= 16'b0010000000000000; 
                            num <= 0013;
                        end
                        16'b0010000000000000: begin//LED state 14
                            LED <= 16'b0010000000000000;
                            state <= 16'b0100000000000000; 
                            num <= 0014;
                        end
                        16'b0100000000000000: begin//LED state 15
                            LED <= 16'b0100000000000000; 
                            state <= 16'b1000000000000000;
                            num <= 0015;
                        end
                        16'b1000000000000000: begin//LED state 16
                            LED <= 16'b1000000000000000; 
                            state <= 16'b0000000000000001;
                            num <= 0016;
                        end
                        default: begin // default case to avoid latches
                            state <= 16'b0000000000000001; // reset state
                        end
                    endcase 
                end
            end
            counter <= 0;
        end  
    end

    always@(posedge clk) begin
        LEDcounter <= LEDcounter + 1;
        if (LEDcounter == 60_000)begin
            case(digit)
                2'b00: begin
                    placement = 4'b0111;
                    cNumber = num/1000;
                    digit <= 2'b01;
                end
                2'b01: begin
                    placement = 4'b1011;
                    cNumber = (num%1000)/100;
                    digit <= 2'b10;
                end
                2'b10: begin
                    placement = 4'b1101;
                    cNumber = ((num%1000)%100)/10;
                    digit <= 2'b11;
                end
                2'b11: begin
                    placement = 4'b1110;
                    cNumber = ((num%1000)%100)%10;
                    digit <= 2'b00;
                end
            endcase
            LEDcounter <= 0;
        end
    end

    always@(*)begin
        case(cNumber)
            4'b0000: seg <= 7'b0000001;
            4'b0001: seg <= 7'b1001111; 
            4'b0010: seg <= 7'b0010010;
            4'b0011: seg <= 7'b0000110;
            4'b0100: seg <= 7'b1001100;
            4'b0101: seg <= 7'b0100100;
            4'b0110: seg <= 7'b0100000;
            4'b0111: seg <= 7'b0001111;
            4'b1000: seg <= 7'b0000000;
            4'b1001: seg <= 7'b0000100;
        endcase
    end
    
endmodule

