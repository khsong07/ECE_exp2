`timescale 1ns / 1ps
module LCD(rst,clk,LCD_E,LCD_RS,LCD_RW,LCD_DATA, day_night,hours_tens, hours_ones, minutes_tens, minutes_ones, seconds_tens, seconds_ones,state1);

input rst,clk;
input day_night;
input [3:0] hours_tens, hours_ones, minutes_tens, minutes_ones, seconds_tens, seconds_ones;

input[3:0] state1;

output LCD_E,LCD_RS,LCD_RW;
output reg[7:0] LCD_DATA;

wire LCD_E;
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
integer cnt;

always @(posedge clk or negedge  rst)
begin
    if(!rst)begin
        state=DELAY;
        cnt=0;
    end
    else begin
        case(state)
            DELAY:begin
                if(cnt==70) state=FUNCTION_SET;
                if(cnt >= 70) cnt = 0;
                else cnt = cnt + 1; 
            end
            FUNCTION_SET:begin
                if(cnt==30) state=DISP_ONOFF;
                if(cnt >= 30) cnt = 0;
                else cnt = cnt + 1;

            end
            DISP_ONOFF:begin
                if(cnt==30) state=ENTRY_MODE;
                if(cnt >= 30) cnt = 0;
                else cnt = cnt + 1;

            end
            ENTRY_MODE:begin
                if(cnt==30) state=LINE1;
                 if(cnt >= 30) cnt = 0;
                else cnt = cnt + 1;

            end
            LINE1:begin
                if(cnt==20) state=LINE2;
                if(cnt >= 20) cnt = 0;
                else cnt = cnt + 1;

            end
            LINE2:begin
                if(cnt==20) state=DELAY_T;
                if(cnt >= 20) cnt = 0;
                else cnt = cnt + 1;

            end
            DELAY_T:begin
                if(cnt==200) state=CLEAR_DISP;
                if(cnt >= 200) cnt = 0;
                else cnt = cnt + 1;

            end
            CLEAR_DISP:begin
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
                {LCD_RS,LCD_RW,LCD_DATA}=10'b0_0_0011_1000;
            DISP_ONOFF:
                {LCD_RS,LCD_RW,LCD_DATA}=10'b0_0_0000_1100;
            ENTRY_MODE:
                {LCD_RS,LCD_RW,LCD_DATA}=10'b0_0_0000_0110;

LINE1:
    begin
        case(cnt)
            00:{LCD_RS,LCD_RW,LCD_DATA}=10'b0_0_1000_0000;
            01:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0101_0100;//T
            02:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_1001;//I
            03:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_1101;//M
            04:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0101;//E
            05:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0011_1010;//:
            06:
                case(hours_tens)
                4'b0001:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0001;//1
                4'b0010:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0010;//2
                4'b0011:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0011;//3
                4'b0100:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0100;//4
                4'b0101:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0101;//5
                4'b0110:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0110;//6
                4'b0111:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0111;//7
                4'b1000:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_1000;//8
                4'b1001:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_1001;//9
                4'b0000:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0000;//0
                endcase
            07:
                 case(hours_ones)
                4'b0001:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0001;//1
                4'b0010:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0010;//2
                4'b0011:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0011;//3
                4'b0100:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0100;//4
                4'b0101:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0101;//5
                4'b0110:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0110;//6
                4'b0111:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0111;//7
                4'b1000:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_1000;//8
                4'b1001:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_1001;//9
                4'b0000:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0000;//0
                endcase
            08:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0011_1010;//:
            09:
                case(minutes_tens)
                4'b0001:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0001;//1
                4'b0010:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0010;//2
                4'b0011:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0011;//3
                4'b0100:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0100;//4
                4'b0101:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0101;//5
                4'b0110:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0110;//6
                4'b0111:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0111;//7
                4'b1000:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_1000;//8
                4'b1001:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_1001;//9
                4'b0000:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0000;//0
                endcase
            10:
                 case(minutes_ones)
                4'b0001:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0001;//1
                4'b0010:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0010;//2
                4'b0011:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0011;//3
                4'b0100:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0100;//4
                4'b0101:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0101;//5
                4'b0110:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0110;//6
                4'b0111:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0111;//7
                4'b1000:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_1000;//8
                4'b1001:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_1001;//9
                4'b0000:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0000;//0
                endcase
            11:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0011_1010;//:
            12:
                case(seconds_tens)
                4'b0001:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0001;//1
                4'b0010:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0010;//2
                4'b0011:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0011;//3
                4'b0100:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0100;//4
                4'b0101:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0101;//5
                4'b0110:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0110;//6
                4'b0111:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0111;//7
                4'b1000:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_1000;//8
                4'b1001:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_1001;//9
                4'b0000:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0000;//0
                endcase
            13:
                 case(seconds_ones)
                4'b0001:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0001;//1
                4'b0010:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0010;//2
                4'b0011:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0011;//3
                4'b0100:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0100;//4
                4'b0101:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0101;//5
                4'b0110:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0110;//6
                4'b0111:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0111;//7
                4'b1000:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_1000;//8
                4'b1001:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_1001;//9
                4'b0000:{LCD_RS,LCD_RW,LCD_DATA}<=10'b1_0_0011_0000;//0
                endcase
            14:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            15:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            16:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
            default:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//         
        endcase
    end

LINE2:
    begin
        case(cnt)
            00:{LCD_RS,LCD_RW,LCD_DATA}=10'b0_0_1100_0000;
            01:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0101_0011;//S
            02:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0101_0100;//T
            03:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0001;//A
            04:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0101_0100;//T
            05:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0101;//E
            06:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0011_1010;//:
            07:
                case(state1)
                4'b0001:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0001;//A
                4'b1011:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0001;//A(EM)
                4'b1100:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0001;//A(EM_A)
                4'b1001:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0001;//A(AA)
                4'b0010:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0010;//B
                4'b0011:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0011;//C
                4'b0100:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0100;//D
                4'b0101:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0101;//E
                4'b1010:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0101;//E(EE)
                4'b0110:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0110;//F
                4'b0111:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0111;//G
                4'b1000:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_1000;//H
                endcase
            08:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_1000;//(
            09:
                case(day_night)
                0:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_1110;//n
                1:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0100;//d
                endcase
            10:
                case(day_night)
                0:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_1001;//i
                endcase
            11:
                case(day_night)
                0:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_0111;//g
                1:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0101_1001;//y
                endcase
            12:
                case(day_night)
                0: {LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0100_1000;//h
                1: {LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_1001;//)
                endcase
            13:
                case(day_night)
                0: {LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0101_0100;//t
                1:{LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
                endcase
            14:
                case(day_night)
                0: {LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_1001;//)
                1: {LCD_RS,LCD_RW,LCD_DATA}=10'b1_0_0010_0000;//
                endcase
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