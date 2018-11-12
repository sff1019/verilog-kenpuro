// Sync with display

module vga_sync
(
  input wire clk,
  input wire w_rst,
  output wire hsync,
  output wire vsync,
  output wire w_active,
  output wire r_draw_x,
  output wire r_draw_y
  );
  /********** 800 x 600 60Hz SVGA Controller **********/
  localparam SCREEN_WIDTH = 800;
  localparam SCREEN_HEIGHT = 600;
  reg [10:0] hcnt, vcnt;

  always @(posedge clk) begin
    hcnt   <= (w_rst) ? 0 : (hcnt==1055) ? 0 : hcnt + 1;
    vcnt   <= (w_rst) ? 0 : (hcnt!=1055) ? vcnt : (vcnt==627) ? 0 : vcnt + 1;
  end
  
  assign hsync = (w_rst) ? 1 : (hcnt>=840 && hcnt<=967) ? 0 : 1;
  assign vsync = (w_rst) ? 1 : (vcnt>=601 && vcnt<=604) ? 0 : 1;
  assign w_active = (w_rst) ? 0 : (hcnt < SCREEN_WIDTH && vcnt < SCREEN_HEIGHT);
  assign r_draw_x = (hcnt < SCREEN_WIDTH) ? hcnt : 0;
  assign r_draw_y = (vcnt < SCREEN_HEIGHT) ? vcnt : 0;


endmodule
