`timescale 1ns / 1ps
module top (
    input         clk,
    input         rst_n,
    output        ws2812,
    input         ps2_clk,
    input         ps2_data,
    output        hsync,
    output        vsync,
    output [11:0] rgb
);

  wire [ 7:0] data;
  reg         vga_clk;
  wire [ 9:0] pix_x;
  wire [ 9:0] pix_y;
  wire [11:0] pix_data;

  ps2_ctrl u_ps2_ctrl (
      .clk(clk),
      .rst_n(rst_n),
      .ps2_clk(ps2_clk),
      .ps2_data(ps2_data),
      .data(data)
  );

  ws2812_ctrl u_ws2812_ctrl (
      .clk  (clk),
      .rst_n(rst_n),
      .led  (ws2812)
  );

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) vga_clk <= 1'd0;
    else vga_clk <= ~vga_clk;
  end

  vga_ctrl u_vga_ctrl (
      .vga_clk(vga_clk),
      .rst_n(rst_n),
      .pix_data(pix_data),

      .pix_x(pix_x),
      .pix_y(pix_y),
      .hsync(hsync),
      .vsync(vsync),
      .rgb  (rgb)
  );

  vga_pic u_vga_pic (
      .vga_clk(vga_clk),
      .rst_n(rst_n),
      .pix_x(pix_x),
      .pix_y(pix_y),
      .data(data),
      .pix_data(pix_data)

  );
endmodule
