module LCD(rst,clk,bin,LCD_E,LCD_RS,LCD_RW,LCD_DATA);

input rst,clk;
input [7:0] bin;

output LCD_E,LCD_RS,LCD_RW;
output reg[7:0] LCD_DATA;

wire[11:0] bcd;
wire LCD_E;

reg[9:0] data1;
reg[9:0] data2;
reg[9:0] data3;

reg LCD_RS,LCD_RW;
reg[2:0] state;
parameter DELAY=3'b000,
          FUNCTION_SET=3'b001,
          ENTRY_MODE  =3'b010,
          DISP_ONOFF  =3'b011,
          LINE1       =3'b100,
          LINE2       =3'b101,
          DELAY_T     =3'b110,
          CLEAR_DISP  =3'b111;
 parameter NUM0=10'b1_0_0011_0000,
           NUM1=10'b1_0_0011_0001,
           NUM2=10'b1_0_0011_0010,
           NUM3=10'b1_0_0011_0011,
           NUM4=10'b1_0_0011_0100,
           NUM5=10'b1_0_0011_0101,
           NUM6=10'b1_0_0011_0110,
           NUM7=10'b1_0_0011_0111,
           NUM8=10'b1_0_0011_1000,
           NUM9=10'b1_0_0011_1001;     
integer cnt;

bin2bcd b1(clk,rst,bin,bcd);


always @(posedge clk or negedge rst)
begin
    if(!rst)begin
        state=DELAY;
        cnt=0;
    end
    else begin
        case(state)
            DELAY:begin
               // LED_out=8'b1000_0000;
                if(cnt==70) state=FUNCTION_SET;
                if(cnt >= 70) cnt = 0;
                else cnt = cnt + 1; 
            end
            FUNCTION_SET:begin
              //  LED_out=8'b0100_0000;
                if(cnt==30) state=DISP_ONOFF;
                if(cnt >= 30) cnt = 0;
                else cnt = cnt + 1;

            end
            DISP_ONOFF:begin
               // LED_out=8'b0010_0000;
                if(cnt==30) state=ENTRY_MODE;
                if(cnt >= 30) cnt = 0;
                else cnt = cnt + 1;

            end
            ENTRY_MODE:begin
                //LED_out=8'b0001_0000;
                if(cnt==30) state=LINE1;
                 if(cnt >= 30) cnt = 0;
                else cnt = cnt + 1;

            end
            LINE1:begin
             //   LED_out=8'b0000_1000;
                if(cnt==20) state=LINE2;
                if(cnt >= 20) cnt = 0;
                else cnt = cnt + 1;

            end
            LINE2:begin
             //   LED_out=8'b0000_0100;
                if(cnt==20) state=DELAY_T;
                if(cnt >= 20) cnt = 0;
                else cnt = cnt + 1;

            end
            DELAY_T:begin
                //LED_out=8'b0000_0010;
                if(cnt==5) state=CLEAR_DISP;
                if(cnt >= 5) cnt = 0;
                else cnt = cnt + 1;

            end
            CLEAR_DISP:begin
                //LED_out=8'b0000_0001;
                if(cnt==5) state=LINE1;
                 if(cnt >= 5) cnt = 0;
                else cnt = cnt + 1;

            end
            default:state=DELAY;
        endcase
    end
end

always @(posedge clk or negedge rst)
begin
    if(!rst)
        {LCD_RS,LCD_RW,LCD_DATA}=10'b1_1_00000000;
    else begin
        case(state)
            FUNCTION_SET:
                {LCD_RS,LCD_RW,LCD_DATA}=10'b0_0_0011_0000;
            DISP_ONOFF:
                {LCD_RS,LCD_RW,LCD_DATA}=10'b0_0_0000_1100;
            ENTRY_MODE:
                {LCD_RS,LCD_RW,LCD_DATA}=10'b0_0_0000_0110;

LINE1:
    begin
        case(bcd[3:0])
            0:data1=NUM0;
            1:data1=NUM1;
            2:data1=NUM2;
            3:data1=NUM3;
            4:data1=NUM4;
            5:data1=NUM5;
            6:data1=NUM6;
            7:data1=NUM7;
            8:data1=NUM8;
            9:data1=NUM9;
        endcase
        case(bcd[7:4])
            0:data2=NUM0;
            1:data2=NUM1;
            2:data2=NUM2;
            3:data2=NUM3;
            4:data2=NUM4;
            5:data2=NUM5;
            6:data2=NUM6;
            7:data2=NUM7;
            8:data2=NUM8;
            9:data2=NUM9;
        endcase
        case(bcd[11:8])
            0:data3=NUM0;
            1:data3=NUM1;
            2:data3=NUM2;
            3:data3=NUM3;
            4:data3=NUM4;
            5:data3=NUM5;
            6:data3=NUM6;
            7:data3=NUM7;
            8:data3=NUM8;
            9:data3=NUM9;
        endcase        
        case(cnt)
            00:{LCD_RS,LCD_RW,LCD_DATA}=10'b0_0_1000_0000;
            01:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            02:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            03:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            04:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            05:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            06:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            07:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            08:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            09:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            10:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            11:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            12:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            13:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            14:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            15:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            16:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            default:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
        endcase
    end

            DELAY_T:
                {LCD_RS,LCD_RW,LCD_DATA}=10'b0_0_0000_0010;
            CLEAR_DISP:
                {LCD_RS,LCD_RW,LCD_DATA}=10'b0_0_0000_0001;
            default:
                {LCD_RS,LCD_RW,LCD_DATA}=10'b1_1_0000_0000;
        endcase
    end
end

assign LCD_E=clk;

endmodule