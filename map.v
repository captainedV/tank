module map (clk,point);
    input wire clk;
    output reg [323:0]point;//点亮否的状态
    integer i;
    always@(negedge clk)begin
        point=0;
        for(i=0;i<18;i=i+1)begin
            point[0*18+i]=1;
            point[17*18+i]=1;
        end
        for(i=1;i<17;i=i+1)begin
            point[i*18+0]=1;
            point[i*18+17]=1;
        end
        point[1*18+2]=1;
        point[2*18+2]=1;
        point[3*18+1]=1;
        point[3*18+2]=1;
        point[6*18+7]=1;
        point[6*18+8]=1;
        point[6*18+9]=1;
        point[6*18+10]=1;
        point[6*18+11]=1;
        point[7*18+7]=1;
        point[7*18+11]=1;
        point[8*18+5]=1;
        point[8*18+6]=1;
        point[8*18+7]=1;
        point[8*18+11]=1;
        point[8*18+15]=1;
        point[8*18+16]=1;
        point[9*18+11]=1;
        point[9*18+15]=1;
        point[10*18+15]=1;
        point[11*18+15]=1;
        point[11*18+16]=1;
        point[12*18+5]=1;
        point[12*18+6]=1;
        point[12*18+7]=1;
        point[12*18+8]=1;
        point[12*18+15]=1;
        point[13*18+8]=1;
        point[13*18+9]=1;
        point[13*18+10]=1;
        point[13*18+11]=1;
        point[13*18+15]=1;
        point[14*18+15]=1;
        point[15*18+15]=1;
    end 
endmodule



