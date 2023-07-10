module led_stream (
    input      clk,
    input      rst_n,
    output reg led
);

  reg [31:0] cnt;
  parameter CLOCK_FREQ = 50000000;
  parameter COUNTER_MAX_CNT = CLOCK_FREQ / 2 - 1;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= 31'd0;
      led <= 1'd0;
    end else begin
      cnt <= cnt + 1'b1;
      if (cnt == COUNTER_MAX_CNT) begin
        cnt <= 31'd0;
        led <= ~led;
      end
    end
  end
endmodule

