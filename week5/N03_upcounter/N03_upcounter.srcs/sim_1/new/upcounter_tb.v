`timescale 1ns / 1ps

module upcounter_tb();

reg clk,rst;
reg x;
wire [1:0] state;

upcounter U1(clk,rst,x,state);



always begin
    #5 clk = ~clk;
end

initial begin
    clk = 0;
    rst = 1;
    x = 0;
    #10 rst = 0;
    #10 rst = 1;
    #10 x = 1;#10 x = 0;
    #10 x = 1;#10 x = 0;
    #10 x = 1;#10 x = 0;
    #10 x = 1;#10 x = 0;
    #10 x = 1;#10 x = 0;
    
end

endmodule
