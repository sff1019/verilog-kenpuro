`timescale 1ns / 1ps

/******************************************************************************/
`default_nettype none
/******************************************************************************/
module m_main (w_clk, r_an, r_sg, w_btn, w_led, vga_red, vga_green, vga_blue, hsync, vsync, sw);

          // VRAM frame buffers (read-write)
    localparam SCREEN_WIDTH = 800;
    localparam SCREEN_HEIGHT = 600;
    localparam VRAM_DEPTH = SCREEN_WIDTH * SCREEN_HEIGHT;
    localparam VRAM_A_WIDTH = 19;  // 2^19 > 800*600
    localparam VRAM_D_WIDTH = 8;   // colour bits per pixel
    localparam HA_STA = 40 + 128 + 88;
    localparam VA_STA = 60;
    localparam VA_END = 540;

  input  wire w_clk;
  input wire[4:0] w_btn;
  input wire [11:0] sw;
  output wire [15:0] w_led;
  output reg hsync, vsync;
  output reg [3:0]  vga_red, vga_green, vga_blue;
  output reg[7:0] r_an;
  output reg[6:0] r_sg;
  reg [11:0] rgb_reg;

  wire clk, w_locked;
  clk_wiz_0 clk_wiz (clk, 0, w_locked, w_clk); // 100MHz -> 40MHz
  wire w_rst = ~w_locked;
  reg [10:0] x=400, y=300;  // current pixel x position: 10-bit value: 0-1023


  always @(posedge clk) rgb_reg <= sw;
  assign w_led = w_btn;

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

  wire [VRAM_A_WIDTH-1:0] address;
  wire [VRAM_D_WIDTH-1:0] data_in;
  wire [VRAM_D_WIDTH-1:0] data_out;

    assign address = (x-y) * 32 + (x-y);
    // Read
    sram #(
          .ADDR_WIDTH(VRAM_A_WIDTH),
          .DATA_WIDTH(VRAM_D_WIDTH),
          .DEPTH(VRAM_DEPTH),
          .MEMFILE("fighter.mem"))
          vram_read (
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
          $readmemh("fighter_palette.mem", palette);  // bitmap palette to load
   end

  always @ (posedge clk)
  begin
      colour <= palette[data_out];

      vga_red <= colour[11:8];
      vga_green <= colour[7:4];
      vga_blue <= colour[3:0];
  end

endmodule

/******************************************************************************/
