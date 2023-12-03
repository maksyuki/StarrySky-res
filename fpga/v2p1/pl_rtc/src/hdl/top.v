module top (
    input      clk,
    input      rst_n,
    output reg led,
    output     i2c_scl,
    inout      i2c_sda
);

  reg [31:0] r_cnt;
  parameter CLOCK_FREQ = 50000000;
  parameter COUNTER_MAX_CNT = CLOCK_FREQ / 2 - 1;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      r_cnt <= 'b0;
      led   <= 'b0;
    end else begin
      r_cnt <= r_cnt + 1'b1;
      if (r_cnt == COUNTER_MAX_CNT) begin
        r_cnt <= 'b0;
        led   <= ~led;
      end
    end
  end



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
