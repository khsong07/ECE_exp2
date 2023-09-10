`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 01:23:59
// Design Name: 
// Module Name: logic_gate_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module logic_gate_tb(a,b,x1,x2,x3,x4,x5);

reg a,b; 

wire x1,x2,x3,x4,x5;

logic_gate U1(.a(a),.b(b),.x1(x1),.x2(x2),.x3(x3),.x4(x4),.x5(x5));

initial begin
a=0;b=0;#10
a=0;b=1;#10
a=1;b=0;#10
a=1;b=1;
end
endmodule
