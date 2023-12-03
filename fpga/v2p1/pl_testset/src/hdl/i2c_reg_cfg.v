module i2c_reg_cfg (
    input             clk,
    input             rst_n,
    input             i2c_done,
    output reg        i2c_rh_wl,
    output reg        i2c_exec,
    output reg        cfg_done,
    output reg [15:0] i2c_data
);

  parameter WL = 6'd16;
  localparam REG_NUM = 6'd29;
  localparam PHONE_VOLUME = 6'd20;
  localparam SPEAK_VOLUME = 6'd30;

  reg [ 2:0] wl;
  reg [ 7:0] start_init_cnt;
  reg [ 5:0] init_reg_cnt;
  reg [23:0] cnt_delay;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) wl <= 3'b00;
    else begin
      case (WL)
        6'd16:   wl <= 3'b011;
        6'd18:   wl <= 3'b010;
        6'd20:   wl <= 3'b001;
        6'd24:   wl <= 3'b000;
        6'd32:   wl <= 3'b100;
        default: wl <= 3'b000;
      endcase
    end
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) start_init_cnt <= 8'd0;
    else if (start_init_cnt < 8'hff) start_init_cnt <= start_init_cnt + 1'b1;
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) i2c_exec <= 1'b0;
    else if (cfg_done == 1 && i2c_rh_wl == 0) i2c_exec <= 1'b1;
    else if (init_reg_cnt == 2 && cnt_delay == 800_000) i2c_exec <= 1'b1;
    else if (init_reg_cnt == 5'd0 & start_init_cnt == 8'hfe) i2c_exec <= 1'b1;
    else if (i2c_done && init_reg_cnt < REG_NUM && init_reg_cnt != 2) i2c_exec <= 1'b1;
    else i2c_exec <= 1'b0;
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) init_reg_cnt <= 5'd0;
    else if (cfg_done == 1 && i2c_rh_wl == 0) init_reg_cnt <= 5'd0;
    else if (i2c_exec) init_reg_cnt <= init_reg_cnt + 1'b1;
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cfg_done <= 1'b0;
    else if (i2c_done & (init_reg_cnt == REG_NUM)) cfg_done <= 1'b1;
    else cfg_done <= 1'b0;
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) i2c_rh_wl <= 1'b0;
    else if (cfg_done) i2c_rh_wl <= 1'b1;
    else i2c_rh_wl <= i2c_rh_wl;
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cnt_delay <= 1'b0;
    else if (cfg_done) cnt_delay <= 1'b0;
    else if (init_reg_cnt == 2) cnt_delay <= cnt_delay + 1;
    else cnt_delay <= cnt_delay;
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) i2c_data <= 16'b0;
    else begin
      case (init_reg_cnt)
        6'd0:    i2c_data <= {8'd0, 8'h80};
        6'd1:    i2c_data <= {8'd0, 8'h00};
        6'd2:    i2c_data <= {8'd1, 8'h58};
        6'd3:    i2c_data <= {8'd1, 8'h50};
        6'd4:    i2c_data <= {8'd2, 8'hf3};
        6'd5:    i2c_data <= {8'd2, 8'h00};
        6'd6:    i2c_data <= {8'd3, 8'h09};
        6'd7:    i2c_data <= {8'd0, 8'h06};
        6'd8:    i2c_data <= {8'd4, 8'h3c};
        6'd9:    i2c_data <= {8'd8, 8'h00};
        6'd10:   i2c_data <= {8'd9, 8'h66};
        6'd11:   i2c_data <= {8'd10, 8'h50};
        6'd12:   i2c_data <= {8'd12, 2'b01, 1'b0, wl, 2'b0};
        6'd13:   i2c_data <= {8'd13, 8'h0c};
        6'd14:   i2c_data <= {8'd16, 8'h00};
        6'd15:   i2c_data <= {8'd17, 8'h00};
        6'd16:   i2c_data <= {8'd18, 8'hc0};
        6'd17:   i2c_data <= {8'd23, 2'b0, wl, 3'b0};
        6'd18:   i2c_data <= {8'd24, 8'h0c};
        6'd19:   i2c_data <= {8'd26, 8'h0a};
        6'd20:   i2c_data <= {8'd27, 8'h0a};
        6'd21:   i2c_data <= {8'd29, 8'h1c};
        6'd22:   i2c_data <= {8'd39, 8'hf8};
        6'd23:   i2c_data <= {8'd42, 8'hf8};
        6'd24:   i2c_data <= {8'd43, 8'h80};
        6'd25:   i2c_data <= {8'd46, 2'b0, PHONE_VOLUME};
        6'd26:   i2c_data <= {8'd47, 2'b0, PHONE_VOLUME};
        6'd27:   i2c_data <= {8'd48, 2'b0, SPEAK_VOLUME};
        6'd28:   i2c_data <= {8'd49, 2'b0, SPEAK_VOLUME};
        default: ;
      endcase
    end
  end

endmodule
