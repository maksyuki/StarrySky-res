module uart_send (
    input clk,
    input rst_n,

    input            uart_en,
    input      [7:0] uart_din,
    output           uart_tx_busy,
    output           en_flag,
    output reg       tx_flag,
    output reg [7:0] tx_data,
    output reg [3:0] tx_cnt,
    output reg       uart_txd
);


  parameter CLK_FREQ = 50000000;
  parameter UART_BPS = 9600;
  localparam BPS_CNT = CLK_FREQ / UART_BPS;

  reg        uart_en_d0;
  reg        uart_en_d1;
  reg [15:0] clk_cnt;


  assign uart_tx_busy = tx_flag;
  assign en_flag      = (~uart_en_d1) & uart_en_d0;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      uart_en_d0 <= 1'b0;
      uart_en_d1 <= 1'b0;
    end else begin
      uart_en_d0 <= uart_en;
      uart_en_d1 <= uart_en_d0;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      tx_flag <= 1'b0;
      tx_data <= 8'd0;
    end else if (en_flag) begin
      tx_flag <= 1'b1;
      tx_data <= uart_din;
    end else if ((tx_cnt == 4'd9) && (clk_cnt == BPS_CNT - (BPS_CNT / 16))) begin
      tx_flag <= 1'b0;
      tx_data <= 8'd0;
    end else begin
      tx_flag <= tx_flag;
      tx_data <= tx_data;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) clk_cnt <= 16'd0;
    else if (tx_flag) begin
      if (clk_cnt < BPS_CNT - 1) clk_cnt <= clk_cnt + 1'b1;
      else clk_cnt <= 16'd0;
    end else clk_cnt <= 16'd0;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) tx_cnt <= 4'd0;
    else if (tx_flag) begin
      if (clk_cnt == BPS_CNT - 1) tx_cnt <= tx_cnt + 1'b1;
      else tx_cnt <= tx_cnt;
    end else tx_cnt <= 4'd0;
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) uart_txd <= 1'b1;
    else if (tx_flag)
      case (tx_cnt)
        4'd0:    uart_txd <= 1'b0;
        4'd1:    uart_txd <= tx_data[0];
        4'd2:    uart_txd <= tx_data[1];
        4'd3:    uart_txd <= tx_data[2];
        4'd4:    uart_txd <= tx_data[3];
        4'd5:    uart_txd <= tx_data[4];
        4'd6:    uart_txd <= tx_data[5];
        4'd7:    uart_txd <= tx_data[6];
        4'd8:    uart_txd <= tx_data[7];
        4'd9:    uart_txd <= 1'b1;
        default: ;
      endcase
    else uart_txd <= 1'b1;
  end

endmodule
