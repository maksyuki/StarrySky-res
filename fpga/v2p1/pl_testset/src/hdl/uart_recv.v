module uart_recv (
    input clk,
    input rst_n,

    input            uart_rxd,
    output reg       uart_done,
    output reg       rx_flag,
    output reg [3:0] rx_cnt,
    output reg [7:0] rxdata,
    output reg [7:0] uart_data
);


  parameter CLK_FREQ = 50000000;
  parameter UART_BPS = 9600;
  localparam BPS_CNT = CLK_FREQ / UART_BPS;


  reg         uart_rxd_d0;
  reg         uart_rxd_d1;
  reg  [15:0] clk_cnt;

  wire        start_flag;
  assign start_flag = uart_rxd_d1 & (~uart_rxd_d0);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      uart_rxd_d0 <= 1'b0;
      uart_rxd_d1 <= 1'b0;
    end else begin
      uart_rxd_d0 <= uart_rxd;
      uart_rxd_d1 <= uart_rxd_d0;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) rx_flag <= 1'b0;
    else begin
      if (start_flag) rx_flag <= 1'b1;

      else if ((rx_cnt == 4'd9) && (clk_cnt == BPS_CNT / 2)) rx_flag <= 1'b0;
      else rx_flag <= rx_flag;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) clk_cnt <= 16'd0;
    else if (rx_flag) begin
      if (clk_cnt < BPS_CNT - 1) clk_cnt <= clk_cnt + 1'b1;
      else clk_cnt <= 16'd0;
    end else clk_cnt <= 16'd0;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) rx_cnt <= 4'd0;
    else if (rx_flag) begin
      if (clk_cnt == BPS_CNT - 1) rx_cnt <= rx_cnt + 1'b1;
      else rx_cnt <= rx_cnt;
    end else rx_cnt <= 4'd0;
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) rxdata <= 8'd0;
    else if (rx_flag)
      if (clk_cnt == BPS_CNT / 2) begin
        case (rx_cnt)
          4'd1:    rxdata[0] <= uart_rxd_d1;
          4'd2:    rxdata[1] <= uart_rxd_d1;
          4'd3:    rxdata[2] <= uart_rxd_d1;
          4'd4:    rxdata[3] <= uart_rxd_d1;
          4'd5:    rxdata[4] <= uart_rxd_d1;
          4'd6:    rxdata[5] <= uart_rxd_d1;
          4'd7:    rxdata[6] <= uart_rxd_d1;
          4'd8:    rxdata[7] <= uart_rxd_d1;
          default: ;
        endcase
      end else rxdata <= rxdata;
    else rxdata <= 8'd0;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      uart_data <= 8'd0;
      uart_done <= 1'b0;
    end else if (rx_cnt == 4'd9) begin
      uart_data <= rxdata;
      uart_done <= 1'b1;
    end else begin
      uart_data <= 8'd0;
      uart_done <= 1'b0;
    end
  end

endmodule
