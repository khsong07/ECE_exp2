`timescale 1ns / 1ps

module state_machine_tb();

reg clk,rst,x;
wire [1:0] state;
wire y;

state_machine U1(clk,rst,x,y,state);

 initial begin
    clk<=0;
    rst<=1;
    #10 rst<=0;
    #10 rst<=1;
    x=1'b01;//1번
    
    #10 x=1'b00;//2번
    
    #10 x=1'b01;
    #10 x=1'b01;//3번

    #10 x=1'b01;
    #10 x=1'b00;//4번 
    
    #10 x=1'b01;
    #10 x=1'b01;
    #10 x=1'b01;
    #10 x=1'b01;//5번 
    
    #10 x=1'b00;
    #10 x=1'b01;
    #10 x=1'b01;
    #10 x=1'b00;//6번    
end

always begin
    #5 clk<=~clk;
end

endmodule
