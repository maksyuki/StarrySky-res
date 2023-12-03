module audio_receive #(
    parameter WL = 6'd32
) (
    input             rst_n,
    input             aud_bclk,
    input             aud_lrc,
    input             aud_adcdat,
    output reg        rx_done,
    output reg [31:0] adc_data
);

  reg         aud_lrc_d0;
  reg  [ 5:0] rx_cnt;
  reg  [31:0] adc_data_t;
  wire        lrc_edge;

  assign lrc_edge = aud_lrc ^ aud_lrc_d0;

  always @(posedge aud_bclk or negedge rst_n) begin
    if (!rst_n) aud_lrc_d0 <= 1'b0;
    else aud_lrc_d0 <= aud_lrc;
  end


  always @(posedge aud_bclk or negedge rst_n) begin
    if (!rst_n) begin
      rx_cnt <= 6'd0;
    end else if (lrc_edge == 1'b1) rx_cnt <= 6'd0;
    else if (rx_cnt < 6'd35) rx_cnt <= rx_cnt + 1'b1;
  end

  always @(posedge aud_bclk or negedge rst_n) begin
    if (!rst_n) begin
      adc_data_t <= 32'b0;
    end else if (rx_cnt < WL) adc_data_t[WL-1'd1-rx_cnt] <= aud_adcdat;
  end


  always @(posedge aud_bclk or negedge rst_n) begin
    if (!rst_n) begin
      rx_done  <= 1'b0;
      adc_data <= 32'b0;
    end else if (rx_cnt == 6'd31) begin
      rx_done  <= 1'b1;
      adc_data <= adc_data_t;
    end else rx_done <= 1'b0;
  end

endmodule
