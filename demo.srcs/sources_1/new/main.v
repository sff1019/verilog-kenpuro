`timescale 1ns / 1ps

/******************************************************************************/
/* Sample Verilog HDL Code for Computer Architecture     Arch Lab. TOKYO TECH */
/******************************************************************************/
`default_nettype none
/******************************************************************************/
module m_main (w_clk, w_btnu, w_btnd, w_led, vga_red, vga_green, vga_blue, hsync, vsync, sw);
  input  wire w_clk, w_btnu, w_btnd;
  input wire [11:0] sw;
  output wire [15:0] w_led;
  output reg         hsync, vsync;
  output wire [3:0]  vga_red, vga_green, vga_blue;
  reg [11:0] rgb_reg;
  
  wire clk, w_locked;
  clk_wiz_0 clk_wiz (clk, 0, w_locked, w_clk); // 100MHz -> 40MHz
  wire w_rst = ~w_locked || w_btnu || w_btnd;

  always @(posedge clk) rgb_reg <= sw;
  assign w_led = sw;

  /********** 800 x 600 60Hz SVGA Controller **********/
  reg [10:0] hcnt, vcnt;
  always @(posedge clk) begin
    hcnt   <= (w_rst) ? 0 : (hcnt==1055) ? 0 : hcnt + 1;
    vcnt   <= (w_rst) ? 0 : (hcnt!=1055) ? vcnt : (vcnt==627) ? 0 : vcnt + 1;
    hsync <= (w_rst) ? 1 : (hcnt>=840 && hcnt<=967) ? 0 : 1;
    vsync <= (w_rst) ? 1 : (vcnt>=601 && vcnt<=604) ? 0 : 1;
  end
  
  assign vga_red = rgb_reg[11:8];
  assign vga_green = rgb_reg[7:4];
  assign vga_blue = rgb_reg[3:0];
endmodule

/******************************************************************************/