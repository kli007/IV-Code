`timescale 1ns/1ps

module pixel_gen(
    input clk,     
    input up,
    input down,
    input left,
    input right,
    output reg [49:0][49:0] chart
    );
    
    // maximum x, y values in display area
    parameter X_MAX = 50;
    parameter Y_MAX = 50;

    integer [49:0] x;
    integer [49:0] y; 
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 50) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)

    wire [9:0] y_pad_t, y_pad_b, x_pad_l, x_pad_r;
    parameter PAD_HEIGHT = 8;  // 72 pixels high
    parameter PAD_WIDTH = 8;
    // register to track top boundary and buffer
    reg [9:0] y_pad_reg, y_pad_next, x_pad_reg, x_pad_next;
    // paddle moving velocity when a button is pressed
    parameter PAD_VELOCITY = 3;     // change to speed up or slow down paddle movement
    parameter i = 0;
    parameter j = 0;

    reg paint [X_MAX:0][Y_MAX:0];

    always @(posedge clk) begin
        y_pad_reg <= y_pad_next;
        x_pad_reg <= x_pad_next;
    end
    
    wire pad_on, paint_on;
    wire [11:0] pad_rgb, bg_rgb, paint_rgb;
    
    
    // assign object colors      // gray wall
    assign pad_rgb = 2; 
    assign bg_rgb = 0;       // close to black background
    assign paint_rgb = 1;

    assign y_pad_t = y_pad_reg;                             // paddle top position
    assign y_pad_b = y_pad_t + PAD_HEIGHT - 1; 
    assign x_pad_l = x_pad_reg;                             // paddle top position
    assign x_pad_r = x_pad_l + PAD_WIDTH - 1;                // paddle bottom position
    assign sq_pad_on = (x_pad_l <= x) && (x <= x_pad_r) &&     // pixel within paddle boundaries
                    (y_pad_t <= y) && (y <= y_pad_b);

   always @(posedge clk) begin
        paint[x_pad_reg][y_pad_reg] <= 0;
            //for (i = x_pad_l; i < x_pad_r; i = i + 1)begin
                //for (j = y_pad_t; j < y_pad_b; j = j + 1) begin
                    
                //end
            //end
    end
                    
    // Paddle Control
    always @* begin
        y_pad_next = y_pad_reg;     // no move
        x_pad_next = x_pad_reg;
        if(refresh_tick) begin
            if(up & (y_pad_t > PAD_VELOCITY))
                y_pad_next = y_pad_reg - PAD_VELOCITY;  // move up
            else if(down & (y_pad_b < (Y_MAX - PAD_VELOCITY)))
                y_pad_next = y_pad_reg + PAD_VELOCITY;  // move down
                
            if(left & (x_pad_l > PAD_VELOCITY))
                x_pad_next = x_pad_reg - PAD_VELOCITY;  // move left
            else if(right & (x_pad_r < (X_MAX - PAD_VELOCITY)))
                x_pad_next = x_pad_reg + PAD_VELOCITY;  // move right
                
        end
    end

    assign paint_on = (paint[x][y]);

    always @*
        if(pad_on)
            chart[x][y] = pad_rgb;      // paddle color
        else
            if (paint_on)
                chart[x][y] = paint_rgb;
            else
                chart[x][y] = bg_rgb;
    
endmodule

module genTB();
    reg clk, up, down, left, right;
    wire [49:0][49:0] chart;
    
    pixel_gen pg(
        .clk(clk),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .chart(chart)
    );
    
    initial begin
        clk = 0;
        up = 0;
        down = 0;
        left = 0;
        right = 0;

        $dumpfile("pTB.vcd"); // dump file for waveform analysis
        $dumpvars(0, pGenTB); // dump all variables in the testbench
        
        #5 up = 1; down = 0; left = 0; right = 0; // move up
        #5 up = 0; down = 1; left = 0; right = 0; // move down
        #5 up = 0; down = 0; left = 1; right = 0; // move left
        #5 up = 0; down = 0; left = 0; right = 1; // move right
        
        #10 $stop;
    end
    
    always #1 clk = ~clk;
    // clock signal with a period of 2 time units   
    always @(posedge clk) begin
        $display("Chart: %b", chart);
    end

endmodule