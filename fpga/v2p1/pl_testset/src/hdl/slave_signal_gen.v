module slave_signal_gen (
    input      clk,
    input      rst_n,
    output reg aud_bclk,
    output reg aud_lrc
);

  parameter FREQ_DIV = 11'd256;

  reg [10:0] lrc_div_cnt;
  reg [ 7:0] bclk_div_cnt;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      lrc_div_cnt <= 1'b0;
      aud_lrc     <= 1'b0;
    end else begin
      if (lrc_div_cnt == FREQ_DIV[10:1] - 1'b1) begin
        lrc_div_cnt <= 1'b0;
        aud_lrc     <= ~aud_lrc;
      end else lrc_div_cnt <= lrc_div_cnt + 1'b1;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bclk_div_cnt <= 1'b0;
      aud_bclk     <= 1'b0;
    end else begin
      if (bclk_div_cnt == FREQ_DIV[10:7] - 1'b1) begin
        bclk_div_cnt <= 1'b0;
        aud_bclk     <= ~aud_bclk;
      end else bclk_div_cnt <= bclk_div_cnt + 1'b1;
    end
  end

endmodule
