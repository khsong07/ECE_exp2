module updowncounter(clk,rst,x,state);

input clk,rst;
input x;
reg x_reg,x_trig,count;
output reg[2:0] state;

always @(negedge rst or posedge clk)begin
    if(!rst)begin  
        {x_reg,x_trig}<=2'b00;
    end
    else begin
        x_reg<=x;
        x_trig<=x&~x_reg;
    end
end 

always @(negedge rst or posedge clk)begin
    if(!rst)
    begin state<=3'b000;count<=1; end
    else if(count==1)begin //upcount_when count==1
        case(state)
            3'b000:{state,count}<=x_trig?4'b0011:4'b0001;
            3'b001:state<=x_trig?3'b010:3'b001;
            3'b010:state<=x_trig?3'b011:3'b010;
            3'b011:state<=x_trig?3'b100:3'b011;
            3'b100:state<=x_trig?3'b101:3'b100;
            3'b101:state<=x_trig?3'b110:3'b101;
            3'b110:state<=x_trig?3'b111:3'b110;
            3'b111:{state,count}<=x_trig?4'b1100:4'b1111;
        endcase
    end
    else begin //downcount_when count==0
        case(state)
            3'b000:{state,count}<=x_trig?4'b0011:4'b0000;
            3'b001:state<=x_trig?3'b000:3'b001;
            3'b010:state<=x_trig?3'b001:3'b010;
            3'b011:state<=x_trig?3'b010:3'b011;
            3'b100:state<=x_trig?3'b011:3'b100;
            3'b101:state<=x_trig?3'b100:3'b101;
            3'b110:state<=x_trig?3'b101:3'b110;
            3'b111:{state,count}<=x_trig?4'b1100:4'b1110;
        endcase
    end

end    
    
    
endmodule

