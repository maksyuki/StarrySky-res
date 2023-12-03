`timescale 1ns / 1ps

module ps2_ctrl (
    input            clk,
    input            rst_n,
    input            ps2_clk,
    input            ps2_data,
    output reg [7:0] data
);

  reg  [1:0] edge_det;
  reg  [9:0] rd_buf;
  reg  [3:0] cnt_rd;
  wire       h2l_edge;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) edge_det <= 2'b11;
    else edge_det <= {edge_det[0], ps2_clk};
  end

  assign h2l_edge = edge_det[1] & (~edge_det[0]);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd_buf <= 8'd0;
      cnt_rd <= 4'd0;
      data   <= 8'd0;
    end else begin
      if (h2l_edge) begin
        if (cnt_rd == 4'd10) begin
          if (rd_buf[0] == 0 && ps2_data && (^rd_buf[9:1])) begin
            data   <= rd_buf[8:1];
            cnt_rd <= 4'd0;
          end
        end else begin
          rd_buf[cnt_rd] <= ps2_data;
          cnt_rd         <= cnt_rd + 1'd1;
        end
      end
    end
  end
endmodule
