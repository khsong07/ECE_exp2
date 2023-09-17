`timescale 1ns / 1ps

module priority_encoder_4to2_tb();

reg a,b,c,d;
wire x,y;

priority_encoder_4to2 U1(.a(a),.b(b),.c(c),.d(d),.x(x),.y(y));
initial begin
a=0;b=0;c=0;d=0;#100;
a=1;b=0;c=0;d=0;#100;
a=1;b=0;c=1;d=1;#100;
a=0;b=1;c=0;d=1;#100;
a=0;b=0;c=0;d=1;
end
endmodule
