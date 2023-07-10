`timescale 1ns / 1ps

module spi_ctrl (
    input clk,
    input rst_n,

    (* MARK_DEBUG = "TRUE" *) output reg cs_n,
    (* MARK_DEBUG = "TRUE" *) output reg sck,
    (* MARK_DEBUG = "TRUE" *) output reg mosi,
    (* MARK_DEBUG = "TRUE" *) input miso
);

  localparam IDLE = 3'b001;
  localparam ID = 3'b010;
  localparam DONE = 3'b100;
  localparam ID_INST = 8'h9F;

  reg [4:0] cnt_clk;
  reg [2:0] cnt_bit;
  reg [1:0] cnt_sck;
  reg [2:0] cnt_byte;
  reg [7:0] cnt_read;
  (* MARK_DEBUG = "TRUE" *) reg rd_flag;
  (* MARK_DEBUG = "TRUE" *) reg [7:0] rd_data;
  reg [2:0] state;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cnt_clk <= 5'd0;
    else if (state == ID) cnt_clk <= cnt_clk + 1'd1;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cnt_byte <= 3'd0;
    else if ((cnt_clk == 5'd31) && (cnt_byte == 3'd3)) cnt_byte <= 3'd0;
    else if (cnt_clk == 5'd31) cnt_byte <= cnt_byte + 1'd1;
  end

  //sck
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cnt_sck <= 2'd0;
    else if (state == ID) cnt_sck <= cnt_sck + 1'd1;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) sck <= 1'd0;
    else if (cnt_sck == 2'd0) sck <= 1'd0;
    else if (cnt_sck == 2'd2) sck <= 1'd1;
  end

  // cs
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cnt_read <= 8'd0;
    else if (cnt_read < 8'd255) cnt_read <= cnt_read + 1'd1;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cs_n <= 1'd1;
    else if (cnt_read == 8'd255) cs_n <= 1'd0;
    else if ((cnt_byte == 3'd3) && (cnt_clk == 5'd31) && (state == ID)) cs_n <= 1'd1;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cnt_bit <= 3'd0;
    else if (cnt_sck == 2'd2) cnt_bit <= cnt_bit + 1'd1;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= IDLE;
    else begin
      case (state)
        IDLE: if (cnt_read == 8'd255) state <= ID;
        ID:   if ((cnt_byte == 3'd3) && (cnt_clk == 5'd31)) state <= DONE;
        DONE: state <= state;
        default: begin
          state <= IDLE;
        end
      endcase
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) mosi <= 1'd0;
    else if ((state == ID) && (cnt_byte >= 3'd1)) mosi <= 1'd0;
    else if ((state == ID) && (cnt_byte == 3'd0) && (cnt_sck == 2'd0)) mosi <= ID_INST[7-cnt_bit];
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) rd_flag <= 1'd0;
    else if (cnt_byte >= 3'd1 && (cnt_sck == 2'd1)) rd_flag <= 1'd1;
    else rd_flag <= 1'd0;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) rd_data <= 8'd0;
    else if (rd_flag) rd_data <= {rd_data[6:0], miso};
  end
endmodule
