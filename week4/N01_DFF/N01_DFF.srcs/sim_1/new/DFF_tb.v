`timescale 1ns / 1ps
module DFF_tb();

reg clk,D;
wire Q;

DFF U1(clk,D,Q);

initial begin
    clk<=0;
    #30 D<=0;
    #30 D<=1;
    #30 D<=0;
    #30 D<=1;
    #30 D<=0;
    #30 D<=1;
    #30 D<=0;
end

always begin
    #5 clk<=~clk;
end

endmodule
