`timescale 1ns / 1ps

module top (
    input  clk,
    input  rst_n,
    output uclk,
    output led,
    output i2c_scl,
    inout  i2c_sda,
    output cs_n,
    output sck,
    output mosi,
    input  miso
);

  pl_uclk u_pl_uclk (
      .clk  (clk),
      .rst_n(rst_n),
      .uclk (uclk)
  );

  led_stream u_led_stream (
      .clk  (clk),
      .rst_n(rst_n),
      .led  (led)
  );

  spi_ctrl u_spi_ctrl (
      .clk  (clk),
      .rst_n(rst_n),
      .cs_n (cs_n),
      .sck  (sck),
      .mosi (mosi),
      .miso (miso)
  );

  parameter TIME_INIT = 48'h19_09_09_16_15_20;

  wire        i2c_clk;
  wire        i2c_end;
  wire [ 7:0] rd_data;
  wire        wr_en;
  wire        rd_en;
  wire        i2c_start;
  wire [15:0] byte_addr;
  wire [ 7:0] wr_data;
  wire [23:0] data_out;

  rtc_ctrl #(
      .TIME_INIT(TIME_INIT)
  ) u_rtc_ctrl (
      .clk      (clk),
      .i2c_clk  (i2c_clk),
      .rst_n    (rst_n),
      .i2c_end  (i2c_end),
      .rd_data  (rd_data),
      .key_flag (1'd0),
      .wr_en    (wr_en),
      .rd_en    (rd_en),
      .i2c_start(i2c_start),
      .byte_addr(byte_addr),
      .wr_data  (wr_data),
      .data_out (data_out)
  );

  i2c_drv #(
      .DEVICE_ADDR(7'b1010_001),
      .CLK_FREQ   (26'd50_000_000),
      .SCL_FREQ   (18'd250_000)
  ) u_i2c_drv (
      .clk      (clk),
      .rst_n    (rst_n),
      .wr_en    (wr_en),
      .rd_en    (rd_en),
      .i2c_start(i2c_start),
      .addr_num (1'b0),
      .byte_addr(byte_addr),
      .wr_data  (wr_data),

      .i2c_clk(i2c_clk),
      .i2c_end(i2c_end),
      .rd_data(rd_data),
      .i2c_scl(i2c_scl),
      .i2c_sda(i2c_sda)
  );

endmodule
