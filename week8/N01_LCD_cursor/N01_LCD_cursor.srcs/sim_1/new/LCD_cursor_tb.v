`timescale 1us/1ns

module LCD_cursor_tb();

reg rst,clk;
reg [9:0] number_btn;
reg [1:0]control_btn;

wire LCD_E,LCD_RS,LCD_RW;
wire [7:0]LCD_DATA;
wire[7:0]LED_out;

LCD_cursor U1(rst,clk,LCD_E,LCD_RS,LCD_RW,LCD_DATA,LED_out,number_btn,control_btn);

initial begin
    clk<=0;
    rst<=1;
    number_btn<= 10'b0000_0000_00;
    control_btn<= 2'b00;
    #0.5 rst<=0;
    #0.5 rst<=1;
    #1e+5 number_btn<= 10'b0100_0000_00;//2
    #1e+5 number_btn<= 10'b0000_0000_00;
    #1e+5 number_btn<= 10'b0001_0000_00;//4
    #1e+5 number_btn<= 10'b0000_0000_00;
    #1e+5 control_btn<= 2'b10;//left
    #1e+5 control_btn<= 2'b00;
    #1e+5 control_btn<= 2'b01;//right  
    #1e+5 control_btn<= 2'b00;
end

always begin
    #0.5 clk<=~clk;
end


endmodule
