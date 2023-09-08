`timescale 1ns / 1ps

module pl_uclk (
    input clk,
    input rst_n,
    output reg uclk
);

  parameter DIV_FREQ = 25_000_000;
  reg [31:0] cnt_div;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt_div <= 32'd0;
      uclk <= 1'd0;
    end else begin
      cnt_div <= cnt_div + 1'd1;
      if (cnt_div == DIV_FREQ - 1'd1) begin
        uclk <= ~uclk;
        cnt_div <= 32'd0;
      end
    end
  end

endmodule
