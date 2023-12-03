`timescale 1ns / 1ps

module led_ctrl #(
    parameter CLK_FREQ = 50000000,
    parameter CNT_MAX  = CLK_FREQ / 2 - 1
) (
    input      clk,
    input      rst_n,
    output reg led
);

  reg [31:0] r_cnt;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      r_cnt <= 'b0;
      led   <= 'b0;
    end else begin
      r_cnt <= r_cnt + 1'b1;
      if (r_cnt == CNT_MAX) begin
        r_cnt <= 'b0;
        led   <= ~led;
      end
    end
  end

endmodule
