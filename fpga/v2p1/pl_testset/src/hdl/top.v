module top (
    input         clk,
    input         rst_n,
    input         ps2_clk,
    input         ps2_data,
    output        hsync,
    output        vsync,
    output [11:0] rgb,
    output        led,
    output        ws2812,
    output        lcd_clk,
    output        lcd_cs,
    output        lcd_rs,
    output        lcd_data,
    input         uart_rxd,
    output        uart_txd,
    output        aud_lrc,
    output        aud_bclk,
    input         aud_adcdat,
    output        aud_mclk,
    output        aud_dacdat,
    output        aud_scl,
    inout         aud_sda
);

  parameter CLK_FREQ = 50000000;
  parameter UART_BPS = 115200;

  wire [ 7:0] data;
  wire        vga_clk;
  wire [11:0] pix_x;
  wire [11:0] pix_y;
  wire [11:0] pix_data;

  ps2_ctrl u_ps2_ctrl (
      .clk     (clk),
      .rst_n   (rst_n),
      .ps2_clk (ps2_clk),
      .ps2_data(ps2_data),
      .data    (data)
  );

  assign vga_clk = clk;

  vga_ctrl u_vga_ctrl (
      .vga_clk (vga_clk),
      .rst_n   (rst_n),
      .pix_data(pix_data),

      .pix_x(pix_x),
      .pix_y(pix_y),
      .hsync(hsync),
      .vsync(vsync),
      .rgb  (rgb)
  );

  vga_pic u_vga_pic (
      .vga_clk (vga_clk),
      .rst_n   (rst_n),
      .pix_x   (pix_x),
      .pix_y   (pix_y),
      .data    (data),
      .pix_data(pix_data)

  );

  led_ctrl u_led_ctrl (
      .clk  (clk),
      .rst_n(rst_n),
      .led  (led)
  );

  ws2812_ctrl u_ws2812_ctrl (
      .clk  (clk),
      .rst_n(rst_n),
      .led  (ws2812)
  );


  lcd_ctrl u_lcd_ctrl (
      .clk     (clk),
      .rst_n   (rst_n),
      .lcd_clk (lcd_clk),
      .lcd_cs  (lcd_cs),
      .lcd_rs  (lcd_rs),
      .lcd_data(lcd_data)
  );

  uart_top #(CLK_FREQ, UART_BPS) u_uart_top (
      .clk     (clk),
      .rst_n   (rst_n),
      .uart_rxd(uart_rxd),
      .uart_txd(uart_txd)
  );

  audio_loopback u_audio_loopback (
      .clk       (clk),
      .rst_n     (rst_n),
      .aud_lrc   (aud_lrc),
      .aud_bclk  (aud_bclk),
      .aud_adcdat(aud_adcdat),
      .aud_mclk  (aud_mclk),
      .aud_dacdat(aud_dacdat),
      .aud_scl   (aud_scl),
      .aud_sda   (aud_sda)
  );
endmodule
