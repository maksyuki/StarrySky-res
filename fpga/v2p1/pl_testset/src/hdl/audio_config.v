module audio_config (
    input clk,
    input rst_n,

    output aud_scl,
    inout  aud_sda
);

  parameter SLAVE_ADDR = 7'h10;
  parameter WL = 6'd16;
  parameter BIT_CTRL = 1'b0;
  parameter CLK_FREQ = 26'd50_000_000;
  parameter I2C_FREQ = 18'd250_000;

  wire        dri_clk;
  wire        i2c_exec;
  wire        i2c_done;
  wire        i2c_rh_wl;
  wire        cfg_done;
  wire [15:0] reg_data;

  i2c_reg_cfg #(
      .WL(WL)
  ) u_i2c_reg_cfg (
      .clk  (dri_clk),
      .rst_n(rst_n),

      .i2c_exec (i2c_exec),
      .i2c_data (reg_data),
      .i2c_rh_wl(i2c_rh_wl),
      .i2c_done (i2c_done),
      .cfg_done (cfg_done)
  );

  i2c_dri #(
      .SLAVE_ADDR(SLAVE_ADDR),
      .CLK_FREQ  (CLK_FREQ),
      .I2C_FREQ  (I2C_FREQ)
  ) u_i2c_dri (
      .clk  (clk),
      .rst_n(rst_n),

      .i2c_exec  (i2c_exec),
      .bit_ctrl  (BIT_CTRL),
      .i2c_rh_wl (i2c_rh_wl),
      .i2c_ack   (),
      .i2c_addr  (reg_data[15:8]),
      .i2c_data_w(reg_data[7:0]),

      .i2c_data_r(),
      .i2c_done  (i2c_done),

      .scl    (aud_scl),
      .sda    (aud_sda),
      .dri_clk(dri_clk)
  );

endmodule
