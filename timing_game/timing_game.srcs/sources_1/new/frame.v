module m_draw_rectangle #(parameter ADDR_WIDTH=8, DATA_WIDTH=4, DEPTH=256) (
  input wire clk,
  input wire i_write,
  input wire [10:0] current_x,
  input wire [10:0] current_y,
  input wire [10:0] half_width,
  input wire [10:0] half_height,
  input wire  [DATA_WIDTH-1:0] i_data,
  output reg [DATA_WIDTH-1:0] o_data

  );

  wire [ADDR_WIDTH-1:0] address;
  wire [DATA_WIDTH-1:0] data;
  wire [DATA_WIDTH-1:0] color;
  wire [10:0] ctr_x = 400, ctr_y = 300;

  sram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .MEMFILE(""))
        vram_read (
        .i_addr(address),
        .clk(clk),
        .i_write(i_write),  // we're always reading
        .i_data(color),
        .o_data(data)
    );

  assign i_write = (((ctr_x - half_width <= current_x) && (current_x < ctr_x + half_width)) &&
                    ((ctr_y - half_height <= current_y) && (current_y < ctr_y + half_height)));
  assign color = i_data;
  assign address = (i_write) ? ((current_y - ctr_y) * half_height * 2 + (current_x - ctr_x)) : 0;
  always @(posedge clk) o_data <= data;
endmodule
