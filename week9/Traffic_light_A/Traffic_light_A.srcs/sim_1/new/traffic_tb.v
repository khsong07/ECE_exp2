`timescale 1ms / 1us

module traffic_tb();

reg rst, clk;
reg btn;//시간 추가 버튼
reg emergency;//구급차량 버튼
reg [1:0] scale;
wire[3:0] traffic_light_N;
wire[3:0] traffic_light_S;
wire[3:0] traffic_light_W;
wire[3:0] traffic_light_E;
wire[1:0] pedestrian_light_N;
wire[1:0] pedestrian_light_S;
wire[1:0] pedestrian_light_W;
wire[1:0] pedestrian_light_E;
wire LCD_E, LCD_RS, LCD_RW;
wire[7:0] LCD_DATA;

Traffic_light_A T1(LCD_E,LCD_RS,LCD_RW,LCD_DATA,rst, clk,btn,emergency,scale,traffic_light_N,traffic_light_S,traffic_light_W,traffic_light_E,pedestrian_light_N,pedestrian_light_S,pedestrian_light_W,pedestrian_light_E);

 initial begin
    clk<=0;
    rst<=0;
    #10 rst<=1;
    #10 rst<=0;
end

always begin
    #1 clk<=~clk;
end


endmodule
