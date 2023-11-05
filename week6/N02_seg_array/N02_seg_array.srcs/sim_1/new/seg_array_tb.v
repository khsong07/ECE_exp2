`timescale 1ns / 1ps

module seg_array_tb();

reg clk,rst;
reg btn;
wire [7:0] seg_data;
wire [7:0] seg_sel;

seg_array U3(clk,rst,btn,seg_data,seg_sel);

always begin
    #2 clk = ~clk;
end

initial begin
    clk = 0;
    rst = 1;
    btn = 0;
    #10 rst = 0;
    #10 rst = 1;
    #20 btn=1;#5 btn=0;//1
    #27 btn=1;#5 btn=0;//2
    #27 btn=1;#5 btn=0;//3
    #27 btn=1;#5 btn=0;//4
    #27 btn=1;#5 btn=0;//5
    #27 btn=1;#5 btn=0;//6
    #27 btn=1;#5 btn=0;//7
    #27 btn=1;#5 btn=0;//8
    #27 btn=1;#5 btn=0;//9
    
    #27 btn=1;#5 btn=0;//10
    #27 btn=1;#5 btn=0;//11
    #27 btn=1;#5 btn=0;//12
    #27 btn=1;#5 btn=0;//13
    #27 btn=1;#5 btn=0;//14
    #27 btn=1;#5 btn=0;//15
    #27 btn=1;#5 btn=0;//0
    #27 btn=1;#5 btn=0;//1     
end

endmodule
