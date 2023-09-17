module decoder_3X8(in,out);

input [2:0] in;
output reg [7:0] out;

always @(in) begin
    out = 8'b0;
    out[in] = 1'b1;
end
endmodule
