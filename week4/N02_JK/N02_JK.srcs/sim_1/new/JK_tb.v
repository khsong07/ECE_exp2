`timescale 1ns / 1ps

module JK_tb();

reg clk,J,K;
wire Q;

JK U1(clk,J,K,Q);

initial begin
    clk<=0;
    #20 J<=0;K<=0;
    #20 J<=0;K<=1;
    #20 J<=0;K<=0;
    #20 J<=1;K<=0;
    #20 J<=0;K<=0;
    #20 J<=1;K<=1;
    #20 J<=0;K<=0;
end

always begin
    #5 clk<=~clk;
end
endmodule
