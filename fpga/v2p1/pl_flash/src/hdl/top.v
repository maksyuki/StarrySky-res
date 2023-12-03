module top (
    input      clk,
    input      rst_n,
    output reg led,
    output     cs_n,
    output     sck,
    output     mosi,
    input      miso
);

  reg [31:0] r_cnt;
  parameter CLOCK_FREQ = 50000000;
  parameter COUNTER_MAX_CNT = CLOCK_FREQ / 2 - 1;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      r_cnt <= 'b0;
      led   <= 'b0;
    end else begin
      r_cnt <= r_cnt + 1'b1;
      if (r_cnt == COUNTER_MAX_CNT) begin
        r_cnt <= 'b0;
        led   <= ~led;
      end
    end
  end

  spi_ctrl u_spi_ctrl (
      .clk  (clk),
      .rst_n(rst_n),
      .cs_n (cs_n),
      .sck  (sck),
      .mosi (mosi),
      .miso (miso)
  );
endmodule
