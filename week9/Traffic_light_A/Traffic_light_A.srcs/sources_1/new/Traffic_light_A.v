`timescale 1ns / 1ps
module Traffic_light_A(LCD_E,LCD_RS,LCD_RW,LCD_DATA,rst, clk,btn,emergency,scale,traffic_light_N,traffic_light_S,traffic_light_W,traffic_light_E,pedestrian_light_N,pedestrian_light_S,pedestrian_light_W,pedestrian_light_E);

input rst, clk; //reset�� clock
input btn;//1�ð� �߰� ��ư
input emergency;//�������� ��ư
input [1:0] scale;//���� ������ ���� ��ư(DIP����ġ)

output reg[3:0] traffic_light_N;//����  ���� ��ȣ��(��,Ȳ,��,���� ��ȣ ��)
output reg[3:0] traffic_light_S;//���� ���� ��ȣ��
output reg[3:0] traffic_light_W;//���� ���� ��ȣ��
output reg[3:0] traffic_light_E;//���� ���� ��ȣ��
output reg[1:0] pedestrian_light_N;//���� ������ ��ȣ��(��,�� ��)
output reg[1:0] pedestrian_light_S;//���� ������ ��ȣ��
output reg[1:0] pedestrian_light_W;//���� ������ ��ȣ��
output reg[1:0] pedestrian_light_E;//���� ������ ��ȣ��

output LCD_E, LCD_RS, LCD_RW;
output[7:0] LCD_DATA;//LCD ���

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
    EM_A = 4'b1100;//�� state parameter ����

reg[3:0] state;//���� ����
reg[3:0] prev_state;//���� ���� ���
reg prev_day_night;//���� ��/�� ���� ���(��=1,��=0)
reg[31:0] cnt;//�ð� ������ ���� cnt
reg day_night;//���� �Ǵ�(1�̸� �� 0�̸� ��)
reg[31:0] emergency_counter;//�ð� ���� ������ counter(�������)
reg[31:0] day_counter;//�ð� ���� ������ counter(�ְ�)
reg[31:0] night_counter;//�ð� ���� ������ counter(�߰�)

reg [3:0] hours_tens, hours_ones, minutes_tens, minutes_ones, seconds_tens, seconds_ones;
//��,��,�� ǥ��(���� �ڸ�, ���� �ڸ�)_LCD����� ����
wire emergency_t,btn_t;

LCD L1(rst,clk,LCD_E,LCD_RS, LCD_RW, LCD_DATA[7:0], day_night,hours_tens, hours_ones, minutes_tens, minutes_ones, seconds_tens, seconds_ones,state);//LCD ǥ��
oneshot_universal #(.WIDTH(2)) O1(clk,rst,{emergency,btn},{emergency_t,btn_t});//one_shot trigger

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        cnt <= 32'd0;//�ʱ� cnt 0���� ����
        day_night<=0;//�⺻�� ������(00:00:00�� �� �ð� �̹Ƿ�)
        prev_day_night<=day_night;//���� ��/�� ���� ������ �ʱ�ȭ
        hours_tens <= 4'd0;//��(���� �ڸ�) �ʱ�ȭ
        hours_ones <= 4'd0;//��(���� �ڸ�) �ʱ�ȭ
        minutes_tens <= 4'd0;//��(���� �ڸ�) �ʱ�ȭ
        minutes_ones <= 4'd0;//��(���� �ڸ�) �ʱ�ȭ
        seconds_tens <= 4'd0;//��(���� �ڸ�) �ʱ�ȭ
        seconds_ones <= 4'd0;//��(���� �ڸ�) �ʱ�ȭ
 
    end else begin
        if (cnt >= 24 * 60 * 60 * 1000 ) cnt = 0;//�ִ� �ð� �Ѿ��  �ٽ� 00�� 00�� 00�ʷ�
        else if (btn_t) cnt = cnt + 60 * 60 * 1000;// �ð� �߰� ��ư ������ 1�ð� �߰�
       else begin
        case(scale)
            2'b00: cnt=cnt+32'd1;//1�� ���� ��ư�� ������ ���
            2'b01: cnt=cnt+32'd10;//10�� ���� ��ư�� ������ ���
            2'b10: cnt=cnt+32'd100;//100�� ���� ��ư�� ������ ���
            2'b11: cnt=cnt+32'd200;//200�� ���� ��ư�� ������ ���
        endcase
                
        hours_tens <= cnt / 36000000; // �ð��� ���� �ڸ� ����
        hours_ones <= (cnt % 36000000) / 3600000; // �ð��� ���� �ڸ� ����
        minutes_tens <= (cnt % 3600000) / 600000; // ���� ���� �ڸ� ����
        minutes_ones <= (cnt % 600000) / 60000; // ���� ���� �ڸ� ����
        seconds_tens <= (cnt % 60000) / 10000; // ���� ���� �ڸ� ����
        seconds_ones <= (cnt % 10000) / 1000; // ���� ���� �ڸ� ����
        
        prev_day_night<=day_night;//������ �����ϱ� �� ���� ���� ���¸� ���
        if (cnt >= 8 * 60 * 60 *1000 && cnt < 23 * 60 * 60*1000) day_night <= 1;//8�ú��� 23�� ���̴� �ְ�(1)
        else day_night <= 0;// 23�ú��� 8�ô� �߰�(0)
  end
end
end

always @(posedge clk or negedge rst) begin
 if (!rst) begin
    state <= B;//�ʱ� ���� B�� ����(�߰� ����)
    prev_state <= state;//���� ���¸� B�� ���
    emergency_counter <= 0;//������� counter �ʱ�ȭ
    day_counter<=0;//�ְ� counter �ʱ�ȭ
    night_counter<=0;//�߰� counter �ʱ�ȭ
    
end else if (emergency_t&&(state!=EM||state!=EM_A)) begin//������ ��ư�� ���� ��Ȳ
    prev_state = state;//���� ���¸� ���
    state = EM;//EM state�� �Ѿ��
               
end else if (day_night==1) begin  // �ְ� ����
    if(prev_day_night==0)state<=A;//������ �߰����� ���� ��� A���� ���� ����
    else begin 
		case (state)
			A: begin
				if(day_counter>=5000)begin//A state 5�ʰ� ����
					day_counter<=0;//5�� ���� ��� �� counter�� �ʱ�ȭ
					state <= D;//D state�� �̵�
				end else day_counter=day_counter+1;//5�ʰ� ������ ���� ��� counter ����
				end
			D: begin
				if (day_counter >= 5000)begin//D state 5�ʰ� ����
					day_counter<=0;
					state <= F;//F state�� �̵�
				end else day_counter = day_counter + 1;
				end
			F: begin
				if (day_counter >= 5000)begin//F state 5�ʰ� ����
				    day_counter<=0;
				    state <= E;//E state�� �̵�
				end else day_counter = day_counter + 1;
				end
			E: begin
				if (day_counter >= 5000)begin//E state 5�ʰ� ����
				    day_counter<=0;
				    state <= G;//G state�� �̵�
				end else day_counter = day_counter + 1;
				end
			G: begin
				if (day_counter >= 5000)begin//G state  5�ʰ� ����
				    day_counter<=0;
				    state <= EE;//EE state�� �̵�
				end else day_counter = day_counter + 1;
				end
		   EE: begin//�ְ����ۿ��� �� ��ȣ ��ȭ ����Ŭ���� �ι�°�� �����ϴ� E state
			   if (day_counter >= 5000)begin//EE state 5�ʰ� ����
			     day_counter<=0;
			     state <= A;//A state�� �̵�
			   end else day_counter = day_counter + 1;
			   end
            EM: begin//��ư ���� ���� ��ư�� ������ �� A state ��ȯ �� 1�� ����ϴ� state
              if (emergency_counter >= 1000)begin//EM state 1�ʰ� ����
                emergency_counter <= 0;
                state <= EM_A;//EM_A state�� �̵�
            end else emergency_counter = emergency_counter + 1;
            end
            EM_A:begin//��ư ���� ���� ��ư�� ������ 1�ʰ� ������ ��� state A�� �����ϴ� state
            if (emergency_counter >= 15000)begin//EM_A state 15�ʰ� ����
                emergency_counter<=0;
                state <= prev_state;//15�ʰ� ������ ���� state�� ����
            end else emergency_counter = emergency_counter + 1;
            end        
		endcase
		end
		
end else if (day_night == 0) begin  // �߰� ����
        if(prev_day_night==1)state<=B;//������ �߰����� ���� ��� B���� ���� ����
        else begin 
		case (state)
		B: begin
			if (night_counter >= 10000)begin//B state 10�ʰ� ����
			    night_counter<=0;//10�ʰ� ���� ��� �� counter�� �ʱ�ȭ
			    state <= A;//A state�� �̵�
			end else night_counter = night_counter + 1;//10�ʰ� ������ ���� ��� counter ����
			end
		A: begin
			if (night_counter >= 10000)begin//A state 10�ʰ� ����
			    night_counter<=0;
			    state <= C;//C state�� �̵�
			end else night_counter = night_counter + 1;
			end
	   C: begin
		   if (night_counter >= 10000)begin//C state 10�ʰ� ����
			    night_counter<=0;
			    state <= AA;//AA state�� �̵�
		 end else night_counter = night_counter + 1;
		   end
	  AA: begin//�߰����ۿ��� �� ��ȣ ��ȭ ����Ŭ���� �ι�°�� �����ϴ� A state
		  if (night_counter >= 10000)begin//AA state 10�ʰ� ����
			    night_counter<=0;
			    state <= E;//E state�� �̵�
		  end else night_counter = night_counter + 1;
		  end
	  E: begin
		  if (night_counter >= 10000)begin//E state 10�ʰ� ����
			    night_counter<=0;
			    state <= H;//H state�� �̵�
		  end else night_counter = night_counter + 1;
		  end
	 H: begin
		 if (night_counter >= 10000)begin//H state 10�ʰ� ����
			    night_counter<=0;
			    state <= B;//B state�� �̵�
		 end else night_counter = night_counter + 1;
		 end
	EM: begin//��ư ���� ���� ��ư�� ������ �� A state ��ȯ �� 1�� ����ϴ� state(�ְ����۰� ����)
		if (emergency_counter >= 1000)begin//EM state 1�ʰ� ����
			emergency_counter <= 0;
            state <= EM_A;//EM_A state�� �̵�
		end else emergency_counter = emergency_counter + 1;
		end
   EM_A:begin//��ư ���� ���� ��ư�� ������ 1�ʰ� ������ ��� state A�� �����ϴ� state(�ְ����۰� ����)
       if (emergency_counter >= 15000) begin//EM_A state 15�ʰ� ����
           emergency_counter<=0;
           state <= prev_state;//15�ʰ� ������ ���� state�� ����
       end else emergency_counter = emergency_counter + 1;
       end
	endcase
	end
end
end

always @(posedge clk or negedge  rst)
begin
    if(!rst)begin
        {traffic_light_N,pedestrian_light_N}<=6'b0000_00;//���� ��ȣ(��Ȳ�ʿ�_�ʻ�) �ʱ�ȭ
        {traffic_light_S,pedestrian_light_S}<=6'b0000_00;//���� ��ȣ(��Ȳ�ʿ�_�ʻ�) �ʱ�ȭ
        {traffic_light_W,pedestrian_light_W}<=6'b0000_00;//���� ��ȣ(��Ȳ�ʿ�_�ʻ�) �ʱ�ȭ
        {traffic_light_E,pedestrian_light_E}<=6'b0000_00;//���� ��ȣ(��Ȳ�ʿ�_�ʻ�) �ʱ�ȭ
        end
    else begin
        case(state)
            A:begin
                {traffic_light_N,pedestrian_light_N}<=6'b0010_01;
                {traffic_light_S,pedestrian_light_S}<=6'b0010_01;
                {traffic_light_W,pedestrian_light_W}<=6'b1000_10;
                {traffic_light_E,pedestrian_light_E}<=6'b1000_10;     
                if(!day_night) begin//�߰� ���۽�
                    if(night_counter>=5000&&night_counter<5500)begin//�߰� �ð��� ����(5��)���� ������ �����ȣ ����
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
                    end else if(night_counter>=9000&&night_counter<9500)begin//state��ȯ 1�� ������ Ȳ�� ��ȣ ���� ����
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
                end else if(day_night) begin//�ְ� ���۽�
                    if(day_counter>=2500&&day_counter<3000)begin //�ְ� �ð��� ����(2.5��)���� ������ �����ȣ ����
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
                    if(night_counter>=5000&&night_counter<5500)begin //�߰� �ð��� ����(5��)���� ������ �����ȣ ����
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
                    end else if(night_counter>=9000&&night_counter<9500)begin//state��ȯ 1�� ������ Ȳ�� ��ȣ ���� ����
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
                    if(night_counter>=5000&&night_counter<5500)begin //�߰� �ð��� ����(5��)���� ������ �����ȣ ����
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
                    end else if(night_counter>=9000&&night_counter<9500)begin//state��ȯ 1�� ������ Ȳ�� ��ȣ ���� ����
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
                if (day_counter >= 4000)begin//state��ȯ 1�� ������ Ȳ�� ��ȣ ���� ����
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
          if(!day_night) begin//�߰� ���۽�
                    if(night_counter>=5000&&night_counter<5500)begin //�߰� �ð��� ����(5��)���� ������ �����ȣ ����
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
                end else if(day_night) begin//�ְ� ���۽�
                    if(day_counter>=2500&&day_counter<3000)begin  //�ְ� �ð��� ����(2.5��)���� ������ �����ȣ ����
                        pedestrian_light_N[1]<=0; 
                        pedestrian_light_S[1]<=0;
                    end else if(day_counter>=3500&&day_counter<4000)begin
                        pedestrian_light_N[1]<=1; 
                        pedestrian_light_S[1]<=1;
                    end else if(day_counter>=4000&&day_counter<4500)begin//state��ȯ 1�� ������ Ȳ�� ��ȣ ���� ����
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
                    if(day_counter>=2500&&day_counter<3000)begin  //�ְ� �ð��� ����(2.5��)���� ������ �����ȣ ����
                        pedestrian_light_N[1]<=0; 
                    end else if(day_counter>=3500&&day_counter<4000)begin
                        pedestrian_light_N[1]<=1; 
                    end else if(day_counter>=4000&&day_counter<4500)begin//state��ȯ 1�� ������ Ȳ�� ��ȣ ���� ����
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
                 if(day_counter>=2500&&day_counter<3000)begin  //�ְ� �ð��� ����(2.5��)���� ������ �����ȣ ����
                        pedestrian_light_S[1]<=0; 
                    end else if(day_counter>=3500&&day_counter<4000)begin
                        pedestrian_light_S[1]<=1; 
                    end else if(day_counter>=4000&&day_counter<4500)begin//state��ȯ 1�� ������ Ȳ�� ��ȣ ���� ����
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
                if(night_counter>=9000)begin//state��ȯ 1�� ������ Ȳ�� ��ȣ ���� ����
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
                  if(night_counter>=5000&&night_counter<5500)begin //�߰� �ð��� ����(5��)���� ������ �����ȣ ����
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
                    end else if(night_counter>=9000&&night_counter<9500)begin//state��ȯ 1�� ������ Ȳ�� ��ȣ ���� ����
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
                 if(day_counter>=2500&&day_counter<3000)begin  //�ְ� �ð��� ����(2.5��)���� ������ �����ȣ ����
                        pedestrian_light_N[1]<=0; 
                        pedestrian_light_S[1]<=0;
                    end else if(day_counter>=3500&&day_counter<4000)begin
                        pedestrian_light_N[1]<=1; 
                        pedestrian_light_S[1]<=1;
                    end else if(day_counter>=4000&&day_counter<4500)begin//state��ȯ 1�� ������ Ȳ�� ��ȣ ���� ����
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
            
                if(emergency_counter>=10000&&emergency_counter<10500)begin//10�ʺ��� ������ �����ȣ ����
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