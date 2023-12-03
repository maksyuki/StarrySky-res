module uart_top #(
    parameter CLK_FREQ = 50000000,
    parameter UART_BPS = 115200
) (
    input clk,
    input rst_n,

    input  uart_rxd,
    output uart_txd
);

  wire       uart_recv_done;
  wire [7:0] uart_recv_data;
  wire       uart_send_en;
  wire [7:0] uart_send_data;
  wire       uart_tx_busy;

  uart_recv #(
      .CLK_FREQ(CLK_FREQ),
      .UART_BPS(UART_BPS)
  ) u_uart_recv (
      .clk      (clk),
      .rst_n    (rst_n),
      .uart_rxd (uart_rxd),
      .uart_done(uart_recv_done),
      .uart_data(uart_recv_data)
  );

  uart_send #(
      .CLK_FREQ(CLK_FREQ),
      .UART_BPS(UART_BPS)
  ) u_uart_send (
      .clk  (clk),
      .rst_n(rst_n),

      .uart_en     (uart_send_en),
      .uart_din    (uart_send_data),
      .uart_tx_busy(uart_tx_busy),
      .uart_txd    (uart_txd)
  );

  uart_loop u_uart_loop (
      .clk  (clk),
      .rst_n(rst_n),

      .recv_done(uart_recv_done),
      .recv_data(uart_recv_data),

      .tx_busy  (uart_tx_busy),
      .send_en  (uart_send_en),
      .send_data(uart_send_data)
  );

endmodule
