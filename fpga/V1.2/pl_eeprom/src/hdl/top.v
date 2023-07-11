`timescale 1ns / 1ps
module top (
    input  clk,
    input  rst_n,
    output i2c_scl,
    inout  i2c_sda,
    output led
);
  parameter SLAVE_ADDR = 7'b101_0000;
  parameter BIT_CTRL = 1'b1;
  parameter CLK_FREQ = 26'd50_000_000;
  parameter I2C_FREQ = 18'd250_000;

  wire        drv_clk;
  wire        i2c_exec;
  wire [15:0] i2c_addr;
  wire [ 7:0] i2c_data_w;
  wire        i2c_done;
  wire        i2c_ack;
  wire        i2c_rh_wl;
  wire [ 7:0] i2c_data_r;
  wire        rw_done;
  wire        rw_res;

  e2prom_ctrl u_e2prom_ctrl (
      .clk  (drv_clk),
      .rst_n(rst_n),
      .i2c_exec  (i2c_exec),
      .i2c_rh_wl (i2c_rh_wl),
      .i2c_addr  (i2c_addr),
      .i2c_data_w(i2c_data_w),
      .i2c_data_r(i2c_data_r),
      .i2c_done  (i2c_done),
      .i2c_ack   (i2c_ack),
      .rw_done  (rw_done),
      .rw_res(rw_res)
  );


  i2c_drv #(
      .SLAVE_ADDR(SLAVE_ADDR),
      .CLK_FREQ  (CLK_FREQ),
      .I2C_FREQ  (I2C_FREQ)
  ) u_i2c_drv (
      .clk       (clk),
      .rst_n     (rst_n),
      .i2c_exec  (i2c_exec),
      .bit_ctrl  (BIT_CTRL),
      .i2c_rh_wl (i2c_rh_wl),
      .i2c_addr  (i2c_addr),
      .i2c_data_w(i2c_data_w),
      .i2c_data_r(i2c_data_r),
      .i2c_done  (i2c_done),
      .i2c_ack   (i2c_ack),
      .scl       (i2c_scl),
      .sda       (i2c_sda),
      .drv_clk   (drv_clk)
  );

  led_stream u_led_stream (
      .clk(clk),
      .rst_n(rst_n),
      .rw_done(rw_done),
      .rw_res(rw_res),
      .led(led)
  );
endmodule
