module mux_2to1(I0,I1,S,Y);

output [3:0]Y;
input [3:0]I0,I1;
input S;

assign Y=(S?I1:I0);

endmodule
