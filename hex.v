module hex(clk,rst,change,price,seg_pi,seg_data);
    input clk;
    input rst;
    input [4:0]price;
    input [4:0]change;
    output [7:0]seg_pi;
    output [7:0]seg_data;


    reg[31:0]time_cnt2;//时间计数器2 用作刷新数码管的时钟
    reg[7:0] wei_cnt_clk;//判断输出哪一个数码管
        //数码管刷新时间 计数
    always@(posedge clk)
    begin 
        if(rst==1'b1)
        begin
            time_cnt2<=32'd0;
        end
        else if(time_cnt2==32'd1_00000)
        begin
            time_cnt2<=32'd0;
            if(wei_cnt_clk==8'd7)
            begin
                wei_cnt_clk<=0;
            end
            else
            begin
                wei_cnt_clk<=wei_cnt_clk+1;
            end
        end
        else
        begin
            time_cnt2<=time_cnt2+32'd1;
        end
    end
    reg[7:0] seg_get_data;//数码管编码后的显示  端选信号
    reg[8:0] seg_pi_data;//片选信号
    reg[7:0] seg_num;//数码管需要显示的数字 
    //数码管显示
    always@(posedge clk)
    begin 	
        if(wei_cnt_clk==8'd0)//如果计时为0 刷新第一个数码管
        begin
            seg_pi_data<=8'b0000_0001;//0代表点亮 选择第一个数码管
           
            seg_num<=change%10;
           
            if(seg_num==8'd0)
            begin
                seg_get_data<=8'b1100_0000;//0的数码管编码
            end
            else if(seg_num==8'd1)
            begin
                seg_get_data<=8'b1111_1001;//1的编码
            end
            else if(seg_num==8'd2)
            begin
                seg_get_data<=8'b1010_0100;
            end
            else if(seg_num==8'd3)
            begin
                seg_get_data<=8'b1011_0000;
            end
            else if(seg_num==8'd4)
            begin
                seg_get_data<=8'b1001_1001;
            end
            else if(seg_num==8'd5)
            begin
                seg_get_data<=8'b1001_0010;
            end
            else if(seg_num==8'd6)
            begin
                seg_get_data<=8'b1000_0010;
            end
            else if(seg_num==8'd7)
            begin
                seg_get_data<=8'b1111_1000;
            end
            else if(seg_num==8'd8)
            begin
                seg_get_data<=8'b1000_0000;
            end
            else if(seg_num==8'd9)
            begin
                seg_get_data<=8'b1001_0000;
            end
            else if(seg_num==8'd10)
            begin
                seg_get_data<=8'b1000_1000;
            end
            else if(seg_num==8'd11)
            begin
                seg_get_data<=8'b1000_0011;
            end
            else if(seg_num==8'd12)
            begin
                seg_get_data<=8'b1100_0110;
            end
            else if(seg_num==8'd13)
            begin
                seg_get_data<=8'b1010_0001;
            end
            else if(seg_num==8'd14)
            begin
                seg_get_data<=8'b1000_0110;
            end
            else if(seg_num==8'd15)
            begin
                seg_get_data<=8'b1000_1110;
            end
        end
        else if(wei_cnt_clk==8'd1)
        begin
            seg_pi_data<=8'b0000_0010;//0代表点亮

            seg_num<=change/10%10;


            if(seg_num==8'd0)
            begin
                seg_get_data<=8'b1100_0000;
            end
            else if(seg_num==8'd1)
            begin
                seg_get_data<=8'b1111_1001;
            end
            else if(seg_num==8'd2)
            begin
                seg_get_data<=8'b1010_0100;
            end
            else if(seg_num==8'd3)
            begin
                seg_get_data<=8'b1011_0000;
            end
            else if(seg_num==8'd4)
            begin
                seg_get_data<=8'b1001_1001;
            end
            else if(seg_num==8'd5)
            begin
                seg_get_data<=8'b1001_0010;
            end
            else if(seg_num==8'd6)
            begin
                seg_get_data<=8'b1000_0010;
            end
            else if(seg_num==8'd7)
            begin
                seg_get_data<=8'b1111_1000;
            end
            else if(seg_num==8'd8)
            begin
                seg_get_data<=8'b1000_0000;
            end
            else if(seg_num==8'd9)
            begin
                seg_get_data<=8'b1001_0000;
            end
            else if(seg_num==8'd10)
            begin
                seg_get_data<=8'b1000_1000;
            end
            else if(seg_num==8'd11)
            begin
                seg_get_data<=8'b1000_0011;
            end
            else if(seg_num==8'd12)
            begin
                seg_get_data<=8'b1100_0110;
            end
            else if(seg_num==8'd13)
            begin
                seg_get_data<=8'b1010_0001;
            end
            else if(seg_num==8'd14)
            begin
                seg_get_data<=8'b1000_0110;
            end
            else if(seg_num==8'd15)
            begin
                seg_get_data<=8'b1000_1110;
            end
        end
        else if(wei_cnt_clk==8'd6)
        begin
            seg_pi_data<=8'b0100_0000;//0代表点亮

            seg_num<=price%10;


            if(seg_num==8'd0)
            begin
                seg_get_data<=8'b1100_0000;
            end
            else if(seg_num==8'd1)
            begin
                seg_get_data<=8'b1111_1001;
            end
            else if(seg_num==8'd2)
            begin
                seg_get_data<=8'b1010_0100;
            end
            else if(seg_num==8'd3)
            begin
                seg_get_data<=8'b1011_0000;
            end
            else if(seg_num==8'd4)
            begin
                seg_get_data<=8'b1001_1001;
            end
            else if(seg_num==8'd5)
            begin
                seg_get_data<=8'b1001_0010;
            end
            else if(seg_num==8'd6)
            begin
                seg_get_data<=8'b1000_0010;
            end
            else if(seg_num==8'd7)
            begin
                seg_get_data<=8'b1111_1000;
            end
            else if(seg_num==8'd8)
            begin
                seg_get_data<=8'b1000_0000;
            end
            else if(seg_num==8'd9)
            begin
                seg_get_data<=8'b1001_0000;
            end
            else if(seg_num==8'd10)
            begin
                seg_get_data<=8'b1000_1000;
            end
            else if(seg_num==8'd11)
            begin
                seg_get_data<=8'b1000_0011;
            end
            else if(seg_num==8'd12)
            begin
                seg_get_data<=8'b1100_0110;
            end
            else if(seg_num==8'd13)
            begin
                seg_get_data<=8'b1010_0001;
            end
            else if(seg_num==8'd14)
            begin
                seg_get_data<=8'b1000_0110;
            end
            else if(seg_num==8'd15)
            begin
                seg_get_data<=8'b1000_1110;
            end
        end
		  
		  else if(wei_cnt_clk==8'd7)
        begin
            seg_pi_data<=8'b1000_0000;//0代表点亮

            seg_num<=price/10%10;


            if(seg_num==8'd0)
            begin
                seg_get_data<=8'b1100_0000;
            end
            else if(seg_num==8'd1)
            begin
                seg_get_data<=8'b1111_1001;
            end
            else if(seg_num==8'd2)
            begin
                seg_get_data<=8'b1010_0100;
            end
            else if(seg_num==8'd3)
            begin
                seg_get_data<=8'b1011_0000;
            end
            else if(seg_num==8'd4)
            begin
                seg_get_data<=8'b1001_1001;
            end
            else if(seg_num==8'd5)
            begin
                seg_get_data<=8'b1001_0010;
            end
            else if(seg_num==8'd6)
            begin
                seg_get_data<=8'b1000_0010;
            end
            else if(seg_num==8'd7)
            begin
                seg_get_data<=8'b1111_1000;
            end
            else if(seg_num==8'd8)
            begin
                seg_get_data<=8'b1000_0000;
            end
            else if(seg_num==8'd9)
            begin
                seg_get_data<=8'b1001_0000;
            end
            else if(seg_num==8'd10)
            begin
                seg_get_data<=8'b1000_1000;
            end
            else if(seg_num==8'd11)
            begin
                seg_get_data<=8'b1000_0011;
            end
            else if(seg_num==8'd12)
            begin
                seg_get_data<=8'b1100_0110;
            end
            else if(seg_num==8'd13)
            begin
                seg_get_data<=8'b1010_0001;
            end
            else if(seg_num==8'd14)
            begin
                seg_get_data<=8'b1000_0110;
            end
            else if(seg_num==8'd15)
            begin
                seg_get_data<=8'b1000_1110;
            end
        end
    end
    assign seg_data=~seg_get_data;
    assign seg_pi=~seg_pi_data;
    endmodule