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

module draw_entity #(parameter ADDR_WIDTH=8, DATA_WIDTH=8, ENTITYSIZE=32, MEMFILE="") (
  input wire clk,
  input wire i_write,
  input wire [10:0] current_x,
  input wire [10:0] current_y,
  input wire [10:0] pos_x,
  input wire [10:0] pos_y,
  input wire  [DATA_WIDTH-1:0] i_data,
  output reg [DATA_WIDTH-1:0] o_data
  );

  wire [ADDR_WIDTH-1:0] address;
  wire [DATA_WIDTH-1:0] data;

  sram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(ENTITYSIZE*ENTITYSIZE),
        .MEMFILE(MEMFILE))
        vram_read (
        .i_addr(address),
        .clk(clk),
        .i_write(i_write),  // we're always reading
        .i_data(i_data),
        .o_data(data)
    );


  assign i_write = (((pos_x <= current_x) && (current_x < pos_x + ENTITYSIZE)) &&
                    ((pos_y <= current_y) && (current_y < pos_y + ENTITYSIZE)));
  assign address = (i_write) ? ((current_y - pos_y) * ENTITYSIZE + (current_x - pos_x)) : 0;
  always @(posedge clk) o_data <= data;
endmodule
