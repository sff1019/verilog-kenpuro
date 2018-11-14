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

  wire clk; // 100MHz
  wire w_locked;
  wire w_rst = ~w_locked;
  reg r_finish = 0;
  reg [31:0] r_duration = 0;
  reg [10:0] r_draw_x, r_draw_y;
  reg [11:0] r_rgb;
  wire [6:0] w_sg;
  wire [7:0] w_an;
  assign w_led = w_btn;

//    reg w_clk = 0;
//    initial forever #1 w_clk = ~w_clk;

  clk_wiz_0 clk_wiz (clk, 0, w_locked, w_clk); // 100MHz -> 40MHz

  /******************************************************************************/
  // Count time
  /******************************************************************************/

  reg [25:0] r_tcnt=0;
  always@(posedge clk) r_tcnt <= (r_tcnt>=(40000000-1)) ? 0 : r_tcnt + 1;
  always@(posedge clk) if(r_tcnt==0) r_duration <= r_duration + 1;

  /******************************************************************************/
  // Display on monitor through vga
  /******************************************************************************/
  localparam SCREEN_WIDTH = 800;
  localparam SCREEN_HEIGHT = 600;

  reg [10:0] hcnt, vcnt;
  reg w_active;

  always @(posedge clk) begin
    hcnt   <= (w_rst) ? 0 : (hcnt==1055) ? 0 : hcnt + 1;
    vcnt   <= (w_rst) ? 0 : (hcnt!=1055) ? vcnt : (vcnt==627) ? 0 : vcnt + 1;
    hsync <= (w_rst) ? 1 : (hcnt>=840 && hcnt<=967) ? 0 : 1;
    vsync <= (w_rst) ? 1 : (vcnt>=601 && vcnt<=604) ? 0 : 1;
    w_active <= (w_rst) ? 0 : (hcnt < SCREEN_WIDTH && vcnt < SCREEN_HEIGHT);
    r_draw_x <= (hcnt < SCREEN_WIDTH) ? hcnt : 0;
    r_draw_y <= (vcnt < SCREEN_HEIGHT) ? vcnt : 0;
  end

  /******************************************************************************/
  // Display on monitor what is inside of BRAM
  /******************************************************************************/
  localparam VRAM_DEPTH = SCREEN_WIDTH * SCREEN_HEIGHT;
  localparam VRAM_A_WIDTH = 19;  // 2^19 > 800*600
  localparam VRAM_D_WIDTH = 8;   // colour bits per pixel

  reg [VRAM_A_WIDTH-1:0] r_address;
  reg [VRAM_D_WIDTH-1:0] r_vram_data_in;
  wire [VRAM_D_WIDTH-1:0] w_vram_data_out;
  reg r_vram_write = 0;

  sram #(
    .ADDR_WIDTH(VRAM_A_WIDTH),
    .DATA_WIDTH(VRAM_D_WIDTH),
    .DEPTH(VRAM_DEPTH),
    .MEMFILE("bg.mem"))
  vram_read (
    .i_addr(r_address),
    .clk(clk),
    .i_write(r_vram_write),  // we're always reading
    .i_data(r_vram_data_in),
    .o_data(w_vram_data_out)
  );

  /******************************************************************************/
  // Store frame info onto BRAM
  /******************************************************************************/

  wire [VRAM_D_WIDTH-1:0] w_frame_data_in = 4'b1001;
  wire [VRAM_D_WIDTH-1:0] w_frame_data_out;
  // assign w_frame_data_in = 4'b1001;
  reg [10:0] r_frame_width = 200;
  reg [10:0] r_frame_height = 150;
  wire w_frame_draw;

  m_draw_rectangle #(
    .ADDR_WIDTH(VRAM_A_WIDTH),
    .DATA_WIDTH(VRAM_D_WIDTH),
    .DEPTH(200*150)
  )
  frame (
    .clk(clk),
    .i_write(w_frame_draw),
    .current_x(r_draw_x),
    .current_y(r_draw_y),
    .half_width(r_frame_width),
    .half_height(r_frame_height),
    .i_data(w_frame_data_in),
    .o_data(w_frame_data_out)
  );

  /******************************************************************************/
  // Store target info onto BRAM
  /******************************************************************************/

  wire [VRAM_D_WIDTH-1:0] w_target_data_in, w_target_data_out;
  assign w_target_data_in = 4'b0100;
  reg [10:0] target_width = 20, target_height = 15;
  wire  w_draw_target;

  m_draw_rectangle #(
    .ADDR_WIDTH(VRAM_A_WIDTH),
    .DATA_WIDTH(VRAM_D_WIDTH),
    .DEPTH(20*15)
  )
  target (
    .clk(clk),
    .i_write(w_draw_target),
    .current_x(r_draw_x),
    .current_y(r_draw_y),
    .half_width(target_width),
    .half_height(target_height),
    .i_data(w_target_data_in),
    .o_data(w_target_data_out)
  );

  /******************************************************************************/
  // Get color palette of memory files
  /******************************************************************************/

  reg [11:0] r_palette_bg [0:255];  // 64 x 12-bit colour palette entries
  initial begin
    $readmemh("bg_palette.mem", r_palette_bg);  // bitmap palette to load
  end

  /******************************************************************************/
  // Every positive clock, do the below:
  // 1. Store new address
  // 2. Change lengths of the frame
  // 3. Store data into register that will be processed into BRAM
  // 4. Display current pixel onto VGA display
  // 5. If finished print score
  // 6. If restarted, reset every variable
  /******************************************************************************/

  reg [19:0] r_cnt=0;
  reg r_restart = 0;
  reg [31:0] r_score=0;

  wire [3:0]  r_lfsr_width, r_lfsr_height;
  reg r_random=0;
  m_lfsr_4bit rand_width (clk, w_rst, r_random, 1, r_lfsr_width);
  m_lfsr_4bit rand_height (clk, w_rst, r_random, 0, r_lfsr_height);

  m_7segcon m_7segcon(clk, r_duration, w_sg, w_an);

  always @(posedge clk) begin
    r_address <= r_draw_y * SCREEN_WIDTH + r_draw_x;
    r_cnt <= (r_cnt>=(200000-1)) ? 0 : r_cnt + 1;
    r_sg <= w_sg;
    r_an <= w_an;
    r_random <= (sw[0]) ? 1 : 0;

    if (r_cnt == 0) begin
      r_finish <= (w_btn[4]|| r_duration == 15) ? 1 : r_finish;
      r_restart <= (w_btn[2]) ? 1 : 0;
      r_frame_width <= (r_finish == 0) ? ((r_frame_width > 20) ? r_frame_width - r_lfsr_width : 354) : r_frame_width;
      r_frame_height <= (r_finish == 0) ? ((r_frame_height > 15) ? r_frame_height - r_lfsr_height : 267) : r_frame_height;
    end

    if (w_draw_target)
    begin
      r_vram_write <= 1;
      r_vram_data_in <= w_target_data_out;
    end
    else if (w_frame_draw)
    begin
      r_vram_write <= 1;
      r_vram_data_in <= w_frame_data_out;
    end
    else r_vram_write <= 0;

    if (w_active && w_draw_target || w_frame_draw)
      r_rgb <= {{2{w_vram_data_out[2], w_vram_data_out[3]}},{2{w_vram_data_out[1], w_vram_data_out[3]}},{2{w_vram_data_out[0], w_vram_data_out[3]}}};
    else if (w_active && !w_draw_target && !w_frame_draw)
      r_rgb <= r_palette_bg[w_vram_data_out];
    else
      r_rgb <= 0;

    vga_red <= r_rgb[11:8];
    vga_green <= r_rgb[7:4];
    vga_blue <= r_rgb[3:0];

    if (r_finish) begin
      r_score <= 1000000 - (r_frame_width + r_frame_width) * (r_frame_height + r_frame_height) - 1000 * r_duration * r_duration;
    end

    if (r_restart) begin
      r_score <= 0;
      r_frame_width <= 354;
      r_frame_height <= 265;
      r_duration <= 0;
      r_finish <= 0;
      r_tcnt <= 0;
    end
  end

endmodule

/******************************************************************************/
