module ps2_mouse_interface (
    input clk,
    input rst,
    input ps2_clk,
    input ps2_data,
    output reg signed [8:0] x_increment,
    output reg signed [8:0] y_increment,
    output reg left_button,
    output reg right_button
);

    reg [7:0] byte_data[2:0];
    reg [1:0] byte_count = 0;
    reg [10:0] shift_reg = 0;
    reg [3:0] bit_count = 0;
    reg prev_ps2_clk = 1;

    always @(posedge clk) begin
        prev_ps2_clk <= ps2_clk;

        if (rst) begin
            bit_count <= 0;
            byte_count <= 0;
        end else if (prev_ps2_clk && !ps2_clk) begin  // Falling edge of PS/2 clock
            shift_reg <= {ps2_data, shift_reg[10:1]};
            bit_count <= bit_count + 1;

            if (bit_count == 10) begin // Full frame received (1 start + 8 data + 1 parity)
                bit_count <= 0;
                byte_data[byte_count] <= shift_reg[8:1]; // Data bits
                byte_count <= byte_count + 1;

                if (byte_count == 2) begin
                    // Extract and sign-extend data
                    left_button  <= byte_data[0][0];
                    right_button <= byte_data[0][1];

                    x_increment <= {byte_data[0][4], byte_data[1]}; // X sign + X delta
                    y_increment <= {byte_data[0][5], byte_data[2]}; // Y sign + Y delta

                    byte_count <= 0;
                end
            end
        end
    end
endmodule