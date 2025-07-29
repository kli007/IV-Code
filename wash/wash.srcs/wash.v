`timescale 1ns/1ps

module washMachine(LED, seg, placement, clk, start, drain);
    input clk, start, drain;

    output reg [15:0]LED;
    output reg [0:6]seg;
    output reg [3:0]placement;

    reg [4:0]state;
    reg [1:0]stage = 0;
    reg [1:0]digit = 2'b00;
    reg [3:0]second = 0;
    reg [35:0]Counter = 000_000_000; // counter for timing 
    reg [15:0]LEDcounter = 00_000; 
    reg [3:0] LED_BCD;
    
    wire [15:0]w_LED;
    

    chainBlink cb(.LED(w_LED), .clk(clk), .start(state));
    
    always@(posedge clk) begin
        case(state)
            5'b00001: begin // idle state
                LED <= 16'b0000000000000000;
                if (start == 1) begin
                    state <= 5'b00010; // move to FILL state
                    stage <= 1; // set stage to 1
                end
            end

            5'b00010: begin // FILL state
                //display F on 7-segment
                // led on
                LED <= 16'b0000000000000001; // turn on LED 0
                Counter <= Counter + 1; // increment fill counter
                if (Counter == 100_000_000) begin // wait for 1 second
                    second <= second + 1;
                    Counter <= 000_000_000; // reset fill counter
                    if (second == 10)begin
                        state <= 5'b00100; // move to agitate state
                        LED <= 16'b0000000000000000; // turn off LED 0
                        second <= 0;
                    end
                end
            end

            5'b00100: begin // AGITATE state
                //display A on 7-segment
                // led on
                LED <= 16'b0000000000000010; // turn on LED 1
                Counter <= Counter + 1; // increment agitate counter
                if (Counter == 100_000_000) begin // wait for 1 second
                    second <= second + 1;
                    Counter <= 000_000_000; // reset fill counter
                    if (second == 10)begin
                        state <= 5'b01000; // move to agitate state
                        LED <= 16'b0000000000000000; // turn off LED 0
                        second <= 0;
                    end
                end
            end

            5'b01000: begin // DRAIN state
                //display d on 7-segment
                // led on
                LED <= 16'b0000000000000100; // turn on LED 2
                if (drain == 1) begin
                    if (stage == 1) begin
                        state <= 5'b00010; // move to fill state
                        stage <= 2;
                    end
                    else if (stage == 2) begin
                        state <= 5'b10000; // move to buzz state
                    end
                    LED <= 16'b0000000000000000; // turn off LED 2
                end
            end

            5'b10000: begin // BUZZ state
                //display b on 7-segment
                // sequence the LEDs to blink
                LED <= w_LED;
                Counter <= Counter + 1; // increment buzz counter
                if (Counter == 100_000_000) begin // wait for 1 second
                    second <= second + 1;
                    Counter <= 000_000_000; // reset fill counter
                    if (second == 10)begin
                        state <= 5'b00001; // move to agitate state
                        second <= 0;
                    end
                end
            end
            
            default: begin
                state <= 5'b00001;
            end
        endcase
    end
    
    always@(posedge clk)begin
        LEDcounter <= LEDcounter +1;
        if (LEDcounter == 60_000)begin
            case(digit)
                2'b00: begin
                    placement <= 4'b1110;
                    LED_BCD <= second % 10;
                    digit <= 2'b01;
                end
                2'b01: begin
                    placement <= 4'b1101;
                    LED_BCD <= second / 10;
                    digit <= 2'b10;
                end
                2'b10: begin
                    placement <= 4'b1011;
                    digit <= 2'b00;
                end
            endcase
            LEDcounter <= 0;
        end
    end
    
    always@(*) begin
        if (placement == 11) begin
            case(state)
                5'b00001: seg <= 7'b1001111;
                5'b00010: seg <= 7'b0111000; 
                5'b00100: seg <= 7'b0001000;
                5'b01000: seg <= 7'b1000010;
                5'b10000: seg <= 7'b1100000;
            endcase
        end
        else begin
            case(LED_BCD)
                4'b0000: seg = 7'b0000001; // "0"     
                4'b0001: seg = 7'b1001111; // "1" 
                4'b0010: seg = 7'b0010010; // "2" 
                4'b0011: seg = 7'b0000110; // "3" 
                4'b0100: seg = 7'b1001100; // "4" 
                4'b0101: seg = 7'b0100100; // "5" 
                4'b0110: seg = 7'b0100000; // "6" 
                4'b0111: seg = 7'b0001111; // "7" 
                4'b1000: seg = 7'b0000000; // "8"     
                4'b1001: seg = 7'b0000100; // "9" 
                default: seg = 7'b0000001; // "0"
            endcase
        end
    end
endmodule


