`timescale 1ns / 1ps

module vga_ctrl (
    input        vga_clk,
    input        rst_n,
    input [11:0] pix_data,

    output [11:0] pix_x,
    output [11:0] pix_y,
    output        hsync,
    output        vsync,
    output [11:0] rgb
);

  localparam H_SYNC = 10'd120;
  localparam H_BACK = 10'd32;
  localparam H_LEFT = 10'd32;
  localparam H_VALID = 10'd800;
  localparam H_TOTAL = 12'd1040;

  localparam V_SYNC = 10'd6;
  localparam V_BACK = 10'd20;
  localparam V_TOP = 10'd3;
  localparam V_VALID = 10'd600;
  localparam V_TOTAL = 10'd666;

  wire        rgb_valid;
  wire        pix_data_req;
  reg  [11:0] cnt_h;
  reg  [11:0] cnt_v;

  always @(posedge vga_clk or negedge rst_n)
    if (rst_n == 1'b0) cnt_h <= 10'd0;
    else if (cnt_h == H_TOTAL - 1'd1) cnt_h <= 10'd0;
    else cnt_h <= cnt_h + 1'd1;

  assign hsync = (cnt_h <= H_SYNC - 1'd1) ? 1'b1 : 1'b0;

  always @(posedge vga_clk or negedge rst_n)
    if (rst_n == 1'b0) cnt_v <= 10'd0;
    else if ((cnt_v == V_TOTAL - 1'd1) && (cnt_h == H_TOTAL - 1'd1)) cnt_v <= 10'd0;
    else if (cnt_h == H_TOTAL - 1'd1) cnt_v <= cnt_v + 1'd1;
    else cnt_v <= cnt_v;

  assign vsync = (cnt_v <= V_SYNC - 1'd1) ? 1'b1 : 1'b0;

  assign  rgb_valid = (((cnt_h >= H_SYNC + H_BACK + H_LEFT)
                    && (cnt_h < H_SYNC + H_BACK + H_LEFT + H_VALID))
                    &&((cnt_v >= V_SYNC + V_BACK + V_TOP)
                    && (cnt_v < V_SYNC + V_BACK + V_TOP + V_VALID)))
                    ? 1'b1 : 1'b0;

  assign  pix_data_req = (((cnt_h >= H_SYNC + H_BACK + H_LEFT - 1'b1)
                    && (cnt_h < H_SYNC + H_BACK + H_LEFT + H_VALID - 1'b1))
                    &&((cnt_v >= V_SYNC + V_BACK + V_TOP)
                    && (cnt_v < V_SYNC + V_BACK + V_TOP + V_VALID)))
                    ? 1'b1 : 1'b0;


  assign pix_x = (pix_data_req == 1'b1) ? (cnt_h - (H_SYNC + H_BACK + H_LEFT - 1'b1)) : 12'hfff;
  assign pix_y = (pix_data_req == 1'b1) ? (cnt_v - (V_SYNC + V_BACK + V_TOP)) : 12'hfff;
  assign rgb = (rgb_valid == 1'b1) ? pix_data : 12'd0;
endmodule
