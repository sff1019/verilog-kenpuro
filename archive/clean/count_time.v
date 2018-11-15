module m_time (
  input wire clk,
  input wire w_finish,
  output reg [31:0] r_duration
  );

  reg [31:0] r_tcnt=0;
  always@(posedge clk) r_tcnt <= (!w_finish) ? (r_tcnt>=(40000000-1)) ? 0 : r_tcnt + 1 : r_tcnt;
  always@(posedge clk) r_duration <= (r_tcnt == 0) ? r_duration + 1 : r_duration;
endmodule
