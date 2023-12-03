module audio_ctrl (
    input         clk,
    input         rst_n,
    input         aud_bclk,
    input         aud_lrc,
    input         aud_adcdat,
    output        aud_dacdat,
    output        aud_scl,
    inout         aud_sda,
    output [31:0] adc_data,
    input  [31:0] dac_data,
    output        rx_done,
    output        tx_done
);

  parameter WL = 6'd16;

  audio_config #(
      .WL(WL)
  ) u_audio_config (
      .clk    (clk),
      .rst_n  (rst_n),
      .aud_scl(aud_scl),
      .aud_sda(aud_sda)
  );

  audio_receive #(
      .WL(WL)
  ) u_audio_receive (
      .rst_n     (rst_n),
      .aud_bclk  (aud_bclk),
      .aud_lrc   (aud_lrc),
      .aud_adcdat(aud_adcdat),
      .adc_data  (adc_data),
      .rx_done   (rx_done)
  );

  audio_send #(
      .WL(WL)
  ) u_audio_send (
      .rst_n     (rst_n),
      .aud_bclk  (aud_bclk),
      .aud_lrc   (aud_lrc),
      .aud_dacdat(aud_dacdat),
      .dac_data  (dac_data),
      .tx_done   (tx_done)
  );

endmodule
