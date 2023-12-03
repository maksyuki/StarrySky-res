module sd_write (
    input             clk_ref,
    input             clk_ref_180deg,
    input             rst_n,
    input             sd_miso,
    output reg        sd_cs,
    output reg        sd_mosi,
    input             wr_start_en,
    input      [31:0] wr_sec_addr,
    input      [15:0] wr_data,
    output reg        wr_busy,
    output reg        wr_req
);

  parameter HEAD_BYTE = 8'hfe;

  reg         wr_en_d0;
  reg         wr_en_d1;
  reg         res_en;
  reg  [ 7:0] res_data;
  reg         res_flag;
  reg  [ 5:0] res_bit_cnt;
  reg  [ 3:0] wr_ctrl_cnt;
  reg  [47:0] cmd_wr;
  reg  [ 5:0] cmd_bit_cnt;
  reg  [ 3:0] bit_cnt;
  reg  [ 8:0] data_cnt;
  reg  [15:0] wr_data_t;
  reg         detect_done_flag;
  reg  [ 7:0] detect_data;
  wire        pos_wr_en;


  assign pos_wr_en = (~wr_en_d1) & wr_en_d0;

  always @(posedge clk_ref or negedge rst_n) begin
    if (!rst_n) begin
      wr_en_d0 <= 1'b0;
      wr_en_d1 <= 1'b0;
    end else begin
      wr_en_d0 <= wr_start_en;
      wr_en_d1 <= wr_en_d0;
    end
  end

  always @(posedge clk_ref_180deg or negedge rst_n) begin
    if (!rst_n) begin
      res_en      <= 1'b0;
      res_data    <= 8'd0;
      res_flag    <= 1'b0;
      res_bit_cnt <= 6'd0;
    end else begin
      if (sd_miso == 1'b0 && res_flag == 1'b0) begin
        res_flag    <= 1'b1;
        res_data    <= {res_data[6:0], sd_miso};
        res_bit_cnt <= res_bit_cnt + 6'd1;
        res_en      <= 1'b0;
      end else if (res_flag) begin
        res_data    <= {res_data[6:0], sd_miso};
        res_bit_cnt <= res_bit_cnt + 6'd1;
        if (res_bit_cnt == 6'd7) begin
          res_flag    <= 1'b0;
          res_bit_cnt <= 6'd0;
          res_en      <= 1'b1;
        end
      end else res_en <= 1'b0;
    end
  end

  always @(posedge clk_ref or negedge rst_n) begin
    if (!rst_n) detect_data <= 8'd0;
    else if (detect_done_flag) detect_data <= {detect_data[6:0], sd_miso};
    else detect_data <= 8'd0;
  end

  always @(posedge clk_ref or negedge rst_n) begin
    if (!rst_n) begin
      sd_cs            <= 1'b1;
      sd_mosi          <= 1'b1;
      wr_ctrl_cnt      <= 4'd0;
      wr_busy          <= 1'b0;
      cmd_wr           <= 48'd0;
      cmd_bit_cnt      <= 6'd0;
      bit_cnt          <= 4'd0;
      wr_data_t        <= 16'd0;
      data_cnt         <= 9'd0;
      wr_req           <= 1'b0;
      detect_done_flag <= 1'b0;
    end else begin
      wr_req <= 1'b0;
      case (wr_ctrl_cnt)
        4'd0: begin
          wr_busy <= 1'b0;
          sd_cs   <= 1'b1;
          sd_mosi <= 1'b1;
          if (pos_wr_en) begin
            cmd_wr      <= {8'h58, wr_sec_addr, 8'hff};
            wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;
            wr_busy     <= 1'b1;
          end
        end
        4'd1: begin
          if (cmd_bit_cnt <= 6'd47) begin
            cmd_bit_cnt <= cmd_bit_cnt + 6'd1;
            sd_cs       <= 1'b0;
            sd_mosi     <= cmd_wr[6'd47-cmd_bit_cnt];
          end else begin
            sd_mosi <= 1'b1;
            if (res_en) begin
              wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;
              cmd_bit_cnt <= 6'd0;
              bit_cnt     <= 4'd1;
            end
          end
        end
        4'd2: begin
          bit_cnt <= bit_cnt + 4'd1;

          if (bit_cnt >= 4'd8 && bit_cnt <= 4'd15) begin
            sd_mosi <= HEAD_BYTE[4'd15-bit_cnt];
            if (bit_cnt == 4'd14) wr_req <= 1'b1;
            else if (bit_cnt == 4'd15) wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;
          end
        end
        4'd3: begin
          bit_cnt <= bit_cnt + 4'd1;
          if (bit_cnt == 4'd0) begin
            sd_mosi   <= wr_data[4'd15-bit_cnt];
            wr_data_t <= wr_data;
          end else sd_mosi <= wr_data_t[4'd15-bit_cnt];
          if ((bit_cnt == 4'd14) && (data_cnt <= 9'd255)) wr_req <= 1'b1;
          if (bit_cnt == 4'd15) begin
            data_cnt <= data_cnt + 9'd1;
            if (data_cnt == 9'd255) begin
              data_cnt    <= 9'd0;
              wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;
            end
          end
        end
        4'd4: begin
          bit_cnt <= bit_cnt + 4'd1;
          sd_mosi <= 1'b1;
          if (bit_cnt == 4'd15) wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;
        end
        4'd5: begin
          if (res_en) wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;
        end
        4'd6: begin
          detect_done_flag <= 1'b1;
          if (detect_data == 8'hff) begin
            wr_ctrl_cnt      <= wr_ctrl_cnt + 4'd1;
            detect_done_flag <= 1'b0;
          end
        end
        default: begin
          sd_cs       <= 1'b1;
          wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;
        end
      endcase
    end
  end

endmodule
