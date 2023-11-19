`timescale 1ns / 1ps
module DAC_C_tb();
reg clk,rst;
reg [5:0] btn;
reg add_sel;
wire dac_csn,dac_ldacn,dac_wrn,dac_a_b;
wire [7:0]dac_d;
wire [7:0]led_out;
wire [7:0] seg_data;
wire[7:0] seg_sel;
wire LCD_E,LCD_RS,LCD_RW;
wire[7:0] LCD_DATA;



DAC_C U3(clk,rst,btn,add_sel,dac_csn,dac_ldacn,dac_wrn,dac_a_b,dac_d,led_out,seg_data,seg_sel,LCD_E,LCD_RS,LCD_RW,LCD_DATA);

initial begin
   clk <= 0;
   rst <= 1;
   add_sel <= 0;
   btn = 9'b000000000;
   #1e+6 rst <= 0;
   #1e+6 rst <= 1;
   #1e+5 btn = 9'b000000001;
   #1e+5 btn = 9'b000000100;
   #1e+5 btn = 9'b000001000;
   #1e+5 btn = 9'b000100000;
   #1e+5 btn = 9'b001000000;
   #1e+5 btn = 9'b100000000;
end
 
always begin
    #0.5 clk = ~clk;
end

endmodule
