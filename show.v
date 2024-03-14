module show (clk_sys, data_col, curr_col1,point);
    input wire clk_sys;
    input wire [255:0]point;
    output reg [15:0] data_col;//数据
    output reg [3:0] curr_col1;//列选
       
        // 480hz分频模块，480=30fps*16col
    reg clk_480 = 1'b0;
    reg [15:0] clk_480_count = 16'd0;
    always @(negedge clk_sys) begin
        if (clk_480_count<16'd52083) clk_480_count <= clk_480_count+1;
        else begin clk_480_count <= 16'b0;
            clk_480 <= ~clk_480;
        end
    end

    // 2Khz分频模块
    reg clk_2K = 1'b0;
    reg [15:0] clk_2K_count = 16'd0;
    always @(negedge clk_sys) begin
        if (clk_2K_count<16'd12500) clk_2K_count <= clk_2K_count+1;
        else begin clk_2K_count <= 16'b0;
            clk_2K <= ~clk_2K;
        end
    end
    
    reg [3:0]curr_col = 0;
    always @(negedge clk_2K)  begin
        if(curr_col == 4'b1111) curr_col <= 4'b0000;
        else begin
            curr_col <= curr_col +1;
        end
    end  
   
    // always @(*)begin
    //       data_col[0]<=point[0*16+curr_col];
    //       data_col[1]<=point[1*16+curr_col];
    //       data_col[2]<=point[2*16+curr_col];
    //       data_col[3]<=point[3*16+curr_col];
    //       data_col[4]<=point[4*16+curr_col];
    //       data_col[5]<=point[5*16+curr_col];
    //       data_col[6]<=point[6*16+curr_col];
    //       data_col[7]<=point[7*16+curr_col];
    //       data_col[8]<=point[8*16+curr_col];
    //       data_col[9]<=point[9*16+curr_col];
    //       data_col[10]<=point[10*16+curr_col];
    //       data_col[11]<=point[11*16+curr_col];
    //       data_col[12]<=point[12*16+curr_col];
    //       data_col[13]<=point[13*16+curr_col];
    //       data_col[14]<=point[14*16+curr_col];
    //       data_col[15]<=point[15*16+curr_col];
    //       curr_col1 <= curr_col;
    // end
    always @(*)begin
            data_col[0]<=point[15*16+curr_col];
            data_col[1]<=point[14*16+curr_col];
            data_col[2]<=point[13*16+curr_col];
            data_col[3]<=point[12*16+curr_col];
            data_col[4]<=point[11*16+curr_col];
            data_col[5]<=point[10*16+curr_col];
            data_col[6]<=point[9*16+curr_col];
            data_col[7]<=point[8*16+curr_col];
            data_col[8]<=point[7*16+curr_col];
            data_col[9]<=point[6*16+curr_col];
            data_col[10]<=point[5*16+curr_col];
            data_col[11]<=point[4*16+curr_col];
            data_col[12]<=point[3*16+curr_col];
            data_col[13]<=point[2*16+curr_col];
            data_col[14]<=point[1*16+curr_col];
            data_col[15]<=point[0*16+curr_col];
            curr_col1 <= curr_col;
        end
   


endmodule