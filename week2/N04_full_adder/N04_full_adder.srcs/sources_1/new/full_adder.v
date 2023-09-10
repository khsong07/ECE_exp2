module full_adder(x,y,z,s,c);

input x,y,z;
output s,c;

wire s1,c1,c2;

half_adder U1(x,y,s1,c1);
half_adder U2(z,s1,s,c2);

assign c=c1|c2;

endmodule
