module priority_encoder_4to2(a,b,c,d,x,y);

input a,b,c,d;
output x,y;
wire x,y;

assign x=c|d;
assign y=(~c&b)|d;

endmodule
