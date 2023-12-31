module sd_init (
    input      clk_ref,
    input      rst_n,
    input      sd_miso,
    output     sd_clk,
    output reg sd_cs,
    output reg sd_mosi,
    output reg sd_init_done
);

  parameter CMD0 = {8'h40, 8'h00, 8'h00, 8'h00, 8'h00, 8'h95};
  parameter CMD8 = {8'h48, 8'h00, 8'h00, 8'h01, 8'haa, 8'h87};
  parameter CMD55 = {8'h77, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff};
  parameter ACMD41 = {8'h69, 8'h40, 8'h00, 8'h00, 8'h00, 8'hff};
  parameter DIV_FREQ = 200;
  parameter POWER_ON_NUM = 5000;
  parameter OVER_TIME_NUM = 25000;

  parameter st_idle = 7'b000_0001;
  parameter st_send_cmd0 = 7'b000_0010;
  parameter st_wait_cmd0 = 7'b000_0100;
  parameter st_send_cmd8 = 7'b000_1000;
  parameter st_send_cmd55 = 7'b001_0000;
  parameter st_send_acmd41 = 7'b010_0000;
  parameter st_init_done = 7'b100_0000;

  reg  [ 6:0] cur_state;
  reg  [ 6:0] next_state;
  reg  [ 7:0] div_cnt;
  reg         div_clk;
  reg  [12:0] poweron_cnt;
  reg         res_en;
  reg  [47:0] res_data;
  reg         res_flag;
  reg  [ 5:0] res_bit_cnt;
  reg  [ 5:0] cmd_bit_cnt;
  reg  [15:0] over_time_cnt;
  reg         over_time_en;
  wire        div_clk_180deg;

  assign sd_clk         = ~div_clk;
  assign div_clk_180deg = ~div_clk;

  always @(posedge clk_ref or negedge rst_n) begin
    if (!rst_n) begin
      div_clk <= 1'b0;
      div_cnt <= 8'd0;
    end else begin
      if (div_cnt == DIV_FREQ / 2 - 1'b1) begin
        div_clk <= ~div_clk;
        div_cnt <= 8'd0;
      end else div_cnt <= div_cnt + 1'b1;
    end
  end

  always @(posedge div_clk or negedge rst_n) begin
    if (!rst_n) poweron_cnt <= 13'd0;
    else if (cur_state == st_idle) begin
      if (poweron_cnt < POWER_ON_NUM) poweron_cnt <= poweron_cnt + 1'b1;
    end else poweron_cnt <= 13'd0;
  end

  always @(posedge div_clk_180deg or negedge rst_n) begin
    if (!rst_n) begin
      res_en      <= 1'b0;
      res_data    <= 48'd0;
      res_flag    <= 1'b0;
      res_bit_cnt <= 6'd0;
    end else begin
      if (sd_miso == 1'b0 && res_flag == 1'b0) begin
        res_flag    <= 1'b1;
        res_data    <= {res_data[46:0], sd_miso};
        res_bit_cnt <= res_bit_cnt + 6'd1;
        res_en      <= 1'b0;
      end else if (res_flag) begin
        res_data    <= {res_data[46:0], sd_miso};
        res_bit_cnt <= res_bit_cnt + 6'd1;
        if (res_bit_cnt == 6'd47) begin
          res_flag    <= 1'b0;
          res_bit_cnt <= 6'd0;
          res_en      <= 1'b1;
        end
      end else res_en <= 1'b0;
    end
  end

  always @(posedge div_clk or negedge rst_n) begin
    if (!rst_n) cur_state <= st_idle;
    else cur_state <= next_state;
  end

  always @(*) begin
    next_state = st_idle;
    case (cur_state)
      st_idle: begin
        if (poweron_cnt == POWER_ON_NUM) next_state = st_send_cmd0;
        else next_state = st_idle;
      end
      st_send_cmd0: begin
        if (cmd_bit_cnt == 6'd47) next_state = st_wait_cmd0;
        else next_state = st_send_cmd0;
      end
      st_wait_cmd0: begin
        if (res_en) begin
          if (res_data[47:40] == 8'h01) next_state = st_send_cmd8;
          else next_state = st_idle;
        end else if (over_time_en) next_state = st_idle;
        else next_state = st_wait_cmd0;
      end

      st_send_cmd8: begin
        if (res_en) begin
          if (res_data[19:16] == 4'b0001) next_state = st_send_cmd55;
          else next_state = st_idle;
        end else next_state = st_send_cmd8;
      end
      st_send_cmd55: begin
        if (res_en) begin
          if (res_data[47:40] == 8'h01) next_state = st_send_acmd41;
          else next_state = st_send_cmd55;
        end else next_state = st_send_cmd55;
      end
      st_send_acmd41: begin
        if (res_en) begin
          if (res_data[47:40] == 8'h00) next_state = st_init_done;
          else next_state = st_send_cmd55;
        end else next_state = st_send_acmd41;
      end
      st_init_done: next_state = st_init_done;
      default:      next_state = st_idle;
    endcase
  end

  always @(posedge div_clk or negedge rst_n) begin
    if (!rst_n) begin
      sd_cs         <= 1'b1;
      sd_mosi       <= 1'b1;
      sd_init_done  <= 1'b0;
      cmd_bit_cnt   <= 6'd0;
      over_time_cnt <= 16'd0;
      over_time_en  <= 1'b0;
    end else begin
      over_time_en <= 1'b0;
      case (cur_state)
        st_idle: begin
          sd_cs   <= 1'b1;
          sd_mosi <= 1'b1;
        end
        st_send_cmd0: begin
          cmd_bit_cnt <= cmd_bit_cnt + 6'd1;
          sd_cs       <= 1'b0;
          sd_mosi     <= CMD0[6'd47-cmd_bit_cnt];
          if (cmd_bit_cnt == 6'd47) cmd_bit_cnt <= 6'd0;
        end
        st_wait_cmd0: begin
          sd_mosi <= 1'b1;
          if (res_en) sd_cs <= 1'b1;
          over_time_cnt <= over_time_cnt + 1'b1;
          if (over_time_cnt == OVER_TIME_NUM - 1'b1) over_time_en <= 1'b1;
          if (over_time_en) over_time_cnt <= 16'd0;
        end
        st_send_cmd8: begin
          if (cmd_bit_cnt <= 6'd47) begin
            cmd_bit_cnt <= cmd_bit_cnt + 6'd1;
            sd_cs       <= 1'b0;
            sd_mosi     <= CMD8[6'd47-cmd_bit_cnt];
          end else begin
            sd_mosi <= 1'b1;
            if (res_en) begin
              sd_cs       <= 1'b1;
              cmd_bit_cnt <= 6'd0;
            end
          end
        end
        st_send_cmd55: begin
          if (cmd_bit_cnt <= 6'd47) begin
            cmd_bit_cnt <= cmd_bit_cnt + 6'd1;
            sd_cs       <= 1'b0;
            sd_mosi     <= CMD55[6'd47-cmd_bit_cnt];
          end else begin
            sd_mosi <= 1'b1;
            if (res_en) begin
              sd_cs       <= 1'b1;
              cmd_bit_cnt <= 6'd0;
            end
          end
        end
        st_send_acmd41: begin
          if (cmd_bit_cnt <= 6'd47) begin
            cmd_bit_cnt <= cmd_bit_cnt + 6'd1;
            sd_cs       <= 1'b0;
            sd_mosi     <= ACMD41[6'd47-cmd_bit_cnt];
          end else begin
            sd_mosi <= 1'b1;
            if (res_en) begin
              sd_cs       <= 1'b1;
              cmd_bit_cnt <= 6'd0;
            end
          end
        end
        st_init_done: begin
          sd_init_done <= 1'b1;
          sd_cs        <= 1'b1;
          sd_mosi      <= 1'b1;
        end
        default: begin
          sd_cs   <= 1'b1;
          sd_mosi <= 1'b1;
        end
      endcase
    end
  end

endmodule
