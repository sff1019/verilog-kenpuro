`timescale 1ns / 1ps

module sram #(parameter ADDR_WIDTH=8, DATA_WIDTH=8, DEPTH=256, MEMFILE="") (
    input wire clk,
    input wire [ADDR_WIDTH-1:0] i_addr,
    input wire i_write,
    input wire [DATA_WIDTH-1:0] i_data,
    output reg [DATA_WIDTH-1:0] o_data
    );

    reg [DATA_WIDTH-1:0] memory_array [0:DEPTH-1];

    initial begin
        if (MEMFILE > 0)
        begin
            $readmemh(MEMFILE, memory_array);
        end
    end

    always @ (posedge clk)
    begin
       if(i_write) begin
            memory_array[i_addr] <= i_data;
       end
        o_data <= memory_array[i_addr];
    end
endmodule

module m_draw_image #(parameter ADDR_WIDTH=8, DATA_WIDTH=8, SHAPE_WIDTH=32, SHAPE_HEIGHT=32, MEMFILE="target.mem") (
  input wire clk,
input wire i_write,
input wire [10:0] current_x,
input wire [10:0] current_y,
input wire [10:0] pos_x,
input wire [10:0] pos_y,
output reg [DATA_WIDTH-1:0] o_data
);
 wire [ADDR_WIDTH-1:0] address;
wire [DATA_WIDTH-1:0] data;
 sram #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH),
      .DEPTH(SHAPE_WIDTH*SHAPE_HEIGHT),
      .MEMFILE(MEMFILE))
      vram_read (
      .i_addr(address),
      .clk(clk),
      .i_write(0),  // we're always reading
      .i_data(0),
      .o_data(data)
  );
 assign i_write = (((pos_x - SHAPE_WIDTH <= current_x) && (current_x < pos_x + SHAPE_WIDTH)) &&
                  ((pos_y - SHAPE_HEIGHT <= current_y) && (current_y < pos_y + SHAPE_HEIGHT)));
assign address = (i_write) ? ((current_y - pos_y) * (SHAPE_WIDTH + SHAPE_WIDTH) + (current_x - pos_x)) : 0;
always @(posedge clk) o_data <= data;
endmodule
