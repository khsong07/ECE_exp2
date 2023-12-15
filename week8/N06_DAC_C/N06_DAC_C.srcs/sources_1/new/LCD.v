module LCD(rst, clk, LCD_E, LCD_RS, LCD_RW, LCD_DATA, dac_d);

input rst, clk;
input[7:0] dac_d;
wire[11:0] bcd;

output LCD_E, LCD_RS, LCD_RW;
output reg[7:0] LCD_DATA;

bin2bcd b2(clk, rst, dac_d, bcd);

wire LCD_E;
reg LCD_RS, LCD_RW;

reg[7:0] cnt;

reg[2:0] state;
parameter DELAY        = 3'b000,
          FUNCTION_SET = 3'b001,
          DISP_ONOFF   = 3'b010,
          ENTRY_MODE   = 3'b011,
          SET_ADDRESS  = 3'b100,
          WRITE        = 3'b101,
          DELAY_T      = 3'b110,
          CLEAR_DISP   = 3'b111;

always @(posedge clk or negedge rst) begin
    if(!rst) 
        state = DELAY;
    else begin
        case(state)
            DELAY : 
                if(cnt == 70) state <= FUNCTION_SET;             
            FUNCTION_SET :
                if(cnt == 30) state <= DISP_ONOFF;
            DISP_ONOFF :
                if(cnt == 30) state <= ENTRY_MODE;
            ENTRY_MODE :
                if(cnt == 30) state <= SET_ADDRESS;
            SET_ADDRESS :
                if(cnt == 100) state <= WRITE;
            WRITE : 
                if(cnt == 30) state <= DELAY_T;
            DELAY_T : 
                if(cnt == 5) state <= CLEAR_DISP;
            CLEAR_DISP :
                if(cnt == 5) state <= WRITE;
        endcase
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst) 
        cnt <= 8'b0000_0000;
    else begin
        case(state)
            DELAY : 
                if(cnt >= 70) cnt <= 0;
                else cnt <= cnt + 1;
            FUNCTION_SET : 
               if(cnt >= 30) cnt <= 0;
                else cnt <= cnt + 1;
            DISP_ONOFF : 
                if(cnt >= 30) cnt <= 0;
                else cnt <= cnt + 1;
            ENTRY_MODE : 
                if(cnt >= 30) cnt <= 0;
                else cnt <= cnt + 1;
            SET_ADDRESS : 
                if(cnt >= 100) cnt <= 0;
                else cnt <= cnt + 1;
            WRITE : 
                if(cnt >= 30) cnt <= 0;
                else cnt <= cnt + 1;
            DELAY_T : 
                if(cnt >= 5) cnt <= 0;
                else cnt <= cnt + 1;
            CLEAR_DISP :
                if(cnt >= 5) cnt <= 0;
                else cnt <= cnt + 1;
        endcase
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst)
        {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_0001;
    else begin
        case(state)
            FUNCTION_SET : 
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0011_1000;
            DISP_ONOFF :
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_1100;
            ENTRY_MODE :
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_0110;
            SET_ADDRESS : 
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_0010;
            WRITE : begin
                case(cnt)
                    00 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; //
                    01 : {LCD_RS, LCD_RW, LCD_DATA} = {1'b1, 1'b0, {4'b0011, bcd[11:8]}}; //100
                    02 : {LCD_RS, LCD_RW, LCD_DATA} = {1'b1, 1'b0, {4'b0011, bcd[7:4]}}; //10
                    03 : {LCD_RS, LCD_RW, LCD_DATA} = {1'b1, 1'b0, {4'b0011, bcd[3:0]}}; //1 
                    04 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // 
                    05 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; //
                    06 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // 
                    07 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // 
                    08 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // 
                    09 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // 
                    10 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // 
                    11 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // 
                    12 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // 
                    13 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // 
                    14 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; //
                    15 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; //
                    16 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; //
                    default : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; //
                endcase
            end
            DELAY_T : 
                {LCD_RS, LCD_RW, LCD_DATA} = 10'b0_0_0000_0010;
            CLEAR_DISP : 
                {LCD_RS, LCD_RW, LCD_DATA} = 10'b0_0_0000_0001;
            default : 
                {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_1_0000_0000;
        endcase
    end
end

assign LCD_E = clk;
        
endmodule