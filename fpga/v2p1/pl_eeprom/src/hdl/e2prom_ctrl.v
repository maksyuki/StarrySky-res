module e2prom_ctrl (
                              input             clk,
                              input             rst_n,
    (* MARK_DEBUG = "TRUE" *) output reg        i2c_rh_wl,
    (* MARK_DEBUG = "TRUE" *) output reg        i2c_exec,
    (* MARK_DEBUG = "TRUE" *) output reg [15:0] i2c_addr,
    (* MARK_DEBUG = "TRUE" *) output reg [ 7:0] i2c_data_w,
    (* MARK_DEBUG = "TRUE" *) input      [ 7:0] i2c_data_r,
    (* MARK_DEBUG = "TRUE" *) input             i2c_done,
    (* MARK_DEBUG = "TRUE" *) input             i2c_ack,
    (* MARK_DEBUG = "TRUE" *) output reg        rw_done,
    (* MARK_DEBUG = "TRUE" *) output reg        rw_res
);

  parameter WR_WAIT_TIME = 14'd12000;  // 12ms
  parameter MAX_BYTE = 16'd256;

  (* MARK_DEBUG = "TRUE" *)reg [ 1:0] flow_cnt;
  reg [13:0] wait_cnt;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      flow_cnt   <= 2'b0;
      i2c_rh_wl  <= 1'b0;
      i2c_exec   <= 1'b0;
      i2c_addr   <= 16'b0;
      i2c_data_w <= 8'b0;
      wait_cnt   <= 14'b0;
      rw_done    <= 1'b0;
      rw_res     <= 1'b0;
    end else begin
      i2c_exec <= 1'b0;
      //   rw_done  <= 1'b0;
      case (flow_cnt)
        2'd0: begin
          wait_cnt <= wait_cnt + 1'b1;
          if (wait_cnt == WR_WAIT_TIME - 1'b1) begin
            wait_cnt <= 1'b0;
            if (i2c_addr == MAX_BYTE) begin
              i2c_addr  <= 1'b0;
              i2c_rh_wl <= 1'b1;
              flow_cnt  <= 2'd2;
            end else begin
              i2c_exec <= 1'b1;
              flow_cnt <= 2'd1;
            end
          end
        end
        2'd1: begin
          if (i2c_done == 1'b1) begin
            flow_cnt   <= 2'd0;
            i2c_addr   <= i2c_addr + 1'b1;
            i2c_data_w <= i2c_data_w + 1'b1;
          end
        end
        2'd2: begin
          i2c_exec <= 1'b1;
          flow_cnt <= 2'd3;
        end
        2'd3: begin
          if (i2c_done == 1'b1) begin
            if ((i2c_addr[7:0] != i2c_data_r) || (i2c_ack == 1'b1)) begin
              rw_done <= 1'b1;
              rw_res  <= 1'b0;
            end else if (i2c_addr == MAX_BYTE - 1'b1) begin
              rw_done <= 1'b1;
              rw_res  <= 1'b1;
            end else begin
              flow_cnt <= 2'd2;
              i2c_addr <= i2c_addr + 1'b1;
            end
          end
        end
        default: ;
      endcase
    end
  end

endmodule
