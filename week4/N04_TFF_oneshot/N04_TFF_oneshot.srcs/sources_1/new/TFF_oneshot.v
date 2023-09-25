module TFF_oneshot(clk, rst, T, Q);

input T, clk, rst;
reg T_reg, T_trig;
output reg Q;

always @(negedge rst or posedge clk) begin
    if(!rst) begin
        Q <= 1'b0;
        T_reg <= 1'b0;
        T_trig <= 1'b0;
    end
    else begin
        T_trig <= T & ~T_reg;
        T_reg <= T;
        if(T_trig)
            Q <= ~Q;
    end
end

endmodule