module mux_4to1(I0,I1,I2,I3,S0,S1,Y);

output [1:0]Y;
input [1:0] I0,I1,I2,I3;
input S0,S1;

assign Y=S1?(S0?I3:I2):(S0?I1:I0);

endmodule
