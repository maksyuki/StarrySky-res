module led_stream (
    input      clk,
    input      rst_n,
    input      rw_done,
    input      rw_res,
    output reg led
);

  parameter CLOCK_FREQ = 50000000;
  parameter COUNTER_MAX_CNT = CLOCK_FREQ / 2 - 1;

  reg rw_done_reg;
  reg [31:0] cnt;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) rw_done_reg <= 1'd0;
    else rw_done_reg <= rw_done;
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= 31'd0;
      led <= 1'd0;
    end else begin
      if (rw_done_reg) begin
        if (rw_res) begin
          led <= 1'd1;
        end else begin
          cnt <= cnt + 1'b1;
          if (cnt == COUNTER_MAX_CNT) begin
            cnt <= 31'd0;
            led <= ~led;
          end
        end
      end else begin
        led <= 1'd0;
      end
    end
  end
endmodule

