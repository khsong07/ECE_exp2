`timescale 1ns / 1ps
module Traffic_light_A(LCD_E,LCD_RS,LCD_RW,LCD_DATA,rst, clk,btn,emergency,scale,traffic_light_N,traffic_light_S,traffic_light_W,traffic_light_E,pedestrian_light_N,pedestrian_light_S,pedestrian_light_W,pedestrian_light_E);

input rst, clk; //reset과 clock
input btn;//1시간 추가 버튼
input emergency;//수동조작 버튼
input [1:0] scale;//배율 조작을 위한 버튼(DIP스위치)

output reg[3:0] traffic_light_N;//북쪽  차량 신호등(빨,황,초,좌측 신호 순)
output reg[3:0] traffic_light_S;//남쪽 차량 신호등
output reg[3:0] traffic_light_W;//서쪽 차량 신호등
output reg[3:0] traffic_light_E;//동쪽 차량 신호등
output reg[1:0] pedestrian_light_N;//북쪽 보행자 신호등(초,빨 순)
output reg[1:0] pedestrian_light_S;//남쪽 보행자 신호등
output reg[1:0] pedestrian_light_W;//서쪽 보행자 신호등
output reg[1:0] pedestrian_light_E;//동쪽 보행자 신호등

output LCD_E, LCD_RS, LCD_RW;
output[7:0] LCD_DATA;//LCD 출력

parameter
    A = 4'b0001, 
    B = 4'b0010, 
    C = 4'b0011, 
    D = 4'b0100, 
    E = 4'b0101, 
    F = 4'b0110, 
    G = 4'b0111, 
    H = 4'b1000,
    AA = 4'b1001,
    EE = 4'b1010,
    EM = 4'b1011,
    EM_A = 4'b1100;//각 state parameter 설정

reg[3:0] state;//현재 상태
reg[3:0] prev_state;//이전 상태 기억
reg prev_day_night;//이전 낮/밤 상태 기억(낮=1,밤=0)
reg[31:0] cnt;//시간 측정을 위한 cnt
reg day_night;//낮밤 판단(1이면 낮 0이면 밤)
reg[31:0] emergency_counter;//시간 간격 측정용 counter(긴급차량)
reg[31:0] day_counter;//시간 간격 측정용 counter(주간)
reg[31:0] night_counter;//시간 간격 측정용 counter(야간)

reg [3:0] hours_tens, hours_ones, minutes_tens, minutes_ones, seconds_tens, seconds_ones;
//시,분,초 표현(십의 자리, 일의 자리)_LCD출력을 위함
wire emergency_t,btn_t;

LCD L1(rst,clk,LCD_E,LCD_RS, LCD_RW, LCD_DATA[7:0], day_night,hours_tens, hours_ones, minutes_tens, minutes_ones, seconds_tens, seconds_ones,state);//LCD 표시
oneshot_universal #(.WIDTH(2)) O1(clk,rst,{emergency,btn},{emergency_t,btn_t});//one_shot trigger

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        cnt <= 32'd0;//초기 cnt 0으로 설정
        day_night<=0;//기본은 밤으로(00:00:00은 밤 시간 이므로)
        prev_day_night<=day_night;//이전 낮/밤 상태 밤으로 초기화
        hours_tens <= 4'd0;//시(십의 자리) 초기화
        hours_ones <= 4'd0;//시(일의 자리) 초기화
        minutes_tens <= 4'd0;//분(십의 자리) 초기화
        minutes_ones <= 4'd0;//분(일의 자리) 초기화
        seconds_tens <= 4'd0;//초(십의 자리) 초기화
        seconds_ones <= 4'd0;//초(일의 자리) 초기화
 
    end else begin
        if (cnt >= 24 * 60 * 60 * 1000 ) cnt = 0;//최대 시간 넘어가면  다시 00시 00분 00초로
        else if (btn_t) cnt = cnt + 60 * 60 * 1000;// 시간 추가 버튼 누르면 1시간 추가
       else begin
        case(scale)
            2'b00: cnt=cnt+32'd1;//1배 배율 버튼이 눌렸을 경우
            2'b01: cnt=cnt+32'd10;//10배 배율 버튼이 눌렸을 경우
            2'b10: cnt=cnt+32'd100;//100배 배율 버튼이 눌렸을 경우
            2'b11: cnt=cnt+32'd200;//200배 배율 버튼이 눌렸을 경우
        endcase
                
        hours_tens <= cnt / 36000000; // 시간의 십의 자리 숫자
        hours_ones <= (cnt % 36000000) / 3600000; // 시간의 일의 자리 숫자
        minutes_tens <= (cnt % 3600000) / 600000; // 분의 십의 자리 숫자
        minutes_ones <= (cnt % 600000) / 60000; // 분의 일의 자리 숫자
        seconds_tens <= (cnt % 60000) / 10000; // 초의 십의 자리 숫자
        seconds_ones <= (cnt % 10000) / 1000; // 초의 일의 자리 숫자
        
        prev_day_night<=day_night;//낮범을 결정하기 전 이전 낮밤 상태를 기록
        if (cnt >= 8 * 60 * 60 *1000 && cnt < 23 * 60 * 60*1000) day_night <= 1;//8시부터 23시 사이는 주간(1)
        else day_night <= 0;// 23시부터 8시는 야간(0)
  end
end
end

always @(posedge clk or negedge rst) begin
 if (!rst) begin
    state <= B;//초기 상태 B로 시작(야간 기준)
    prev_state <= state;//이전 상태를 B로 기억
    emergency_counter <= 0;//긴급차량 counter 초기화
    day_counter<=0;//주간 counter 초기화
    night_counter<=0;//야간 counter 초기화
    
end else if (emergency_t&&(state!=EM||state!=EM_A)) begin//구급차 버튼이 눌린 상황
    prev_state = state;//이전 상태를 기억
    state = EM;//EM state로 넘어가기
               
end else if (day_night==1) begin  // 주간 동작
    if(prev_day_night==0)state<=A;//이전에 야간에서 끝난 경우 A부터 새로 시작
    else begin 
		case (state)
			A: begin
				if(day_counter>=5000)begin//A state 5초간 유지
					day_counter<=0;//5초 지난 경우 낮 counter값 초기화
					state <= D;//D state로 이동
				end else day_counter=day_counter+1;//5초가 지나지 않은 경우 counter 증가
				end
			D: begin
				if (day_counter >= 5000)begin//D state 5초간 유지
					day_counter<=0;
					state <= F;//F state로 이동
				end else day_counter = day_counter + 1;
				end
			F: begin
				if (day_counter >= 5000)begin//F state 5초간 유지
				    day_counter<=0;
				    state <= E;//E state로 이동
				end else day_counter = day_counter + 1;
				end
			E: begin
				if (day_counter >= 5000)begin//E state 5초간 유지
				    day_counter<=0;
				    state <= G;//G state로 이동
				end else day_counter = day_counter + 1;
				end
			G: begin
				if (day_counter >= 5000)begin//G state  5초간 유지
				    day_counter<=0;
				    state <= EE;//EE state로 이동
				end else day_counter = day_counter + 1;
				end
		   EE: begin//주간동작에서 한 신호 변화 사이클에서 두번째로 등장하는 E state
			   if (day_counter >= 5000)begin//EE state 5초간 유지
			     day_counter<=0;
			     state <= A;//A state로 이동
			   end else day_counter = day_counter + 1;
			   end
            EM: begin//버튼 수동 조작 버튼을 눌렀을 때 A state 전환 전 1초 대기하는 state
              if (emergency_counter >= 1000)begin//EM state 1초간 유지
                emergency_counter <= 0;
                state <= EM_A;//EM_A state로 이동
            end else emergency_counter = emergency_counter + 1;
            end
            EM_A:begin//버튼 수동 조작 버튼을 누르고 1초가 지났을 경우 state A를 수행하는 state
            if (emergency_counter >= 15000)begin//EM_A state 15초간 유지
                emergency_counter<=0;
                state <= prev_state;//15초가 지나면 기존 state로 복귀
            end else emergency_counter = emergency_counter + 1;
            end        
		endcase
		end
		
end else if (day_night == 0) begin  // 야간 동작
        if(prev_day_night==1)state<=B;//이전에 야간에서 끝난 경우 B부터 새로 시작
        else begin 
		case (state)
		B: begin
			if (night_counter >= 10000)begin//B state 10초간 유지
			    night_counter<=0;//10초가 지난 경우 밤 counter값 초기화
			    state <= A;//A state로 이동
			end else night_counter = night_counter + 1;//10초가 지나지 않은 경우 counter 증가
			end
		A: begin
			if (night_counter >= 10000)begin//A state 10초간 유지
			    night_counter<=0;
			    state <= C;//C state로 이동
			end else night_counter = night_counter + 1;
			end
	   C: begin
		   if (night_counter >= 10000)begin//C state 10초간 유지
			    night_counter<=0;
			    state <= AA;//AA state로 이동
		 end else night_counter = night_counter + 1;
		   end
	  AA: begin//야간동작에서 한 신호 변화 사이클에서 두번째로 등장하는 A state
		  if (night_counter >= 10000)begin//AA state 10초간 유지
			    night_counter<=0;
			    state <= E;//E state로 이동
		  end else night_counter = night_counter + 1;
		  end
	  E: begin
		  if (night_counter >= 10000)begin//E state 10초간 유지
			    night_counter<=0;
			    state <= H;//H state로 이동
		  end else night_counter = night_counter + 1;
		  end
	 H: begin
		 if (night_counter >= 10000)begin//H state 10초간 유지
			    night_counter<=0;
			    state <= B;//B state로 이동
		 end else night_counter = night_counter + 1;
		 end
	EM: begin//버튼 수동 조작 버튼을 눌렀을 때 A state 전환 전 1초 대기하는 state(주간동작과 동일)
		if (emergency_counter >= 1000)begin//EM state 1초간 유지
			emergency_counter <= 0;
            state <= EM_A;//EM_A state로 이동
		end else emergency_counter = emergency_counter + 1;
		end
   EM_A:begin//버튼 수동 조작 버튼을 누르고 1초가 지났을 경우 state A를 수행하는 state(주간동작과 동일)
       if (emergency_counter >= 15000) begin//EM_A state 15초간 유지
           emergency_counter<=0;
           state <= prev_state;//15초가 지나면 기존 state로 복귀
       end else emergency_counter = emergency_counter + 1;
       end
	endcase
	end
end
end

always @(posedge clk or negedge  rst)
begin
    if(!rst)begin
        {traffic_light_N,pedestrian_light_N}<=6'b0000_00;//북쪽 신호(빨황초왼_초빨) 초기화
        {traffic_light_S,pedestrian_light_S}<=6'b0000_00;//남쪽 신호(빨황초왼_초빨) 초기화
        {traffic_light_W,pedestrian_light_W}<=6'b0000_00;//서쪽 신호(빨황초왼_초빨) 초기화
        {traffic_light_E,pedestrian_light_E}<=6'b0000_00;//남쪽 신호(빨황초왼_초빨) 초기화
        end
    else begin
        case(state)
            A:begin
                {traffic_light_N,pedestrian_light_N}<=6'b0010_01;
                {traffic_light_S,pedestrian_light_S}<=6'b0010_01;
                {traffic_light_W,pedestrian_light_W}<=6'b1000_10;
                {traffic_light_E,pedestrian_light_E}<=6'b1000_10;     
                if(!day_night) begin//야간 동작시
                    if(night_counter>=5000&&night_counter<5500)begin//야간 시간의 절반(5초)부터 보행자 점멸신호 시작
                        pedestrian_light_W[1]<=0; 
                        pedestrian_light_E[1]<=0;
                    end else if(night_counter>=5500&&night_counter<6000)begin
                        pedestrian_light_W[1]<=1; 
                        pedestrian_light_E[1]<=1;
                    end else if(night_counter>=6000&&night_counter<6500)begin
                        pedestrian_light_W[1]<=0; 
                        pedestrian_light_E[1]<=0;
                    end else if(night_counter>=6500&&night_counter<7000)begin
                        pedestrian_light_W[1]<=1; 
                        pedestrian_light_E[1]<=1;
                    end else if(night_counter>=7000&&night_counter<7500)begin
                        pedestrian_light_W[1]<=0; 
                        pedestrian_light_E[1]<=0;
                    end else if(night_counter>=7500&&night_counter<8000)begin
                        pedestrian_light_W[1]<=1; 
                        pedestrian_light_E[1]<=1;
                    end else if(night_counter>=8000&&night_counter<8500)begin
                        pedestrian_light_W[1]<=0; 
                        pedestrian_light_E[1]<=0;
                    end else if(night_counter>=8500&&night_counter<9000)begin
                        pedestrian_light_W[1]<=1; 
                        pedestrian_light_E[1]<=1;     
                    end else if(night_counter>=9000&&night_counter<9500)begin//state변환 1초 전부터 황색 신호 점등 시작
                        pedestrian_light_W[1]<=0; 
                        pedestrian_light_E[1]<=0;
                        traffic_light_N[2]<=1;
                        traffic_light_N[1]<=0;
                    end else if(night_counter>=9500&&night_counter<10000)begin
                        pedestrian_light_W[1]<=1; 
                        pedestrian_light_E[1]<=1;
                        traffic_light_N[2]<=1;
                        traffic_light_N[1]<=0;
                    end
                end else if(day_night) begin//주간 동작시
                    if(day_counter>=2500&&day_counter<3000)begin //주간 시간의 절반(2.5초)부터 보행자 점멸신호 시작
                        pedestrian_light_W[1]<=0; 
                        pedestrian_light_E[1]<=0;
                    end else if(day_counter>=3500&&day_counter<4000)begin
                        pedestrian_light_W[1]<=1; 
                        pedestrian_light_E[1]<=1;
                    end else if(day_counter>=4000&&day_counter<4500)begin
                        pedestrian_light_W[1]<=0; 
                        pedestrian_light_E[1]<=0;
                    end else if(day_counter>=4500&&day_counter<5000)begin
                        pedestrian_light_W[1]<=1; 
                        pedestrian_light_E[1]<=1;
                    end 
               end    
               end        

            B:begin
                {traffic_light_N,pedestrian_light_N}<=6'b0011_01;
                {traffic_light_S,pedestrian_light_S}<=6'b1000_01;
                {traffic_light_W,pedestrian_light_W}<=6'b1000_01;
                {traffic_light_E,pedestrian_light_E}<=6'b1000_10;
                    if(night_counter>=5000&&night_counter<5500)begin //야간 시간의 절반(5초)부터 보행자 점멸신호 시작
                        pedestrian_light_E[1]<=0;
                    end else if(night_counter>=5500&&night_counter<6000)begin
                        pedestrian_light_E[1]<=1;
                    end else if(night_counter>=6000&&night_counter<6500)begin
                        pedestrian_light_E[1]<=0;
                    end else if(night_counter>=6500&&night_counter<7000)begin
                        pedestrian_light_E[1]<=1;
                    end else if(night_counter>=7000&&night_counter<7500)begin
                        pedestrian_light_E[1]<=0;
                    end else if(night_counter>=7500&&night_counter<8000)begin
                        pedestrian_light_E[1]<=1;
                    end else if(night_counter>=8000&&night_counter<8500)begin
                        pedestrian_light_E[1]<=0; 
                    end else if(night_counter>=8500&&night_counter<9000)begin
                        pedestrian_light_E[1]<=1;     
                    end else if(night_counter>=9000&&night_counter<9500)begin//state변환 1초 전부터 황색 신호 점등 시작
                        pedestrian_light_E[1]<=0; 
                        traffic_light_N[2]<=1;
                        traffic_light_N[0]<=0;
                    end else if(night_counter>=9500&&night_counter<10000)begin 
                        pedestrian_light_E[1]<=1;
                        traffic_light_N[2]<=1;
                        traffic_light_N[0]<=0;
                    end                
            end                     
            
            C:begin
                {traffic_light_N,pedestrian_light_N}<=6'b1000_01;
                {traffic_light_S,pedestrian_light_S}<=6'b0011_01;
                {traffic_light_W,pedestrian_light_W}<=6'b1000_10;
                {traffic_light_E,pedestrian_light_E}<=6'b1000_01;
                    if(night_counter>=5000&&night_counter<5500)begin //야간 시간의 절반(5초)부터 보행자 점멸신호 시작
                        pedestrian_light_W[1]<=0;
                    end else if(night_counter>=5500&&night_counter<6000)begin
                        pedestrian_light_W[1]<=1;
                    end else if(night_counter>=6000&&night_counter<6500)begin
                        pedestrian_light_W[1]<=0;
                    end else if(night_counter>=6500&&night_counter<7000)begin
                        pedestrian_light_W[1]<=1;
                    end else if(night_counter>=7000&&night_counter<7500)begin
                        pedestrian_light_W[1]<=0;
                    end else if(night_counter>=7500&&night_counter<8000)begin
                        pedestrian_light_W[1]<=1;
                    end else if(night_counter>=8000&&night_counter<8500)begin
                        pedestrian_light_W[1]<=0; 
                    end else if(night_counter>=8500&&night_counter<9000)begin
                        pedestrian_light_W[1]<=1;   
                    end else if(night_counter>=9000&&night_counter<9500)begin//state변환 1초 전부터 황색 신호 점등 시작
                        pedestrian_light_W[1]<=0; 
                        traffic_light_S[2]<=1;
                        traffic_light_S[0]<=0;
                    end else if(night_counter>=9500&&night_counter<10000)begin
                        pedestrian_light_W[1]<=1;
                        traffic_light_S[2]<=1;
                        traffic_light_S[0]<=0;
                    end            
            end            
                
            D:begin
                if (day_counter >= 4000)begin//state변환 1초 전부터 황색 신호 점등 시작
                    {traffic_light_N,pedestrian_light_N}<=6'b0001_01;
                    {traffic_light_S,pedestrian_light_S}<=6'b0100_01;
                    {traffic_light_W,pedestrian_light_W}<=6'b1000_01;
                    {traffic_light_E,pedestrian_light_E}<=6'b1000_01;
                end else begin                
                    {traffic_light_N,pedestrian_light_N}<=6'b0001_01;
                    {traffic_light_S,pedestrian_light_S}<=6'b0001_01;
                    {traffic_light_W,pedestrian_light_W}<=6'b1000_01;
                    {traffic_light_E,pedestrian_light_E}<=6'b1000_01;
                end
            end
     
          E:begin
            {traffic_light_N,pedestrian_light_N}<=6'b1000_10;
            {traffic_light_S,pedestrian_light_S}<=6'b1000_10;
            {traffic_light_W,pedestrian_light_W}<=6'b0010_01;
            {traffic_light_E,pedestrian_light_E}<=6'b0010_01;
          if(!day_night) begin//야간 동작시
                    if(night_counter>=5000&&night_counter<5500)begin //야간 시간의 절반(5초)부터 보행자 점멸신호 시작
                        pedestrian_light_N[1]<=0; 
                        pedestrian_light_S[1]<=0;
                    end else if(night_counter>=5500&&night_counter<6000)begin
                        pedestrian_light_N[1]<=1; 
                        pedestrian_light_S[1]<=1;
                    end else if(night_counter>=6000&&night_counter<6500)begin
                        pedestrian_light_N[1]<=0; 
                        pedestrian_light_S[1]<=0;
                    end else if(night_counter>=6500&&night_counter<7000)begin
                        pedestrian_light_N[1]<=1; 
                        pedestrian_light_S[1]<=1;
                    end else if(night_counter>=7000&&night_counter<7500)begin
                        pedestrian_light_N[1]<=0; 
                        pedestrian_light_S[1]<=0;
                    end else if(night_counter>=7500&&night_counter<8000)begin
                        pedestrian_light_N[1]<=1; 
                        pedestrian_light_S[1]<=1;
                    end else if(night_counter>=8000&&night_counter<8500)begin
                        pedestrian_light_N[1]<=0; 
                        pedestrian_light_S[1]<=0;
                    end else if(night_counter>=8500&&night_counter<9000)begin
                        pedestrian_light_N[1]<=1; 
                        pedestrian_light_S[1]<=1;    
                    end else if(night_counter>=9000&&night_counter<9500)begin
                        pedestrian_light_N[1]<=0; 
                        pedestrian_light_S[1]<=0;
                    end else if(night_counter>=9500&&night_counter<10000)begin
                        pedestrian_light_N[1]<=1; 
                        pedestrian_light_S[1]<=1;
                    end
                end else if(day_night) begin//주간 동작시
                    if(day_counter>=2500&&day_counter<3000)begin  //주간 시간의 절반(2.5초)부터 보행자 점멸신호 시작
                        pedestrian_light_N[1]<=0; 
                        pedestrian_light_S[1]<=0;
                    end else if(day_counter>=3500&&day_counter<4000)begin
                        pedestrian_light_N[1]<=1; 
                        pedestrian_light_S[1]<=1;
                    end else if(day_counter>=4000&&day_counter<4500)begin//state변환 1초 전부터 황색 신호 점등 시작
                        pedestrian_light_N[1]<=0; 
                        pedestrian_light_S[1]<=0;
                        traffic_light_W[2]<=1;
                        traffic_light_W[1]<=0;
                    end else if(day_counter>=4500&&day_counter<5000)begin
                        pedestrian_light_N[1]<=1; 
                        pedestrian_light_S[1]<=1;
                        traffic_light_W[2]<=1;
                        traffic_light_W[1]<=0;
                    end 
               end    
               end        
            
            F:begin
                {traffic_light_N,pedestrian_light_N}<=6'b1000_10;
                {traffic_light_S,pedestrian_light_S}<=6'b1000_01;
                {traffic_light_W,pedestrian_light_W}<=6'b0011_01;
                {traffic_light_E,pedestrian_light_E}<=6'b1000_01;
                    if(day_counter>=2500&&day_counter<3000)begin  //주간 시간의 절반(2.5초)부터 보행자 점멸신호 시작
                        pedestrian_light_N[1]<=0; 
                    end else if(day_counter>=3500&&day_counter<4000)begin
                        pedestrian_light_N[1]<=1; 
                    end else if(day_counter>=4000&&day_counter<4500)begin//state변환 1초 전부터 황색 신호 점등 시작
                        pedestrian_light_N[1]<=0; 
                        traffic_light_W[2]<=1;
                        traffic_light_W[0]<=0;
                    end else if(day_counter>=4500&&day_counter<5000)begin
                        pedestrian_light_N[1]<=1; 
                        traffic_light_W[2]<=1;
                        traffic_light_W[0]<=0;
                    end   
                    end              
          
            G:begin
                {traffic_light_N,pedestrian_light_N}<=6'b1000_01;
                {traffic_light_S,pedestrian_light_S}<=6'b1000_10;
                {traffic_light_W,pedestrian_light_W}<=6'b1000_01;
                {traffic_light_E,pedestrian_light_E}<=6'b0011_01;
                 if(day_counter>=2500&&day_counter<3000)begin  //주간 시간의 절반(2.5초)부터 보행자 점멸신호 시작
                        pedestrian_light_S[1]<=0; 
                    end else if(day_counter>=3500&&day_counter<4000)begin
                        pedestrian_light_S[1]<=1; 
                    end else if(day_counter>=4000&&day_counter<4500)begin//state변환 1초 전부터 황색 신호 점등 시작
                        pedestrian_light_S[1]<=0; 
                        traffic_light_E[2]<=1;
                        traffic_light_E[0]<=0;
                    end else if(day_counter>=4500&&day_counter<5000)begin
                        pedestrian_light_S[1]<=1; 
                        traffic_light_E[2]<=1;
                        traffic_light_E[0]<=0;
                    end   
                    end             
             
            H:begin
                if(night_counter>=9000)begin//state변환 1초 전부터 황색 신호 점등 시작
                    {traffic_light_N,pedestrian_light_N}<=6'b1000_01;
                    {traffic_light_S,pedestrian_light_S}<=6'b1000_01;
                    {traffic_light_W,pedestrian_light_W}<=6'b0100_01;
                    {traffic_light_E,pedestrian_light_E}<=6'b0100_01;
                end else begin               
                    {traffic_light_N,pedestrian_light_N}<=6'b1000_01;
                    {traffic_light_S,pedestrian_light_S}<=6'b1000_01;
                    {traffic_light_W,pedestrian_light_W}<=6'b0001_01;
                    {traffic_light_E,pedestrian_light_E}<=6'b0001_01;
                end
            end     
            
           AA:begin
                {traffic_light_N,pedestrian_light_N}<=6'b0010_01;
                {traffic_light_S,pedestrian_light_S}<=6'b0010_01;
                {traffic_light_W,pedestrian_light_W}<=6'b1000_10;
                {traffic_light_E,pedestrian_light_E}<=6'b1000_10;
                  if(night_counter>=5000&&night_counter<5500)begin //야간 시간의 절반(5초)부터 보행자 점멸신호 시작
                        pedestrian_light_W[1]<=0; 
                        pedestrian_light_E[1]<=0;
                    end else if(night_counter>=5500&&night_counter<6000)begin
                        pedestrian_light_W[1]<=1; 
                        pedestrian_light_E[1]<=1;
                    end else if(night_counter>=6000&&night_counter<6500)begin
                        pedestrian_light_W[1]<=0; 
                        pedestrian_light_E[1]<=0;
                    end else if(night_counter>=6500&&night_counter<7000)begin
                        pedestrian_light_W[1]<=1; 
                        pedestrian_light_E[1]<=1;
                    end else if(night_counter>=7000&&night_counter<7500)begin
                        pedestrian_light_W[1]<=0; 
                        pedestrian_light_E[1]<=0;
                    end else if(night_counter>=7500&&night_counter<8000)begin
                        pedestrian_light_W[1]<=1; 
                        pedestrian_light_E[1]<=1;
                    end else if(night_counter>=8000&&night_counter<8500)begin
                        pedestrian_light_W[1]<=0; 
                        pedestrian_light_E[1]<=0;
                     end else if(night_counter>=8500&&night_counter<9000)begin
                        pedestrian_light_W[1]<=1; 
                        pedestrian_light_E[1]<=1;    
                    end else if(night_counter>=9000&&night_counter<9500)begin//state변환 1초 전부터 황색 신호 점등 시작
                        pedestrian_light_W[1]<=0; 
                        pedestrian_light_E[1]<=0;
                        traffic_light_N[2]<=1;
                        traffic_light_N[1]<=0;
                        traffic_light_S[1]<=0;
                        traffic_light_S[2]<=1;
                    end else if(night_counter>=9500&&night_counter<10000)begin
                        pedestrian_light_W[1]<=1; 
                        pedestrian_light_E[1]<=1;
                        traffic_light_N[2]<=1;
                        traffic_light_S[2]<=1;
                        traffic_light_N[1]<=0;
                        traffic_light_S[1]<=0;
                    end
                    end
                
            EE:begin
                {traffic_light_N,pedestrian_light_N}<=6'b1000_10;
                {traffic_light_S,pedestrian_light_S}<=6'b1000_10;
                {traffic_light_W,pedestrian_light_W}<=6'b0010_01;
                {traffic_light_E,pedestrian_light_E}<=6'b0010_01;
                 if(day_counter>=2500&&day_counter<3000)begin  //주간 시간의 절반(2.5초)부터 보행자 점멸신호 시작
                        pedestrian_light_N[1]<=0; 
                        pedestrian_light_S[1]<=0;
                    end else if(day_counter>=3500&&day_counter<4000)begin
                        pedestrian_light_N[1]<=1; 
                        pedestrian_light_S[1]<=1;
                    end else if(day_counter>=4000&&day_counter<4500)begin//state변환 1초 전부터 황색 신호 점등 시작
                        pedestrian_light_N[1]<=0; 
                        pedestrian_light_S[1]<=0;
                        traffic_light_W[2]<=1;
                        traffic_light_E[2]<=1;
                        traffic_light_W[1]<=0;
                        traffic_light_E[1]<=0;
                    end else if(day_counter>=4500&&day_counter<5000)begin
                        pedestrian_light_N[1]<=1; 
                        pedestrian_light_S[1]<=1;
                        traffic_light_W[2]<=1;
                        traffic_light_E[2]<=1;
                        traffic_light_W[1]<=0;
                        traffic_light_E[1]<=0;
                    end 
               end    
            
            EM_A:begin
                {traffic_light_N,pedestrian_light_N}<=6'b0010_01;
                {traffic_light_S,pedestrian_light_S}<=6'b0010_01;
                {traffic_light_W,pedestrian_light_W}<=6'b1000_10;
                {traffic_light_E,pedestrian_light_E}<=6'b1000_10;     
            
                if(emergency_counter>=10000&&emergency_counter<10500)begin//10초부터 보행자 점멸신호 시작
                    pedestrian_light_W[1]<=0; 
                    pedestrian_light_E[1]<=0;
                end else if(emergency_counter>=10500&&emergency_counter<11000)begin
                    pedestrian_light_W[1]<=1; 
                    pedestrian_light_E[1]<=1;
                end else if(emergency_counter>=11000&&emergency_counter<11500)begin
                    pedestrian_light_W[1]<=0; 
                    pedestrian_light_E[1]<=0;
                end else if(emergency_counter>=11500&&emergency_counter<12000)begin
                    pedestrian_light_W[1]<=1; 
                    pedestrian_light_E[1]<=1;
                end else if(emergency_counter>=12000&&emergency_counter<12500)begin
                    pedestrian_light_W[1]<=0; 
                    pedestrian_light_E[1]<=0;
                end else if(emergency_counter>=12500&&emergency_counter<13000)begin
                    pedestrian_light_W[1]<=1; 
                    pedestrian_light_E[1]<=1;
                end else if(emergency_counter>=13000&&emergency_counter<13500)begin
                    pedestrian_light_W[1]<=0; 
                    pedestrian_light_E[1]<=0;  
                end else if(emergency_counter>=13500&&emergency_counter<14000)begin
                    pedestrian_light_W[1]<=1; 
                    pedestrian_light_E[1]<=1;
                end else if(emergency_counter>=14000&&emergency_counter<14500)begin
                    pedestrian_light_W[1]<=0; 
                    pedestrian_light_E[1]<=0;   
                end else if(emergency_counter>=14500&&emergency_counter<15000)begin
                    pedestrian_light_W[1]<=1; 
                    pedestrian_light_E[1]<=1;       
                end
            end   
         endcase
    end
end
endmodule