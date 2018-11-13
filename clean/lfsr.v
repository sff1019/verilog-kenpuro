`timescale 1ns / 1ps

module m_lfsr_4bit (
    input wire clk,
    input wire w_rst,
    output reg [3:0] out
    );
  wire feedback;
  
  assign feedback = ~(out[3] ^ out[2]);

    always @(posedge clk) begin
        if (w_rst) out = 4'b0;
        else out <= {out[2:0],feedback};
  end
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
