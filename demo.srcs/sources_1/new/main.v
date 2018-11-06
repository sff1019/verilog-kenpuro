`timescale 1ns / 1ps

/******************************************************************************/
`default_nettype none
/******************************************************************************/ 
module m_main (w_clk, r_an, r_sg, w_btnu, w_btnd, w_led, vga_red, vga_green, vga_blue, hsync, vsync, sw);
// VRAM frame buffers (read-write)
  localparam SCREEN_WIDTH = 800;
  localparam SCREEN_HEIGHT = 600;
  localparam VRAM_DEPTH = SCREEN_WIDTH * SCREEN_HEIGHT; 
  localparam VRAM_A_WIDTH = 19;  // 2^19 > 800*600
  localparam VRAM_D_WIDTH = 6;   // colour bits per pixel
  localparam HA_STA = 40 + 128 + 88;
  localparam VA_STA = 60;
  localparam VA_END = 540;

  input  wire w_clk, w_btnu, w_btnd;
  input wire [11:0] sw;
  output wire [15:0] w_led;
  output reg hsync, vsync;
  output reg [3:0]  vga_red, vga_green, vga_blue;
  output reg[7:0] r_an;
  output reg[6:0] r_sg;
  reg [11:0] rgb_reg;

  wire clk, w_locked;
  clk_wiz_0 clk_wiz (clk, 0, w_locked, w_clk); // 100MHz -> 40MHz
  wire w_rst = ~w_locked || w_btnu || w_btnd;
  reg [10:0] x, y;  // current pixel x position: 10-bit value: 0-1023
  
 
  always @(posedge clk) rgb_reg <= sw;
  assign w_led = sw;
  
  /********** 800 x 600 60Hz SVGA Controller **********/
  reg [10:0] hcnt, vcnt;
  always @(posedge clk) begin
    hcnt   <= (w_rst) ? 0 : (hcnt==1055) ? 0 : hcnt + 1;
    vcnt   <= (w_rst) ? 0 : (hcnt!=1055) ? vcnt : (vcnt==627) ? 0 : vcnt + 1;
    hsync <= (w_rst) ? 1 : (hcnt>=840 && hcnt<=967) ? 0 : 1;
    vsync <= (w_rst) ? 1 : (vcnt>=601 && vcnt<=604) ? 0 : 1;
    x <= (hcnt < HA_STA) ? 0 : (hcnt - HA_STA);
    y <= (vcnt >= VA_END) ? (VA_END - VA_STA - 1) : (vcnt - VA_STA);
  end
  
  reg [VRAM_A_WIDTH-1:0] address;
  wire [VRAM_D_WIDTH-1:0] data_in;
  wire [VRAM_D_WIDTH-1:0] data_out;
    
  sram #(
      .ADDR_WIDTH(VRAM_A_WIDTH), 
      .DATA_WIDTH(VRAM_D_WIDTH), 
      .DEPTH(VRAM_DEPTH), 
      .MEMFILE("game.mem"))  // bitmap to load
      vram (
      .i_addr(address), 
      .clk(clk), 
      .i_write(0),  // we're always reading
      .i_data(0), 
      .o_data(data_out)
  );
  
  reg [11:0] palette [0:63];  // 64 x 12-bit colour palette entries
  reg [11:0] colour;
  initial begin
      $display("Loading palette.");
      $readmemh("game_palette.mem", palette);  // bitmap palette to load
  end
  
  always @ (posedge clk)
  begin
      address <= y * SCREEN_WIDTH + x;
      colour <= palette[data_out];
      
      vga_red <= colour[11:8];
      vga_green <= colour[7:4];
      vga_blue <= colour[3:0];
  end
  
endmodule

/******************************************************************************/

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
            $display("Loading memory init file '" + MEMFILE + "' into array.");
            $readmemh(MEMFILE, memory_array);
        end
    end

    always @ (posedge clk)
    begin
        if(i_write) begin
            memory_array[i_addr] <= i_data;
        end
        else begin
            o_data <= memory_array[i_addr];
        end     
    end
endmodule