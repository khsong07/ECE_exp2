`timescale 1us / 1ns

module text_LCD_B_tb();

reg rst,clk;

wire LCD_E,LCD_RS,LCD_RW;
wire[7:0] LCD_DATA;
wire[7:0] LED_out;

text_LCD_B U1 (rst,clk,LCD_E,LCD_RS,LCD_RW,LCD_DATA,LED_out);

initial begin
    clk<=0;
    rst<=0;
    #10 rst<=1;  
    end

always begin
    #0.5 clk<=~clk;
end


endmodule
