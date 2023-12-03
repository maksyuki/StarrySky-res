module audio_loopback (
    input  clk,
    input  rst_n,
    output aud_lrc,
    output aud_bclk,
    input  aud_adcdat,
    output aud_mclk,
    output aud_dacdat,
    output aud_scl,
    inout  aud_sda
);

  // parameter    WL = 6'd16;
  parameter WL = 6'd24;

  wire [31:0] adc_data;

  clk_wiz_0 u_clk_wiz_0 (
      .clk_out1(aud_mclk),
      .reset   (~rst_n),
      .clk_in1 (clk)
  );


  slave_signal_gen u_slave_signal_gen (
      .clk     (aud_mclk),
      .rst_n   (rst_n),
      .aud_bclk(aud_bclk),
      .aud_lrc (aud_lrc)
  );

  audio_ctrl #(
      .WL(WL)
  ) u_audio_ctrl (
      .clk       (clk),
      .rst_n     (rst_n),
      .aud_bclk  (aud_bclk),
      .aud_lrc   (aud_lrc),
      .aud_adcdat(aud_adcdat),
      // .aud_dacdat         (aud_dacdat ),
      .aud_dacdat(aud_dacdat),
      .aud_scl   (aud_scl),
      .aud_sda   (aud_sda),
      .adc_data  (adc_data),
      .dac_data  (adc_data),
      .rx_done   (),
      .tx_done   ()
  );

endmodule
