`timescale 1ns / 1ps

module mux_8to1_tb();
wire [3:0]Y;
reg [3:0]I0,I1,I2,I3,I4,I5,I6,I7;
reg S0,S1,S2;
mux_8to1 U4(.I0(I0),.I1(I1),.I2(I2),.I3(I3),.I4(I4),.I5(I5),.I6(I6),.I7(I7),.S0(S0),.S1(S1),.S2(S2),.Y(Y));

initial begin
I0=4'b0000;
I1=4'b0001;
I2=4'b0010;
I3=4'b0011;
I4=4'b0100;
I5=4'b0101;
I6=4'b0110;
I7=4'b0111;

S2=0;S1=0;S0=0;#100;
S2=0;S1=0;S0=1;#100;
S2=0;S1=1;S0=0;#100;
S2=0;S1=1;S0=1;#100;
S2=1;S1=0;S0=0;#100;
S2=1;S1=0;S0=1;#100;
S2=1;S1=1;S0=0;#100;
S2=1;S1=1;S0=1;
end

endmodule
