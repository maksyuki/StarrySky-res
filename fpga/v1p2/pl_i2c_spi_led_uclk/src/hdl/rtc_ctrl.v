`timescale 1ns / 1ps

module rtc_ctrl #(
    parameter TIME_INIT = 48'h20_06_08_08_00_00
) (
    input             clk,
    input             rst_n,
    input             i2c_clk,
    input             i2c_end,
    input      [ 7:0] rd_data,
    input             key_flag,
    output reg        wr_en,
    output reg        rd_en,
    output reg        i2c_start,
    output reg [15:0] byte_addr,
    output reg [ 7:0] wr_data,
    output reg [23:0] data_out
);

  localparam S_WAIT = 4'd1;
  localparam INIT_SEC = 4'd2;
  localparam INIT_MIN = 4'd3;
  localparam INIT_HOUR = 4'd4;
  localparam INIT_DAY = 4'd5;
  localparam INIT_MON = 4'd6;
  localparam INIT_YEAR = 4'd7;
  localparam RD_SEC = 4'd8;
  localparam RD_MIN = 4'd9;
  localparam RD_HOUR = 4'd10;
  localparam RD_DAY = 4'd11;
  localparam RD_MON = 4'd12;
  localparam RD_YEAR = 4'd13;
  localparam CNT_WAIT_8MS = 8000;

  reg [ 7:0] year;
  reg [ 7:0] month;
  reg [ 7:0] day;
  (* MARK_DEBUG = "TRUE" *)reg [ 7:0] hour;
  (* MARK_DEBUG = "TRUE" *)reg [ 7:0] minute;
  (* MARK_DEBUG = "TRUE" *)reg [ 7:0] second;
  (* MARK_DEBUG = "TRUE" *)reg        data_flag;
  (* MARK_DEBUG = "TRUE" *)reg [ 3:0] state;
  (* MARK_DEBUG = "TRUE" *)reg [12:0] cnt_wait;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) data_flag <= 1'b0;
    else if (key_flag == 1'b1) data_flag <= ~data_flag;
    else data_flag <= data_flag;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) data_out <= 24'd0;
    else if (data_flag == 1'b0) data_out <= {hour, minute, second};
    else data_out <= {year, month, day};
  end

  always @(posedge i2c_clk or negedge rst_n) begin
    if (!rst_n) cnt_wait <= 13'd0;
    else    if((state==S_WAIT && cnt_wait==CNT_WAIT_8MS) || 
              (state==INIT_SEC && i2c_end==1'b1) || (state==INIT_MIN 
              && i2c_end==1'b1) || (state==INIT_HOUR && i2c_end==1'b1)
              || (state==INIT_DAY && i2c_end==1'b1) || (state==INIT_MON
              && i2c_end == 1'b1) || (state==INIT_YEAR && i2c_end==1'b1)
              || (state==RD_SEC && i2c_end==1'b1) || (state==RD_MIN && 
              i2c_end==1'b1) || (state==RD_HOUR && i2c_end==1'b1) || 
              (state==RD_DAY && i2c_end==1'b1) || (state==RD_MON && 
              i2c_end==1'b1) || (state==RD_YEAR && i2c_end==1'b1))
      cnt_wait <= 13'd0;
    else cnt_wait <= cnt_wait + 1'b1;
  end

  always @(posedge i2c_clk or negedge rst_n) begin
    if (!rst_n) state <= S_WAIT;
    else
      case (state)
        S_WAIT:
        if (cnt_wait == CNT_WAIT_8MS) state <= INIT_SEC;
        else state <= S_WAIT;

        INIT_SEC:
        if (i2c_end == 1'b1) state <= INIT_MIN;
        else state <= INIT_SEC;

        INIT_MIN:
        if (i2c_end == 1'b1) state <= INIT_HOUR;
        else state <= INIT_MIN;

        INIT_HOUR:
        if (i2c_end == 1'b1) state <= INIT_DAY;
        else state <= INIT_HOUR;

        INIT_DAY:
        if (i2c_end == 1'b1) state <= INIT_MON;
        else state <= INIT_DAY;

        INIT_MON:
        if (i2c_end == 1'b1) state <= INIT_YEAR;
        else state <= INIT_MON;

        INIT_YEAR:
        if (i2c_end == 1) state <= RD_SEC;
        else state <= INIT_YEAR;

        RD_SEC:
        if (i2c_end == 1'b1) state <= RD_MIN;
        else state <= RD_SEC;

        RD_MIN:
        if (i2c_end == 1'b1) state <= RD_HOUR;
        else state <= RD_MIN;

        RD_HOUR:
        if (i2c_end == 1'b1) state <= RD_DAY;
        else state <= RD_HOUR;

        RD_DAY:
        if (i2c_end == 1'b1) state <= RD_MON;
        else state <= RD_DAY;

        RD_MON:
        if (i2c_end == 1'b1) state <= RD_YEAR;
        else state <= RD_MON;

        RD_YEAR: begin
          if (i2c_end == 1'b1) state <= RD_SEC;
          else state <= RD_YEAR;
        end
        default: state <= S_WAIT;
      endcase
  end

  always @(posedge i2c_clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      wr_en     <= 1'b0;
      rd_en     <= 1'b0;
      i2c_start <= 1'b0;
      byte_addr <= 16'd0;
      wr_data   <= 8'd0;
      year      <= 8'd0;
      month     <= 8'd0;
      day       <= 8'd0;
      hour      <= 8'd0;
      minute    <= 8'd0;
      second    <= 8'd0;
    end else
      case (state)
        S_WAIT: begin
          wr_en     <= 1'b0;
          rd_en     <= 1'b0;
          i2c_start <= 1'b0;
          byte_addr <= 16'h0;
          wr_data   <= 8'h00;
        end
        INIT_SEC:
        if (cnt_wait == 13'd1) begin
          wr_en     <= 1'b1;
          i2c_start <= 1'b1;
          byte_addr <= 16'h02;
          wr_data   <= TIME_INIT[7:0];
        end else begin
          wr_en     <= 1'b1;
          i2c_start <= 1'b0;
          byte_addr <= 16'h02;
          wr_data   <= TIME_INIT[7:0];
        end
        INIT_MIN:
        if (cnt_wait == 13'd1) begin
          i2c_start <= 1'b1;
          byte_addr <= 16'h03;
          wr_data   <= TIME_INIT[15:8];
        end else begin
          i2c_start <= 1'b0;
          byte_addr <= 16'h03;
          wr_data   <= TIME_INIT[15:8];
        end
        INIT_HOUR:
        if (cnt_wait == 13'd1) begin
          i2c_start <= 1'b1;
          byte_addr <= 16'h04;
          wr_data   <= TIME_INIT[23:16];
        end else begin
          i2c_start <= 1'b0;
          byte_addr <= 16'h04;
          wr_data   <= TIME_INIT[23:16];
        end
        INIT_DAY:
        if (cnt_wait == 13'd1) begin
          i2c_start <= 1'b1;
          byte_addr <= 16'h05;
          wr_data   <= TIME_INIT[31:24];
        end else begin
          i2c_start <= 1'b0;
          byte_addr <= 16'h05;
          wr_data   <= TIME_INIT[31:24];
        end
        INIT_MON:
        if (cnt_wait == 13'd1) begin
          i2c_start <= 1'b1;
          byte_addr <= 16'h07;
          wr_data   <= TIME_INIT[39:32];
        end else begin
          i2c_start <= 1'b0;
          byte_addr <= 16'h07;
          wr_data   <= TIME_INIT[39:32];
        end
        INIT_YEAR:
        if (cnt_wait == 13'd1) begin
          i2c_start <= 1'b1;
          byte_addr <= 16'h08;
          wr_data   <= TIME_INIT[47:40];
        end else begin
          i2c_start <= 1'b0;
          byte_addr <= 16'h08;
          wr_data   <= TIME_INIT[47:40];
        end
        RD_SEC:
        if (cnt_wait == 13'd1) i2c_start <= 1'b1;
        else if (i2c_end == 1'b1) second <= rd_data[6:0];
        else begin
          wr_en     <= 1'b0;
          rd_en     <= 1'b1;
          i2c_start <= 1'b0;
          byte_addr <= 16'h02;
          wr_data   <= 8'd0;
        end
        RD_MIN:
        if (cnt_wait == 13'd1) i2c_start <= 1'b1;
        else if (i2c_end == 1'b1) minute <= rd_data[6:0];
        else begin
          rd_en     <= 1'b1;
          i2c_start <= 1'b0;
          byte_addr <= 16'h03;
        end
        RD_HOUR:
        if (cnt_wait == 13'd1) i2c_start <= 1'b1;
        else if (i2c_end == 1'b1) hour <= rd_data[5:0];
        else begin
          rd_en     <= 1'b1;
          i2c_start <= 1'b0;
          byte_addr <= 16'h04;
        end
        RD_DAY:
        if (cnt_wait == 13'd1) i2c_start <= 1'b1;
        else if (i2c_end == 1'b1) day <= rd_data[5:0];
        else begin
          rd_en     <= 1'b1;
          i2c_start <= 1'b0;
          byte_addr <= 16'h05;
        end
        RD_MON:
        if (cnt_wait == 13'd1) i2c_start <= 1'b1;
        else if (i2c_end == 1'b1) month <= rd_data[4:0];
        else begin
          rd_en     <= 1'b1;
          i2c_start <= 1'b0;
          byte_addr <= 16'h07;
        end
        RD_YEAR:
        if (cnt_wait == 13'd1) i2c_start <= 1'b1;
        else if (i2c_end == 1'b1) year <= rd_data[7:0];
        else begin
          rd_en     <= 1'b1;
          i2c_start <= 1'b0;
          byte_addr <= 16'h08;
        end
        default: begin
          wr_en     <= 1'b0;
          rd_en     <= 1'b0;
          i2c_start <= 1'b0;
          byte_addr <= 16'd0;
          wr_data   <= 8'd0;
          year      <= 8'd0;
          month     <= 8'd0;
          day       <= 8'd0;
          hour      <= 8'd0;
          minute    <= 8'd0;
          second    <= 8'd0;
        end
      endcase
  end
endmodule
