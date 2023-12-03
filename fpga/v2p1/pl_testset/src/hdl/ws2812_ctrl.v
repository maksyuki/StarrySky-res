`timescale 1ns / 1ps

module ws2812_ctrl (
    input  clk,
    input  rst_n,
    output led
);

  //clk 50M
  parameter T0H = 6'd17;
  parameter T0L = 6'd50;
  parameter T1H = 6'd50;
  parameter T1L = 6'd17;
  parameter RST = 14'd15000;

  parameter LED_1 = 25'b0_1111_0000_1111_0000_1111_0000;
  parameter LED_2 = 25'b0_1111_0000_0000_0000_1111_0000;
  parameter LED_3 = 25'b0_0000_0000_1111_0000_1111_0000;
  parameter LED_4 = 25'b0_1111_0000_1111_0000_0000_0000;
  parameter IDLE = 5'b0000;
  parameter LED1 = 5'b0001;
  parameter LED2 = 5'b0010;
  parameter LED3 = 5'b0100;
  parameter LED4 = 5'b1000;
  parameter RST_FSM = 5'b1_0000;

  reg [ 4:0] state;
  reg [ 4:0] state_n;
  reg [ 6:0] cycle_cnt;
  reg        led_pwm;
  reg        shift;
  reg        state_tran;
  reg        state_tran_rst;
  reg [13:0] rst_cnt;
  reg [ 4:0] bit_cnt;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cycle_cnt <= 7'd0;
    else if (cycle_cnt == (T0H + T0L - 6'd1)) cycle_cnt <= 7'd0;
    else if (state != RST_FSM) cycle_cnt <= cycle_cnt + 1'b1;
    else cycle_cnt <= 7'd0;
  end

  //FSM 1
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= IDLE;
    else state <= state_n;
  end

  //FSM 2
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      led_pwm <= 1'b0;
      shift   <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          led_pwm <= 1'b1;
        end
        LED1: begin
          shift <= LED_1[bit_cnt];
          if (shift == 1'b1) begin
            if (cycle_cnt == T1H) led_pwm <= 1'b0;
            else if (cycle_cnt == (T1H + T0H - 6'd1)) led_pwm <= 1'b1;
            else led_pwm <= led_pwm;
          end else begin
            if (cycle_cnt == T0H) led_pwm <= 1'b0;
            else if (cycle_cnt == (T1H + T0H - 6'd1)) led_pwm <= 1'b1;
            else led_pwm <= led_pwm;
          end
        end
        LED2: begin
          shift <= LED_2[bit_cnt];
          if (shift == 1'b1) begin
            if (cycle_cnt == T1H) led_pwm <= 1'b0;
            else if (cycle_cnt == (T1H + T0H - 6'd1)) led_pwm <= 1'b1;
            else led_pwm <= led_pwm;
          end else begin
            if (cycle_cnt == T0H) led_pwm <= 1'b0;
            else if (cycle_cnt == (T1H + T0H - 6'd1)) led_pwm <= 1'b1;
            else led_pwm <= led_pwm;
          end
        end
        LED3: begin
          shift <= LED_3[bit_cnt];
          if (shift == 1'b1) begin
            if (cycle_cnt == T1H) led_pwm <= 1'b0;
            else if (cycle_cnt == (T1H + T0H - 6'd1)) led_pwm <= 1'b1;
            else led_pwm <= led_pwm;
          end else begin
            if (cycle_cnt == T0H) led_pwm <= 1'b0;
            else if (cycle_cnt == (T1H + T0H - 6'd1)) led_pwm <= 1'b1;
            else led_pwm <= led_pwm;
          end
        end
        LED4: begin
          shift <= LED_4[bit_cnt];
          if (shift == 1'b1) begin
            if (cycle_cnt == T1H) led_pwm <= 1'b0;
            else if (cycle_cnt == (T1H + T0H - 6'd1)) led_pwm <= 1'b1;
            else led_pwm <= led_pwm;
          end else begin
            if (cycle_cnt == T0H) led_pwm <= 1'b0;
            else if (cycle_cnt == (T1H + T0H - 6'd1)) led_pwm <= 1'b1;
            else led_pwm <= led_pwm;
          end
        end
        RST_FSM: begin
          led_pwm <= 1'b0;
        end

        default: begin
          led_pwm <= 1'b0;
        end
      endcase
    end
  end

  assign led = led_pwm;
  //FSM 3
  always @(*) begin
    case (state)
      IDLE:    state_n = LED1;
      LED1: begin
        if (state_tran) state_n = LED2;
        else state_n = state;
      end
      LED2: begin
        if (state_tran) state_n = LED3;
        else state_n = state;
      end
      LED3: begin
        if (state_tran) state_n = LED4;
        else state_n = state;
      end
      LED4: begin
        if (state_tran) state_n = RST_FSM;
        else state_n = state;
      end
      RST_FSM: begin
        if (state_tran_rst) state_n = IDLE;
        else state_n = state;
      end
      default: state_n = RST_FSM;
    endcase
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bit_cnt    <= 5'd0;
      state_tran <= 1'b0;
    end else if (bit_cnt == 5'd24) begin
      bit_cnt    <= 5'd0;
      state_tran <= 1'b1;
    end else if (cycle_cnt == (T0H + T0L - 6'd1)) begin
      bit_cnt    <= bit_cnt + 1'b1;
      state_tran <= 1'b0;
    end else begin
      bit_cnt    <= bit_cnt;
      state_tran <= 1'b0;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) rst_cnt <= 14'd0;
    else if (state == RST_FSM) rst_cnt <= rst_cnt + 1'b1;
    else rst_cnt <= 14'd0;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state_tran_rst <= 1'b0;
    else if (rst_cnt == RST) state_tran_rst <= 1'b1;
    else state_tran_rst <= 1'b0;
  end
endmodule
