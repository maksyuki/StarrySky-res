module audio_send #(
    parameter WL = 6'd32
) (
    input             rst_n,
    input             aud_bclk,
    input             aud_lrc,
    output reg        aud_dacdat,
    input      [31:0] dac_data,
    output reg        tx_done
);

  reg         aud_lrc_d0;
  reg  [ 5:0] tx_cnt;
  reg  [31:0] dac_data_t;
  wire        lrc_edge;

  assign lrc_edge = aud_lrc ^ aud_lrc_d0;

  always @(posedge aud_bclk or negedge rst_n) begin
    if (!rst_n) aud_lrc_d0 <= 1'b0;
    else aud_lrc_d0 <= aud_lrc;
  end

  always @(posedge aud_bclk or negedge rst_n) begin
    if (!rst_n) begin
      tx_cnt     <= 6'd0;
      dac_data_t <= 32'd0;
    end else if (lrc_edge == 1'b1) begin
      tx_cnt     <= 6'd0;
      dac_data_t <= dac_data;
    end else if (tx_cnt < 6'd35) tx_cnt <= tx_cnt + 1'b1;
  end

  always @(posedge aud_bclk or negedge rst_n) begin
    if (!rst_n) begin
      tx_done <= 1'b0;
    end else if (tx_cnt == 6'd31) tx_done <= 1'b1;
    else tx_done <= 1'b0;
  end

  always @(negedge aud_bclk or negedge rst_n) begin
    if (!rst_n) begin
      aud_dacdat <= 1'b0;
    end else if (tx_cnt < WL) aud_dacdat <= dac_data_t[WL-1'd1-tx_cnt];
    else aud_dacdat <= 1'b0;
  end

endmodule
