module half_adder(x,y,s,c);

input x,y;

output s,c;

assign c=x&y;

assign s=x^y;

endmodule
