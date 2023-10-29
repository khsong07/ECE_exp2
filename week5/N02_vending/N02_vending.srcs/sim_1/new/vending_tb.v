`timescale 1ns / 1ps

module vending_tb();

reg clk,rst;
reg A,B,C;
wire [2:0]state;
wire y;

vending U1(clk,rst,A,B,C,state,y);

initial begin
    clk<=0;
    rst<=1;
    A<=0;
    B<=0;
    C<=0;
    #10 rst<=0;
    #10 rst<=1;
    #15 A<=1'b01;#15 A<=1'b00;
    #15 B<=1'b01;#15 B<=1'b00;
    #15 A<=1'b01;#15 A<=1'b00;
    #15 B<=1'b01;#15 B<=1'b00;
    #15 C<=1'b01;#15 C<=1'b00;
    #15 rst<=0;#15 rst<=1;
    #15 A<=1'b01;#15 A<=1'b00;
    #15 B<=1'b01;#15 B<=1'b00;
    #15 C<=1'b01;#15 C<=1'b00;
    
end

always begin
    #5 clk<=~clk;
end

endmodule
