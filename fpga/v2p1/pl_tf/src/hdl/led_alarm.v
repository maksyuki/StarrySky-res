module led_alarm #(
    parameter L_TIME = 25'd25_000_000
) (
    input  clk,
    input  rst_n,
    output led,
    input  error_flag
);

  reg        led_t;
  reg [24:0] led_cnt;

  assign led = led_t;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      led_cnt <= 25'd0;
      led_t   <= 1'b0;
    end else begin
      if (error_flag) begin
        if (led_cnt == L_TIME - 1'b1) begin
          led_cnt <= 25'd0;
          led_t   <= ~led_t;
        end else led_cnt <= led_cnt + 25'd1;
      end else begin
        led_cnt <= 25'd0;
        led_t   <= 1'b1;
      end
    end
  end

endmodule
