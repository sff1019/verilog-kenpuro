// Sync with display

module vga_sync
(
  input wire clk,
  input wire w_rst,
  output wire [10:0] pos_x,
  output wire [10:0] pos_y,
  output wire hsync,
  output wire vsync,
  output wire active
  );
  /********** 800 x 600 60Hz SVGA Controller **********/
  localparam SCREEN_WIDTH = 800;
  localparam SCREEN_HEIGHT = 600;
  localparam HR_FNT_PORCH = 40;
  localparam HR_SYNC = 128;
  localparam HR_BK_PORCH = 88;
  localparam VT_FNT_PORCH = 1;
  localparam VT_SYNC = 4;
  localparam VT_BK_PORCH = 23;

  localparam HA_STA = HR_FNT_PORCH + HR_SYNC + HR_BK_PORCH; // horizontal active pixel start
  localparam HS_STA = SCREEN_WIDTH + HR_FNT_PORCH; // horizontal sync start
  localparam HS_END = HS_STA + HR_SYNC; // horizontal sync end
  localparam HR_MAX = HA_STA + SCREEN_WIDTH; // Max horizontal

  localparam VT_MAX = VT_FNT_PORCH + VT_SYNC + VT_BK_PORCH;
  localparam VS_STA = SCREEN_HEIGHT + VT_FNT_PORCH;
  localparam VS_END = VS_STA + VT_SYNC;
  localparam VA_STA = 60;
  localparam VA_END = 540;
  reg [10:0] hcnt, vcnt;

  always @(posedge clk) begin
  hcnt   <= (w_rst) ? 0 : (hcnt==HR_MAX-1) ? 0 : hcnt + 1;
  vcnt   <= (w_rst) ? 0 : (hcnt!=HR_MAX-1) ? vcnt : (vcnt==VT_MAX-1) ? 0 : vcnt + 1;
  end
  assign hsync  = (w_rst) ? 1 : (hcnt>=HS_STA && hcnt<=HS_END-1) ? 0 : 1;
  assign vsync  = (w_rst) ? 1 : (vcnt>=VS_STA && vcnt<=VS_END-1) ? 0 : 1;

  assign pos_x  = (hcnt < SCREEN_WIDTH) ? hcnt : 0;
  assign pos_y  = (vcnt < SCREEN_HEIGHT) ? vcnt : 0;
endmodule
