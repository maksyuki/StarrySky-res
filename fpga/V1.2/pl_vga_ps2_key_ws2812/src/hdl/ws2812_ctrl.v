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
      IDLE: state_n = LED1;
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
      bit_cnt <= 5'd0;
      state_tran <= 1'b0;
    end else if (bit_cnt == 5'd24) begin
      bit_cnt <= 5'd0;
      state_tran <= 1'b1;
    end else if (cycle_cnt == (T0H + T0L - 6'd1)) begin
      bit_cnt <= bit_cnt + 1'b1;
      state_tran <= 1'b0;
    end else begin
      bit_cnt <= bit_cnt;
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

// module ws2812_ctrl (
//     input  wire clk,
//     input  wire rst_n,
//     output wire led
// );

//   parameter LED_NUM = 4;
//   parameter FREQ = 50_000_0;  //100ms加一次 也就是频率10HZ


//   // 50MHz => 20ns
//   // 50 => 1us  17 => 340ns
//   parameter T0H = 6'd17;
//   parameter T0L = 6'd50;
//   parameter T1H = 6'd50;
//   parameter T1L = 6'd17;
//   parameter RST_NUM = 14'd15000;
//   parameter IDLE = 2'd0;
//   parameter LED_start = 2'd1;
//   parameter RST_FSM = 2'd2;

//   reg [ 1:0] state;
//   reg [ 1:0] state_n;
//   reg [23:0] led_num;
//   reg [24:0] led_brink;
//   reg [31:0] led_brink_cnt;
//   reg [ 6:0] cycle_cnt;
//   reg        led_pwm;
//   reg        shift;
//   reg        state_tran;
//   reg        state_tran_rst;
//   reg [13:0] rst_cnt;
//   reg [ 4:0] bit_cnt;

//   assign led = led_pwm;
//   always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) cycle_cnt <= 7'd0;
//     else if (cycle_cnt == (T0H + T0L - 6'd1)) cycle_cnt <= 7'd0;
//     else if (state != RST_FSM) cycle_cnt <= cycle_cnt + 1'b1;
//     else cycle_cnt <= 7'd0;
//   end

//   //FSM 1
//   always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) state <= IDLE;
//     else state <= state_n;
//   end

//   always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) led_brink_cnt <= 24'd0;
//     else if (led_brink_cnt == FREQ - 1) led_brink_cnt <= 24'd0;
//     else led_brink_cnt <= led_brink_cnt + 1'b1;
//   end

//   always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) led_brink <= 25'd0;
//     else if (led_brink_cnt == FREQ - 1) led_brink <= led_brink + 1'b1;
//   end

//   //FSM 2
//   always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//       led_pwm <= 1'd0;
//       shift   <= 1'd0;
//       led_num <= 1'd0;
//     end else begin
//       case (state)
//         IDLE: begin
//           led_pwm <= 1'b1;
//         end
//         LED_start: begin
//           shift <= led_brink[bit_cnt];
//           if (shift == 1'b1) begin
//             if (led_num == LED_NUM - 1) led_num <= 6'd0;
//             else if (cycle_cnt == T1H) led_pwm <= 1'b0;
//             else if (cycle_cnt == (T1H + T0H - 6'd1)) begin
//               led_pwm <= 1'b1;
//               led_num <= led_num + 1'b1;
//             end else led_pwm <= led_pwm;
//           end else begin
//             if (led_num == LED_NUM - 1) led_num <= 6'd0;
//             else if (cycle_cnt == T0H) led_pwm <= 1'b0;
//             else if (cycle_cnt == (T1H + T0H - 6'd1)) begin
//               led_pwm <= 1'b1;
//               led_num <= led_num + 1'b1;
//             end else led_pwm <= led_pwm;
//           end
//         end
//         RST_FSM: begin
//           led_pwm <= 1'b0;
//         end
//         default: begin
//           led_pwm <= 1'b0;
//         end
//       endcase
//     end
//   end

//   //FSM 3
//   always @(*) begin
//     case (state)
//       IDLE: state_n = LED_start;
//       LED_start: begin
//         if (state_tran) state_n = RST_FSM;
//         else state_n = state;
//       end
//       RST_FSM: begin
//         if (state_tran_rst) state_n = IDLE;
//         else state_n = state;
//       end
//       default: begin
//         state_n = state;
//       end
//     endcase
//   end

//   always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//       bit_cnt <= 5'd0;
//       state_tran <= 1'b0;
//     end else if (bit_cnt == 5'd23) begin
//       bit_cnt <= 5'd0;
//       if (led_num == LED_NUM - 1) begin
//         state_tran <= 1'b1;
//       end
//     end else if (cycle_cnt == (T0H + T0L - 6'd1)) begin
//       bit_cnt <= bit_cnt + 1'b1;
//       state_tran <= 1'b0;
//     end else begin
//       bit_cnt <= bit_cnt;
//       state_tran <= 1'b0;
//     end
//   end

//   always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) rst_cnt <= 14'd0;
//     else if (state == RST_FSM) rst_cnt <= rst_cnt + 1'b1;
//     else rst_cnt <= 14'd0;
//   end

//   always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) state_tran_rst <= 1'b0;
//     else if (rst_cnt == RST_NUM) state_tran_rst <= 1'b1;
//     else state_tran_rst <= 1'b0;
//   end
// endmodule
