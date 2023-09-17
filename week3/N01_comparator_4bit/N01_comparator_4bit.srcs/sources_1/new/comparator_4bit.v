module comparator_4bit(a,b,x,y,z);

input [3:0] a,b;
output x,y,z;
wire x,y,z;

//x: A>B case
assign x=(a>b)?1'b1:1'b0;

//y: A=B case
assign y=(a==b)?1'b1:1'b0;

//z: A<B case
assign z=(a<b)?1'b1:1'b0;

endmodule
