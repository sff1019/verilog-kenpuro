`timescale 1ns / 1ps

module m_lfsr_4bit (
  input wire clk,
  output wire [31:0] result
  );

  reg [3:0] random;
  initial begin random <= 4'b1111; end
  wire feedback = random[3] ^ random[2];

  always @(posedge clk)
    random <= {random[3:0], feedback};

  assign result = random;
endmodule

module m_lfsr_32bit(
  input wire clk,
  output wire [31:0] rand
);

  reg [31:0] random = 32'hffffffff;
  wire feedback = random[31] ^ random[6] ^ random[5] ^ random[1] ;

  reg [31:0] r_tcnt=0;
  always@(posedge clk) random <= {rand[31:0], feedback};

  assign rand = random;
endmodule
