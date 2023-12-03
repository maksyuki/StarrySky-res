module uart_loop (
    input            clk,
    input            rst_n,
    input            recv_done,
    input      [7:0] recv_data,
    input            tx_busy,
    output reg       send_en,
    output reg [7:0] send_data
);

  reg  recv_done_d0;
  reg  recv_done_d1;
  reg  tx_ready;

  wire recv_done_flag;

  assign recv_done_flag = (~recv_done_d1) & recv_done_d0;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      recv_done_d0 <= 1'b0;
      recv_done_d1 <= 1'b0;
    end else begin
      recv_done_d0 <= recv_done;
      recv_done_d1 <= recv_done_d0;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      tx_ready  <= 1'b0;
      send_en   <= 1'b0;
      send_data <= 8'd0;
    end else begin
      if (recv_done_flag) begin
        tx_ready  <= 1'b1;
        send_en   <= 1'b0;
        send_data <= recv_data;
      end else if (tx_ready && (~tx_busy)) begin
        tx_ready <= 1'b0;
        send_en  <= 1'b1;
      end
    end
  end

endmodule
