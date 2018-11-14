
//module draw_target_k #(parameter ADDR_WIDTH=8, DATA_WIDTH=8, WIDTH=40,HEIGHT=30, MEMFILE="") (
//  input wire clk,
//  input wire w_write,
//  input wire [10:0] w_current_x,
//  input wire [10:0] w_current_y,
//  input wire [10:0] w_pos_x,
//  input wire [10:0] w_pos_y,
//  output reg [DATA_WIDTH-1:0] r_out_data
//  );

//  wire [ADDR_WIDTH-1:0] w_address;
//  wire [DATA_WIDTH-1:0] w_data;

//  sram #(
//        .ADDR_WIDTH(ADDR_WIDTH),
//        .DATA_WIDTH(DATA_WIDTH),
//        .DEPTH(WIDTH*HEIGHT),
//        .MEMFILE(MEMFILE))
//        vram_read (
//        .w_addr(address),
//        .clk(clk),
//        .w_write(0),
//        .w_in_data(0),
//        .r_out_data(data)
//    );

//  assign w_write = (((w_pos_x <= w_current_x) && (w_current_x < w_pos_x + WIDTH)) &&
//                    ((w_pos_y <= w_current_y) && (w_current_y < w_pos_y + HEIGHT)));
//  assign address = (w_write) ? ((w_current_y - w_pos_y) * WIDTH + (w_current_x - w_pos_x)) : 0;
//  always @(posedge clk) r_out_data <= w_data;
//endmodule