module half_adder_case(x,y,s,c);

input x,y;

output c,s;

reg c,s;

always @(*) begin

case({x,y})
2'b00: begin c=0; s=0; end
2'b01: begin c=0; s=1; end
2'b10: begin c=0; s=1; end
2'b11: begin c=1; s=0; end
default: begin c=0;s=0; end
endcase
end

endmodule
