`timescale 1ns / 1ps

module i2c_drv #(
    parameter DEVICE_ADDR = 7'b1010_000,
    parameter CLK_FREQ    = 26'd50_000_000,
    parameter SCL_FREQ    = 18'd250_000
) (
    input        clk,
    input        rst_n,
    input        wr_en,
    input        rd_en,
    input        i2c_start,
    input        addr_num,
    input [15:0] byte_addr,
    input [ 7:0] wr_data,

    output reg       i2c_clk,
    output reg       i2c_end,
    output reg [7:0] rd_data,
    output reg       i2c_scl,
    inout            i2c_sda
);

  localparam CNT_CLK_MAX = (CLK_FREQ / SCL_FREQ) >> 2'd3;
  localparam CNT_START_MAX = 8'd100;
  localparam IDLE = 4'd00;
  localparam START_1 = 4'd01;
  localparam SEND_D_ADDR = 4'd02;
  localparam ACK_1 = 4'd03;
  localparam SEND_B_ADDR_H = 4'd04;
  localparam ACK_2 = 4'd05;
  localparam SEND_B_ADDR_L = 4'd06;
  localparam ACK_3 = 4'd07;
  localparam WR_DATA = 4'd08;
  localparam ACK_4 = 4'd09;
  localparam START_2 = 4'd10;
  localparam SEND_RD_ADDR = 4'd11;
  localparam ACK_5 = 4'd12;
  localparam RD_DATA = 4'd13;
  localparam N_ACK = 4'd14;
  localparam STOP = 4'd15;

  wire       sda_in;
  wire       sda_en;
  reg  [7:0] cnt_clk;
  reg  [3:0] state;
  reg        cnt_i2c_clk_en;
  reg  [1:0] cnt_i2c_clk;
  reg  [2:0] cnt_bit;
  reg        ack;
  reg        i2c_sda_reg;
  reg  [7:0] rd_data_reg;

  always @(posedge clk or negedge rst_n)
    if (rst_n == 1'b0) cnt_clk <= 8'd0;
    else if (cnt_clk == CNT_CLK_MAX - 1'b1) cnt_clk <= 8'd0;
    else cnt_clk <= cnt_clk + 1'b1;

  always @(posedge clk or negedge rst_n)
    if (rst_n == 1'b0) i2c_clk <= 1'b1;
    else if (cnt_clk == CNT_CLK_MAX - 1'b1) i2c_clk <= ~i2c_clk;

  always @(posedge i2c_clk or negedge rst_n)
    if (rst_n == 1'b0) cnt_i2c_clk_en <= 1'b0;
    else if ((state == STOP) && (cnt_bit == 3'd3) && (cnt_i2c_clk == 3)) cnt_i2c_clk_en <= 1'b0;
    else if (i2c_start == 1'b1) cnt_i2c_clk_en <= 1'b1;

  always @(posedge i2c_clk or negedge rst_n)
    if (rst_n == 1'b0) cnt_i2c_clk <= 2'd0;
    else if (cnt_i2c_clk_en == 1'b1) cnt_i2c_clk <= cnt_i2c_clk + 1'b1;

  always @(posedge i2c_clk or negedge rst_n)
    if (rst_n == 1'b0) cnt_bit <= 3'd0;
    else    if((state == IDLE) || (state == START_1) || (state == START_2)
                || (state == ACK_1) || (state == ACK_2) || (state == ACK_3)
                || (state == ACK_4) || (state == ACK_5) || (state == N_ACK))
      cnt_bit <= 3'd0;
    else if ((cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3)) cnt_bit <= 3'd0;
    else if ((cnt_i2c_clk == 2'd3) && (state != IDLE)) cnt_bit <= cnt_bit + 1'b1;


  always @(posedge i2c_clk or negedge rst_n)
    if (rst_n == 1'b0) state <= IDLE;
    else
      case (state)
        IDLE:
        if (i2c_start == 1'b1) state <= START_1;
        else state <= state;
        START_1:
        if (cnt_i2c_clk == 3) state <= SEND_D_ADDR;
        else state <= state;
        SEND_D_ADDR:
        if ((cnt_bit == 3'd7) && (cnt_i2c_clk == 3)) state <= ACK_1;
        else state <= state;
        ACK_1:
        if ((cnt_i2c_clk == 3) && (ack == 1'b0)) begin
          if (addr_num == 1'b1) state <= SEND_B_ADDR_H;
          else state <= SEND_B_ADDR_L;
        end else state <= state;
        SEND_B_ADDR_H:
        if ((cnt_bit == 3'd7) && (cnt_i2c_clk == 3)) state <= ACK_2;
        else state <= state;
        ACK_2:
        if ((cnt_i2c_clk == 3) && (ack == 1'b0)) state <= SEND_B_ADDR_L;
        else state <= state;
        SEND_B_ADDR_L:
        if ((cnt_bit == 3'd7) && (cnt_i2c_clk == 3)) state <= ACK_3;
        else state <= state;
        ACK_3:
        if ((cnt_i2c_clk == 3) && (ack == 1'b0)) begin
          if (wr_en == 1'b1) state <= WR_DATA;
          else if (rd_en == 1'b1) state <= START_2;
          else state <= state;
        end else state <= state;
        WR_DATA:
        if ((cnt_bit == 3'd7) && (cnt_i2c_clk == 3)) state <= ACK_4;
        else state <= state;
        ACK_4:
        if ((cnt_i2c_clk == 3) && (ack == 1'b0)) state <= STOP;
        else state <= state;
        START_2:
        if (cnt_i2c_clk == 3) state <= SEND_RD_ADDR;
        else state <= state;
        SEND_RD_ADDR:
        if ((cnt_bit == 3'd7) && (cnt_i2c_clk == 3)) state <= ACK_5;
        else state <= state;
        ACK_5:
        if ((cnt_i2c_clk == 3) && (ack == 1'b0)) state <= RD_DATA;
        else state <= state;
        RD_DATA:
        if ((cnt_bit == 3'd7) && (cnt_i2c_clk == 3)) state <= N_ACK;
        else state <= state;
        N_ACK:
        if (cnt_i2c_clk == 3) state <= STOP;
        else state <= state;
        STOP:
        if ((cnt_bit == 3'd3) && (cnt_i2c_clk == 3)) state <= IDLE;
        else state <= state;
        default: state <= IDLE;
      endcase


  always @(*)
    case (state)
      IDLE,START_1,SEND_D_ADDR,SEND_B_ADDR_H,SEND_B_ADDR_L,
        WR_DATA,START_2,SEND_RD_ADDR,RD_DATA,N_ACK:
      ack <= 1'b1;
      ACK_1, ACK_2, ACK_3, ACK_4, ACK_5:
      if (cnt_i2c_clk == 2'd0) ack <= sda_in;
      else ack <= ack;
      default: ack <= 1'b1;
    endcase


  always @(*)
    case (state)
      IDLE: i2c_scl <= 1'b1;
      START_1:
      if (cnt_i2c_clk == 2'd3) i2c_scl <= 1'b0;
      else i2c_scl <= 1'b1;
      SEND_D_ADDR,ACK_1,SEND_B_ADDR_H,ACK_2,SEND_B_ADDR_L,
        ACK_3,WR_DATA,ACK_4,START_2,SEND_RD_ADDR,ACK_5,RD_DATA,N_ACK:
      if ((cnt_i2c_clk == 2'd1) || (cnt_i2c_clk == 2'd2)) i2c_scl <= 1'b1;
      else i2c_scl <= 1'b0;
      STOP:
      if ((cnt_bit == 3'd0) && (cnt_i2c_clk == 2'd0)) i2c_scl <= 1'b0;
      else i2c_scl <= 1'b1;
      default: i2c_scl <= 1'b1;
    endcase


  always @(*)
    case (state)
      IDLE: begin
        i2c_sda_reg <= 1'b1;
        rd_data_reg <= 8'd0;
      end
      START_1:
      if (cnt_i2c_clk <= 2'd0) i2c_sda_reg <= 1'b1;
      else i2c_sda_reg <= 1'b0;
      SEND_D_ADDR:
      if (cnt_bit <= 3'd6) i2c_sda_reg <= DEVICE_ADDR[6-cnt_bit];
      else i2c_sda_reg <= 1'b0;
      ACK_1: i2c_sda_reg <= 1'b1;
      SEND_B_ADDR_H: i2c_sda_reg <= byte_addr[15-cnt_bit];
      ACK_2: i2c_sda_reg <= 1'b1;
      SEND_B_ADDR_L: i2c_sda_reg <= byte_addr[7-cnt_bit];
      ACK_3: i2c_sda_reg <= 1'b1;
      WR_DATA: i2c_sda_reg <= wr_data[7-cnt_bit];
      ACK_4: i2c_sda_reg <= 1'b1;
      START_2:
      if (cnt_i2c_clk <= 2'd1) i2c_sda_reg <= 1'b1;
      else i2c_sda_reg <= 1'b0;
      SEND_RD_ADDR:
      if (cnt_bit <= 3'd6) i2c_sda_reg <= DEVICE_ADDR[6-cnt_bit];
      else i2c_sda_reg <= 1'b1;
      ACK_5: i2c_sda_reg <= 1'b1;
      RD_DATA:
      if (cnt_i2c_clk == 2'd2) rd_data_reg[7-cnt_bit] <= sda_in;
      else rd_data_reg <= rd_data_reg;
      N_ACK: i2c_sda_reg <= 1'b1;
      STOP:
      if ((cnt_bit == 3'd0) && (cnt_i2c_clk < 2'd3)) i2c_sda_reg <= 1'b0;
      else i2c_sda_reg <= 1'b1;
      default: begin
        i2c_sda_reg <= 1'b1;
        rd_data_reg <= rd_data_reg;
      end
    endcase

  always @(posedge i2c_clk or negedge rst_n)
    if (rst_n == 1'b0) rd_data <= 8'd0;
    else if ((state == RD_DATA) && (cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3))
      rd_data <= rd_data_reg;


  always @(posedge i2c_clk or negedge rst_n)
    if (rst_n == 1'b0) i2c_end <= 1'b0;
    else if ((state == STOP) && (cnt_bit == 3'd3) && (cnt_i2c_clk == 3)) i2c_end <= 1'b1;
    else i2c_end <= 1'b0;


  assign sda_in = i2c_sda;

  assign  sda_en = ((state == RD_DATA) || (state == ACK_1) || (state == ACK_2)
                    || (state == ACK_3) || (state == ACK_4) || (state == ACK_5))
                    ? 1'b0 : 1'b1;

  assign i2c_sda = (sda_en == 1'b1) ? i2c_sda_reg : 1'bz;

endmodule
