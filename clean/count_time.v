module m_time (
  input wire clk,
  input wire w_finish,
  output reg [31:0] r_duration
  );

  reg [31:0] r_tcnt=0;
  always@(posedge clk) r_tcnt <= (!w_finish) ? (r_tcnt>=(100000000-1)) ? 0 : r_tcnt + 1 : r_tcnt;
  always@(posedge clk) if(r_tcnt==0) r_duration <= r_duration + 1;
endmodule
