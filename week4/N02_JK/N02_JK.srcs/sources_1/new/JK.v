module JK(clk,J,K,Q);

input J,K,clk;
output reg Q;

always @(posedge clk)
begin
    if(J==0&&K==0) 
    begin Q<=Q;end
    if(J==0&&K==1) 
    begin Q<=1'b0;end       
    if(J==1&&K==0) 
    begin Q<=1'b1;end    
    if(J==1&&K==1)
    begin Q<=~Q;end
end
endmodule
