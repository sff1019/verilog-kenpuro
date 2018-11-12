module m_7segled (w_in, r_led);
  input  wire [3:0] w_in;
  output reg  [6:0] r_led;
  always @(*) begin
    case (w_in)
      4'd0  : r_led <= 7'b1111110;
      4'd1  : r_led <= 7'b0110000;
      4'd2  : r_led <= 7'b1101101;
      4'd3  : r_led <= 7'b1111001;
      4'd4  : r_led <= 7'b0110011;
      4'd5  : r_led <= 7'b1011011;
      4'd6  : r_led <= 7'b1011111;
      4'd7  : r_led <= 7'b1110000;
      4'd8  : r_led <= 7'b1111111;
      4'd9  : r_led <= 7'b1111011;
      default:r_led <= 7'b0000000;
    endcase
  end
endmodule

`define DELAY7SEG  100000 // 200000 for 100MHz, 100000 for 50MHz
/******************************************************************************/
module m_7segcon (w_clk, w_din, r_sg, r_an);
  input  wire w_clk;
  input  wire [31:0] w_din;
  output reg [6:0] r_sg;  // cathode segments
  output reg [7:0] r_an;  // common anode

  reg [31:0] r_val   = 0;
  reg [31:0] r_cnt   = 0;
  reg  [3:0] r_in    = 0;
  reg  [2:0] r_digit = 0;
  always@(posedge w_clk) r_val <= w_din;

  always@(posedge w_clk) begin
    r_cnt <= (r_cnt>=(`DELAY7SEG-1)) ? 0 : r_cnt + 1;
    if(r_cnt==0) begin
      r_digit <= r_digit+ 1;
       if (r_digit==0) begin r_an <= 8'b11111110; r_in <= r_val % 10; end
       else if (r_digit==1) begin r_an <= 8'b11111101; r_in <= (r_val / 10 ) % 10; end
       else if (r_digit==2) begin r_an <= 8'b11111011; r_in <= (r_val / 100 ) % 10;  end
       else if (r_digit==3) begin r_an <= 8'b11110111; r_in <= (r_val / 1000 ) % 10; end
       else if (r_digit==4) begin r_an <= 8'b11101111; r_in <= (r_val / 10000 ) % 10; end
       else if (r_digit==5) begin r_an <= 8'b11011111; r_in <= (r_val / 100000 ) % 10; end
       else if (r_digit==6) begin r_an <= 8'b10111111; r_in <= (r_val / 1000000 ) % 10; end
       else                 begin r_an <= 8'b01111111; r_in <= (r_val / 10000000 ) % 10; end

    end
  end
  wire [6:0] w_segments;
  m_7segled m_7segled (r_in, w_segments);
  always@(posedge w_clk) r_sg <= ~w_segments;
endmodule
/******************************************************************************/
