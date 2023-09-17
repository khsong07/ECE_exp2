`timescale 1ns / 1ps

module comparator_4bit_tb();

reg [3:0] a,b;
wire x,y,z;
comparator_4bit U1(.a(a),.b(b),.x(x),.y(y),.z(z));

initial begin
a=4'b0011;
b=4'b1000;#200;
a=4'b0111;
b=4'b0001;#200;
a=4'b1001;
b=4'b1001;#200;
a=4'b1011;
b=4'b1111;
end

endmodule
