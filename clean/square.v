module m_draw_rectangle #(parameter ADDR_WIDTH=8, DATA_WIDTH=4, SHAPE_HF_WIDTH=32, SHAPE_HF_HEIGHT=32) (
  input wire clk,
  input wire i_write,
  input wire [10:0] current_x,
  input wire [10:0] current_y,
  input wire [10:0] pos_x,
  input wire [10:0] pos_y,
  // input wire  [DATA_WIDTH-1:0] i_data,
  output reg [DATA_WIDTH-1:0] o_data

  );

  wire [ADDR_WIDTH-1:0] address;
  wire [DATA_WIDTH-1:0] data;
  wire [DATA_WIDTH-1:0] color;

  sram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH((SHAPE_HF_WIDTH+SHAPE_HF_WIDTH)*(SHAPE_HF_HEIGHT*SHAPE_HF_HEIGHT)),
        .MEMFILE(""))
        vram_read (
        .i_addr(address),
        .clk(clk),
        .i_write(i_write),  // we're always reading
        .i_data(color),
        .o_data(data)
    );

  assign i_write = (((pos_x <= current_x) && (current_x < pos_x + SHAPE_HF_WIDTH*2)) &&
                    ((pos_y <= current_y) && (current_y < pos_y + SHAPE_HF_HEIGHT*2)));
  assign color = 4'b1110;
  assign address = (i_write) ? ((current_y - pos_y) * SHAPE_HF_HEIGHT * 2 + (current_x - pos_x)) : 0;
  always @(posedge clk) o_data <= data;
endmodule

module m_draw_frame #(parameter ADDR_WIDTH=8, DATA_WIDTH=4, DEPTH=256) (
    input wire clk,
    input wire i_write,
    input wire [10:0] pos_x,
    input wire [10:0] pos_y,
    input wire [10:0] inr_hf_wth, // Inner rectangle's width / 2
    input wire [10:0] inr_hf_hgt, // Inner rectangle's height / 2
    input wire [10:0] otr_hf_wth, // Outer rectangle's width / 2
    input wire [10:0] otr_hf_hgt, // Outer rectangle's height / 2
    // input wire  [DATA_WIDTH-1:0] i_data,
    output reg [DATA_WIDTH-1:0] o_data
    );
    
    wire [ADDR_WIDTH-1:0] address;
    wire [DATA_WIDTH-1:0] data;
    wire [DATA_WIDTH-1:0] color;
    
    localparam  CTR_X = 400;
    localparam  CTR_Y = 300;
    wire [11:0]  max_left = CTR_X - otr_hf_wth;
    wire [11:0]  min_left = CTR_X - inr_hf_wth;
    wire [11:0]  max_right = CTR_X + otr_hf_wth;
    wire [11:0]  min_right = CTR_X + inr_hf_wth;
    wire [11:0]  max_up = CTR_Y - otr_hf_hgt;
    wire [11:0]  min_up = CTR_Y - inr_hf_hgt;
    wire [11:0]  max_down = CTR_Y + otr_hf_hgt;
    wire [11:0]  min_down = CTR_Y + inr_hf_hgt;
    
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
    
    assign i_write = ((max_left <= pos_x && pos_x < max_right) && (max_up <= pos_y && pos_y < max_down) &&
                     (pos_x < min_left || min_right < pos_x) && (pos_y < min_up || min_down < pos_y)) ? 1 : 0;
    assign color = 4'b1001;
    assign address = (i_write) ? ((pos_y - CTR_Y) * otr_hf_hgt * 2 + (pos_x - CTR_X)) : 0;
    always @(posedge clk) o_data <= data;
endmodule
