`timescale 1ns / 1ps

module vga_pic (
    input             vga_clk,
    input             rst_n,
    input      [11:0] pix_x,
    input      [11:0] pix_y,    // no used
    input      [ 7:0] data,
    output reg [11:0] pix_data
);

  // localparam H_VALID = 10'd640;
  // localparam V_VALID = 10'd480;
  localparam H_VALID = 10'd800;
  localparam V_VALID = 10'd600;
  localparam RED = 12'hF00;
  localparam ORANGE = 12'hFA0;  //FFA500
  localparam YELLOW = 12'hFF0;
  localparam GREEN = 12'h080;  // 008000
  localparam CYAN = 12'h0B8;  //0DBF8C
  localparam BLUE = 12'h00F;
  localparam PURPLE = 12'h808;  // 800080
  localparam BLACK = 12'h000;
  localparam WHITE = 12'hFFF;
  localparam GRAY = 12'h888;  // 808080

  always @(posedge vga_clk or negedge rst_n)
    if (rst_n == 1'b0) pix_data <= 12'd0;
    else if (data == 8'h1C) pix_data <= GREEN;
    else if ((pix_x >= 0) && (pix_x < (H_VALID / 10) * 1)) pix_data <= RED;
    else if ((pix_x >= (H_VALID / 10) * 1) && (pix_x < (H_VALID / 10) * 2)) pix_data <= ORANGE;
    else if ((pix_x >= (H_VALID / 10) * 2) && (pix_x < (H_VALID / 10) * 3)) pix_data <= YELLOW;
    else if ((pix_x >= (H_VALID / 10) * 3) && (pix_x < (H_VALID / 10) * 4)) pix_data <= GREEN;
    else if ((pix_x >= (H_VALID / 10) * 4) && (pix_x < (H_VALID / 10) * 5)) pix_data <= CYAN;
    else if ((pix_x >= (H_VALID / 10) * 5) && (pix_x < (H_VALID / 10) * 6)) pix_data <= BLUE;
    else if ((pix_x >= (H_VALID / 10) * 6) && (pix_x < (H_VALID / 10) * 7)) pix_data <= PURPLE;
    else if ((pix_x >= (H_VALID / 10) * 7) && (pix_x < (H_VALID / 10) * 8)) pix_data <= BLACK;
    else if ((pix_x >= (H_VALID / 10) * 8) && (pix_x < (H_VALID / 10) * 9)) pix_data <= WHITE;
    else if ((pix_x >= (H_VALID / 10) * 9) && (pix_x < H_VALID)) pix_data <= GRAY;
    else pix_data <= BLACK;

endmodule
