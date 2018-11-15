`timescale 1ns / 1ps

/******************************************************************************/
`default_nettype none
/******************************************************************************/
module m_main (
  input wire w_clk,             // 100MHz
  input wire [4:0] w_btn,       // Stop button
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

  wire clk; // 40Mhz
  wire w_locked;
  wire w_rst = ~w_locked;
  wire [6:0] w_sg;
  wire [7:0] w_an;
  reg [11:0] r_rgb;
  reg r_finish = 0;

  // 100MHz -> 40MHz
  clk_wiz_0 clk_wiz (clk, 1'b0, w_locked, w_clk); // 100MHz -> 40MHz

  assign w_led = w_btn;

/******************************************************************************/
// Count time
/******************************************************************************/
  reg [31:0] r_duration = 0;

  reg [31:0] r_tcnt=0;
  always@(posedge clk) r_tcnt <= (!r_finish) ? (r_tcnt>=(40000000-1)) ? 0 : r_tcnt + 1 : r_tcnt;
  always@(posedge clk) r_duration <= (r_tcnt == 0) ? r_duration + 1 : r_duration;

/******************************************************************************/
// Display on monitor through vga
/******************************************************************************/

  // VRAM frame buffers (read-write)
  localparam SCREEN_WIDTH = 800;
  localparam SCREEN_HEIGHT = 600;
  reg [10:0] r_draw_x, r_draw_y;
  reg w_active;
  reg [10:0] hcnt, vcnt;

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
  localparam VRAM_D_WIDTH = 4;   // colour bits per pixel

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

  /******************************************************************************/
  // Store frame info onto BRAM
  /******************************************************************************/

  wire [VRAM_D_WIDTH-1:0] w_frame_data_in, w_frame_data_out;
  assign w_frame_data_in = 4'b1001;
  reg [10:0] frame_width = 400, frame_height = 300;
  wire w_frame_draw;

  m_draw_rectangle #(
    .ADDR_WIDTH(VRAM_A_WIDTH),
    .DATA_WIDTH(VRAM_D_WIDTH),
    .DEPTH(400*300)
  )
  frame (
    .clk(clk),
    .i_write(w_frame_draw),
    .current_x(r_draw_x),
    .current_y(r_draw_y),
    .half_width(frame_width),
    .half_height(frame_height),
    .i_data(w_frame_data_in),
    .o_data(w_frame_data_out)
  );

  /******************************************************************************/
  // Store target info onto BRAM
  /******************************************************************************/

  wire [VRAM_D_WIDTH-1:0] w_target_data_in, w_target_data_out;
  assign w_target_data_in = 4'b0100;
  reg [10:0] target_width = 20, target_height = 15;
  wire  w_target_draw;

  m_draw_rectangle #(
    .ADDR_WIDTH(VRAM_A_WIDTH),
    .DATA_WIDTH(VRAM_D_WIDTH),
    .DEPTH(20*15)
  )
  target (
    .clk(clk),
    .i_write(w_target_draw),
    .current_x(r_draw_x),
    .current_y(r_draw_y),
    .half_width(target_width),
    .half_height(target_height),
    .i_data(w_target_data_in),
    .o_data(w_target_data_out)
  );

  /******************************************************************************/
  // Store target info onto BRAM
  /******************************************************************************/

  reg [31:0] r_score=0;
  reg [19:0] r_cnt=0;
  wire [3:0]  r_lfsr_width, r_lfsr_height;
  reg r_restart = 0;
  reg r_random=0;
  m_lfsr_4bit rand_width (clk, w_rst, r_random, 1, r_lfsr_width);
  m_lfsr_4bit rand_height (clk, w_rst, r_random, 0, r_lfsr_height);

  m_7segcon m_7segcon(clk, r_score, w_sg, w_an);

  always @(posedge clk) begin
    r_address <= r_draw_y * SCREEN_WIDTH + r_draw_x;
    if (r_random) r_cnt <= (r_cnt>=(500000-1)) ? 0 : r_cnt + 1;
    else r_cnt <= (r_cnt>=(200000-1)) ? 0 : r_cnt + 1;
    r_sg <= w_sg;
    r_an <= w_an;
    r_random <= (sw[0]) ? 1 : 0;

    if (r_cnt == 0) begin
      r_finish <= (w_btn[4]|| r_duration == 30) ? 1 : r_finish;
      r_restart <= (w_btn[2]) ? 1 : 0;
      frame_width <= (r_finish == 0) ? ((frame_width > target_width) ? frame_width - r_lfsr_width : 400) : frame_width;
      frame_height <= (r_finish == 0) ? ((frame_height > target_height) ? frame_height - r_lfsr_height : 300) : frame_height;
    end

    // If writing an object
    if (w_frame_draw || w_target_draw) begin
      r_vram_write <= 1;
      r_vram_data_in <= (w_target_draw) ? w_target_data_out : w_frame_data_out;
    end
    else r_vram_write <= 0;

    r_rgb <= (w_active && (w_target_draw || w_frame_draw)) ? {{2{w_vram_data_out[2], w_vram_data_out[3]}},
             {2{w_vram_data_out[1], w_vram_data_out[3]}},
             {2{w_vram_data_out[0], w_vram_data_out[3]}}} : (w_active) ? 12'b111111111111 : 0;

    vga_red <= r_rgb[11:8];
    vga_green <= r_rgb[7:4];
    vga_blue <= r_rgb[3:0];

    /******************************************************************************/
    // After 'stop' has been pushed, display score
    /******************************************************************************/
    if (r_finish) begin
        r_score <= 1000000 - (frame_width + frame_width) * (frame_height + frame_height) - 1000 * r_duration * r_duration;
    end
    
    if (r_restart) begin
        r_score <= 0;
        frame_width <= 400;
        frame_height <= 300;
        r_duration <= 0;
        r_finish <= 0;
     end
  end

endmodule

/******************************************************************************/