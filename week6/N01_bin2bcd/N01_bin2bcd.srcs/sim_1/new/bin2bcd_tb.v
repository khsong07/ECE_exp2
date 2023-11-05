`timescale 1ns / 1ps

    module bin2bcd_tb();

reg clk,rst;
reg[3:0] bin;
wire[7:0] bcd;

bin2bcd U1(clk,rst,bin,bcd);

always begin
    #5 clk = ~clk;
end

initial begin
    clk = 0;
    rst = 1;
    bin<=4'b0000; #10
    bin<=4'b0001; #10
    bin<=4'b0010; #10
    bin<=4'b0011; #10
    bin<=4'b0100; #10
    bin<=4'b0101; #10
    bin<=4'b0110; #10
    bin<=4'b0111; #10
   
    bin<=4'b1000; #10
    bin<=4'b1001; #10
    bin<=4'b1010; #10
    bin<=4'b1011; #10
    bin<=4'b1100; #10
    bin<=4'b1101; #10
    bin<=4'b1110; #10
    bin<=4'b1111;
end 

endmodule
