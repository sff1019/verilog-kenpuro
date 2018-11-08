`timescale 1ns / 1ps

/******************************************************************************/
`default_nettype none
/******************************************************************************/
module m_main (
  input wire w_clk,
  input wire [4:0] w_btn,
  input wire [11:0] sw,
  output wire[15:0] w_led,
  output reg hsync,
  output reg vsync,
  output reg [3:0] vga_red,
  output reg [3:0] vga_green,
  output reg [3:0] vga_blue,
  output reg [6:0] r_sg,
  output reg [7:0] r_an
  );


   // VRAM frame buffers (read-write)
  localparam SCREEN_WIDTH = 800;
  localparam SCREEN_HEIGHT = 600;
  localparam VRAM_DEPTH = SCREEN_WIDTH * SCREEN_HEIGHT;
  localparam VRAM_A_WIDTH = 19;  // 2^19 > 800*600
  localparam VRAM_D_WIDTH = 8;   // colour bits per pixel

  wire clk, w_locked;
  wire w_rst = ~w_locked;
  reg [10:0] r_draw_x, r_draw_y;
  reg [11:0] r_rgb;

//  reg w_clk = 0;
//  initial forever #1 w_clk = ~w_clk;

  clk_wiz_0 clk_wiz (clk, 0, w_locked, w_clk); // 100MHz -> 40MHz

  //initial forever #1 CLK100MHZ = ~CLK100MHZ;


  assign w_led = w_btn;

  reg [10:0] hcnt, vcnt;
  reg w_active;

//  vga_sync (clk, w_rst, r_draw_x, r_draw_y, hsync, vsync, w_active);
   always @(posedge clk) begin
   hcnt   <= (w_rst) ? 0 : (hcnt==1055) ? 0 : hcnt + 1;
   vcnt   <= (w_rst) ? 0 : (hcnt!=1055) ? vcnt : (vcnt==627) ? 0 : vcnt + 1;
   hsync <= (w_rst) ? 1 : (hcnt>=840 && hcnt<=967) ? 0 : 1;
   vsync <= (w_rst) ? 1 : (vcnt>=601 && vcnt<=604) ? 0 : 1;
   w_active <= (w_rst) ? 0 : (hcnt < SCREEN_WIDTH && vcnt < SCREEN_HEIGHT);
   r_draw_x <= (hcnt < SCREEN_WIDTH) ? hcnt : 0;
   r_draw_y <= (vcnt < SCREEN_HEIGHT) ? vcnt : 0;
   end

  reg [VRAM_A_WIDTH-1:0] r_address;
  reg [VRAM_D_WIDTH-1:0] r_vram_data_in;
  wire [VRAM_D_WIDTH-1:0] w_vram_data_out;
  reg r_vram_write = 0;

  sram #(
        .ADDR_WIDTH(VRAM_A_WIDTH),
        .DATA_WIDTH(VRAM_D_WIDTH),
        .DEPTH(VRAM_DEPTH),
        .MEMFILE(""))
        vram_read (
        .i_addr(r_address),
        .clk(clk),
        .i_write(r_vram_write),  // we're always reading
        .i_data(r_vram_data_in),
        .o_data(w_vram_data_out)
    );

  wire [VRAM_D_WIDTH-1:0] w_entity_data_out;
  reg [10:0] r_pos_x=400, r_pos_y=300;  // current pixel x position: 10-bit value: 0-1023
  wire w_draw;

  draw_entity #(
    .ADDR_WIDTH(VRAM_A_WIDTH),
    .DATA_WIDTH(VRAM_D_WIDTH),
    .ENTITYSIZE(32),
    .MEMFILE("fighter.mem")
    )
    entity (
      .clk(clk),
      .i_write(w_draw),
      .current_x(r_draw_x),
      .current_y(r_draw_y),
      .pos_x(r_pos_x),
      .pos_y(r_pos_y),
      .o_data(w_entity_data_out)
    );

  reg [11:0] r_palette [0:255];  // 64 x 12-bit colour palette entries
  initial begin
          $display("Loading palette.");
          $readmemh("fighter_palette.mem", r_palette);  // bitmap palette to load
   end

    reg [19:0] r_cnt=0;
   always @(posedge clk) begin
     r_cnt <= (r_cnt>=(200000-1)) ? 0 : r_cnt + 1;;
     if (r_cnt == 0) begin
         if(w_btn[0] && (r_pos_x > 32)) r_pos_x <= r_pos_x - 1;
         if(w_btn[1] && (r_pos_x < SCREEN_HEIGHT - 32)) r_pos_x <= r_pos_x + 1;
         if(w_btn[2] && (r_pos_y > 32)) r_pos_y <= r_pos_y - 1;
         if(w_btn[3] && (r_pos_y < SCREEN_WIDTH-32)) r_pos_y <= r_pos_y + 1;
    end
      if(r_pos_x!=SCREEN_HEIGHT)
        r_address <= r_draw_y * SCREEN_WIDTH + r_draw_x;

      if (w_draw)
      begin
        r_vram_write <= 1;
        r_vram_data_in <= w_entity_data_out;
      end
      else r_vram_write <= 0;

      if (w_active)
        r_rgb <= r_palette[w_vram_data_out];
      else
        r_rgb <= 0;

      vga_red <= r_rgb[11:8];
      vga_green <= r_rgb[7:4];
      vga_blue <= r_rgb[3:0];
    end

endmodule

/******************************************************************************/
