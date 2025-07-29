`timescale 1ns / 1ps

module pixel_gen(
    input clk,  
    input reset,    
    input up,
    input down,
    input left,
    input right,
    input swt,
    input video_on,
    input [9:0] x,
    input [9:0] y,
    output reg [11:0] rgb
    );
    
    // maximum x, y values in display area
    parameter X_PIX = 640;
    parameter Y_PIX = 480; //1920 x 1080, 640 x 480
    
    parameter X_MAX = X_PIX - 1;
    parameter Y_MAX = Y_PIX - 1;
    
    
    parameter TOTAL_PIX = X_PIX * Y_PIX; //The total amount of pixels on the screen
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    

    
    // PADDLE
    // paddle horizontal boundaries    // 4 pixels wide
    // paddle vertical boundary signals
    wire [9:0] y_pad_t, y_pad_b, x_pad_l, x_pad_r;
    parameter PAD_HEIGHT = 8;  // 72 pixels high
    parameter PAD_WIDTH = 8;
    // register to track top boundary and buffer
    reg [9:0] y_pad_reg, y_pad_next, x_pad_reg, x_pad_next;
    // paddle moving velocity when a button is pressed
    parameter PAD_VELOCITY = 1;     // change to speed up or slow down paddle movement
    
    // BALL
    // square rom boundaries
    
    // round ball from square image
    wire [2:0] rom_addr, rom_col;   // 3-bit rom address and rom column
    reg [7:0] rom_data;             // data at current rom address
    wire rom_bit;                   // signify when rom data is 1 or 0 for ball rgb control
    
    //PAINT SECTION
    
    reg paint_we, paint_din;
    wire paint_dout; 
    reg [18:0] paint_addr; //write enable, data in, data out, and address of paint
    
    (* ram_style = "block" *) reg paint_mem [0: TOTAL_PIX -1]; //the actual memory of paint
    
    wire [9:0] x_safe = (x >= X_PIX)? X_PIX - 1 : x;
    wire [9:0] y_safe = (y >= Y_PIX)? Y_PIX - 1 : y;
    
    wire [18:0] paint_vga_addr = y_safe * X_PIX + x_safe; //coordinate address  for buffer
    assign paint_dout = (x < X_PIX & y < Y_PIX) ? paint_mem[paint_vga_addr] : 0; //assigning to special pixel of mem, checking if colored
    
    reg paint_clear;
    reg [18:0] paint_clear_addr; //check if the paint needs to be reset, the address for reser process
    
    wire [18:0] paint_index = y_pad_reg * X_PIX + x_pad_reg;
    wire paint_pix = refresh_tick && swt; //marking the cursor location as index, checking if the area should be painted
    
    
    // Register Control
    always @(posedge clk) begin
        if(reset) begin
            y_pad_reg <= Y_PIX/2;
            x_pad_reg <= X_PIX/2;
            
            paint_clear <= 1'b1;
            paint_clear_addr <= 0; // once reset is pressed, the clear index will continue until it reach end of total pix and then turn off
        end
        else if (paint_clear) begin
            paint_clear_addr <= paint_clear_addr + 1;
            if (paint_clear_addr == TOTAL_PIX -1)
                paint_clear <= 1'b0;
        end
        else begin
            y_pad_reg <= y_pad_next;
            x_pad_reg <= x_pad_next;
        end
    end
    
    //buffer for paint
    
    always @* begin
       if(paint_clear) begin
           paint_we = 1'b1;
           paint_addr = paint_clear_addr;
           paint_din = 1'b0;// if clearing then writing to all pixels selected by clear address and inputing not painted to them
       end
       else begin
           paint_we = paint_pix;
           paint_addr = paint_index;
           paint_din = 1'b1; // else write to pixel selecetd by index if  paint pix, and write painted
       end
    end
    
    always @(posedge clk)begin
        if (paint_we) 
            paint_mem[paint_addr] <= paint_din; // assigning special pixel to the dinput
    end
    
    // ball rom
    always @* begin
        case(rom_addr)
            3'b000 :    rom_data = 8'b00111100; //   ****  
            3'b001 :    rom_data = 8'b01111110; //  ******
            3'b010 :    rom_data = 8'b11111111; // ********
            3'b011 :    rom_data = 8'b11111111; // ********
            3'b100 :    rom_data = 8'b11111111; // ********
            3'b101 :    rom_data = 8'b11111111; // ********
            3'b110 :    rom_data = 8'b01111110; //  ******
            3'b111 :    rom_data = 8'b00111100; //   ****
        endcase
    end
    
    // OBJECT STATUS SIGNALS
    wire pad_on;
    wire [11:0] pad_rgb, bg_rgb, paint_rgb;
    
    
    // assign object colors      // gray wall
    assign pad_rgb = 12'hAA0; 
    assign bg_rgb = 12'hAAA;       // close to black background
    assign paint_rgb = 12'h111;
    
    // paddle 
    assign y_pad_t = y_pad_reg;                             // paddle top position
    assign y_pad_b = y_pad_t + PAD_HEIGHT - 1; 
    assign x_pad_l = x_pad_reg;                             // paddle top position
    assign x_pad_r = x_pad_l + PAD_WIDTH - 1;                // paddle bottom position
    assign sq_pad_on = (x_pad_l <= x) && (x <= x_pad_r) &&     // pixel within paddle boundaries
                    (y_pad_t <= y) && (y <= y_pad_b);
                     
                
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
    


    // map current pixel location to rom addr/col
    assign rom_addr = y[2:0] - y_pad_t[2:0];   // 3-bit address
    assign rom_col = x[2:0] - x_pad_l[2:0];    // 3-bit column index
    assign rom_bit = rom_data[rom_col];         // 1-bit signal rom data by column
    // pixel within round ball
    assign pad_on = sq_pad_on & rom_bit;      // within square boundaries AND rom data bit == 1
    
    // change ball direction after collision                    
    
    // rgb multiplexing circuit
    always @* begin
        if(~video_on)
            rgb = 12'h000;      // no value, blank
        else if(pad_on)
            rgb = pad_rgb;      // paddle color
        else if (paint_dout)
            rgb = paint_rgb;
        else
            rgb = bg_rgb;       // background
    end
       
endmodule
