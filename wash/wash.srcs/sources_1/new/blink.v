module chainBlink(LED, clk, start);
    input clk;
    input [4:0]start;
    output reg [15:0]LED;
    
    reg [24:0]counter = 00_000_000;
    reg [15:0]state; // 4 bits for 16 states

    
    always @(posedge clk) begin
        if (start == 16) begin
            counter <= counter + 1;
            if (counter == 25_000_000) begin
                case(state) //16 states of led
                    16'b0000000000000001: begin//LED state 1
                        LED <= 16'b0000000000000001; 
                        state <= 16'b0000000000000010;
                    end
                    16'b0000000000000010: begin//LED state 2
                        LED <= 16'b0000000000000010; 
                        state <= 16'b0000000000000100;
                    end
                    16'b0000000000000100: begin//LED state 3
                        LED <= 16'b0000000000000100; 
                        state <= 16'b0000000000001000;
                    end
                    16'b0000000000001000: begin//LED state 4
                        LED <= 16'b0000000000001000; 
                        state <= 16'b0000000000010000;
                    end
                    16'b0000000000010000: begin//LED state 5
                        LED <= 16'b0000000000010000; 
                        state <= 16'b0000000000100000; 
                    end
                    16'b0000000000100000: begin//LED state 6
                        LED <= 16'b0000000000100000; 
                        state <= 16'b0000000001000000;
                    end
                    16'b0000000001000000: begin//LED state 7
                        LED <= 16'b0000000001000000; 
                        state <= 16'b0000000010000000;
                    end
                    16'b0000000010000000: begin//LED state 8
                         LED <= 16'b0000000010000000; 
                         state <= 16'b0000000100000000;
                    end
                    16'b0000000100000000: begin//LED state 9
                         LED <= 16'b0000000100000000; 
                         state <= 16'b0000001000000000;
                    end
                    16'b0000001000000000: begin//LED state 10
                         LED <= 16'b0000001000000000; 
                         state <= 16'b0000010000000000;
                    end
                    16'b0000010000000000: begin//LED state 11
                         LED <= 16'b0000010000000000; 
                         state <= 16'b0000100000000000;
                    end
                    16'b0000100000000000: begin//LED state 12
                         LED <= 16'b0000100000000000; 
                         state <= 16'b0001000000000000;
                    end
                    16'b0001000000000000: begin//LED state 13
                         LED <= 16'b0001000000000000; 
                         state <= 16'b0010000000000000; 
                    end
                    16'b0010000000000000: begin//LED state 14
                         LED <= 16'b0010000000000000;
                         state <= 16'b0100000000000000; 
                    end
                    16'b0100000000000000: begin//LED state 15
                         LED <= 16'b0100000000000000; 
                         state <= 16'b1000000000000000;
                    end
                    16'b1000000000000000: begin//LED state 16
                         LED <= 16'b1000000000000000; 
                         state <= 16'b0000000000000001;
                    end
                    default: begin // default case to avoid latches
                         state <= 16'b0000000000000001; // reset state
                    end
                endcase 
                counter <= 0;
            end  
        end
    end
endmodule
