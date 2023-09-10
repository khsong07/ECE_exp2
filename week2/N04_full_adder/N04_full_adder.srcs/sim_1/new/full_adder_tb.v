`timescale 1ns / 1ps

module full_adder_tb();

reg x,y,z;
wire s,c;

full_adder U3(.x(x),.y(y),.z(z),.s(s),.c(c));

initial begin
x=0;y=0;z=0; #10;
x=0;y=0;z=1; #10;
x=0;y=1;z=0; #10;
x=0;y=1;z=1; #10;
x=1;y=0;z=0; #10;
x=1;y=0;z=1; #10;
x=1;y=1;z=0; #10;
x=1;y=1;z=1;
end

endmodule
