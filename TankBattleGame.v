module TankBattleGame(
    input clock,
    input reset,
    input l,
    input [9:0] playerControls_b,  // 涓ゅ悕鐜╁鐨勬帶鍒惰緭鍏
    output wire [15:0] data_col,
    output wire [3:0] curr_col,
    output wire [7:0]seg_pi,
    output wire [7:0]seg_data
);
wire [9:0] playerControls;
wire [323:0]point;
reg [255:0]out_point;
reg [323:0]map;
reg [323:0]out;//鍧﹀厠鐐归樀
reg [323:0]out1;
wire [9:0] tank1_position;
wire [9:0] tank2_position;
wire [2:0] tank1_angle;
wire [2:0] tank2_angle;

wire [9:0] bullet1_position;
wire [9:0] bullet2_position;
wire [2:0] bullet1_direction;
wire [2:0] bullet2_direction;
wire bullet1_active;
wire bullet2_active;

wire [4:0]player1_score;
wire [4:0]player2_score;


integer i,j,tank1,tank2,bullet1,bullet2;
map map_obj1(clock,point);
always @(negedge clock)begin
    map<=point;
end

debouncing debouncing_obj1(clock,playerControls_b[0],playerControls[0]);
debouncing debouncing_obj2(clock,playerControls_b[1],playerControls[1]);
debouncing debouncing_obj3(clock,playerControls_b[2],playerControls[2]);
debouncing debouncing_obj4(clock,playerControls_b[3],playerControls[3]);
debouncing debouncing_obj5(clock,playerControls_b[4],playerControls[4]);
debouncing debouncing_obj6(clock,playerControls_b[5],playerControls[5]);
debouncing debouncing_obj7(clock,playerControls_b[6],playerControls[6]);
debouncing debouncing_obj8(clock,playerControls_b[7],playerControls[7]);
debouncing debouncing_obj9(clock,playerControls_b[8],playerControls[8]);
debouncing debouncing_obj10(clock,playerControls_b[9],playerControls[9]);
//杈撳叆妯″潡锛岃緭鍏ヤ负涓や釜鐢ㄦ埛鐨涓緭鍏ユ潵鍒嗗埆鎺у埗鍧﹀厠鐨勫墠杩涖€佸悗閫€銆佹棆杞互鍙婃槸鍚﹀彂灏勫瓙寮癸紝杈撳嚭涓哄垎鍒袱鍙板潶鍏嬬殑浣嶇疆涓庡Э鎬佷袱涓姸鎬佷互鍙婂垎鍒皠鍑虹殑瀛愬脊鐨勪綅缃笌杩愬姩鏂瑰悜涓や釜鐘舵€侊紝褰撳満鏅腑涓€鏋跺潶鍏嬪皠鍑虹殑瀛愬脊鏈秷澶卞墠涓嶈兘鍙戝皠涓嬩竴涓瓙寮
TankGameInput TankGameInput_obj1(clock,reset,!playerControls[0],!playerControls[1],!playerControls[2],!playerControls[3],!playerControls[4],!playerControls[5],!playerControls[6],!playerControls[7],!playerControls[8],!playerControls[9],map,tank1_position,tank2_position,tank1_angle,tank2_angle,bullet1_position,bullet2_position,bullet1_derection,bullet2_derection,bullet1_active,bullet2_active,player1_score,player2_score);
//姝ヨ繘妯″潡锛屽垎棰戣缃瓙寮圭Щ鍔ㄩ€熷害
always @(negedge clock)begin
    out=0;
    tank1=tank1_position;
    tank2=tank2_position;
    bullet1=bullet1_position;
    bullet2=bullet2_position;
    out[tank1]=1;
    out[tank2]=1;
    if (bullet1_active==1)begin
        out[bullet1]=1;
    end
    if (bullet2_active==1)begin
		out[bullet2]=1;
    end
    case (tank1_angle)
        3'b000:begin 
            out[tank1+1]=1;
            out[tank1-1]=1;
            out[tank1-18]=1;
        end
        3'b001:begin 
            out[tank1+1]=1;
            out[tank1-1]=1;
            out[tank1-18+1]=1;
        end
        3'b010:begin 
            out[tank1+18]=1;
            out[tank1-18]=1;
            out[tank1+1]=1;
        end
        3'b011:begin 
            out[tank1+18]=1;
            out[tank1-18]=1;
            out[tank1+1+18]=1;
        end
        3'b100:begin 
            out[tank1+1]=1;
            out[tank1-1]=1;
            out[tank1+18]=1;
        end
        3'b101:begin 
            out[tank1+1]=1;
            out[tank1-1]=1;
            out[tank1+18-1]=1;
        end
        3'b110:begin 
            out[tank1+18]=1;
            out[tank1-18]=1;
            out[tank1-1]=1;
        end
        3'b111:begin 
            out[tank1+18]=1;
            out[tank1-18]=1;
            out[tank1-1-18]=1;
        end
    endcase
    case (tank2_angle)
        3'b000:begin 
            out[tank2+1]=1;
            out[tank2-1]=1;
            out[tank2-18]=1;
        end
        3'b001:begin 
            out[tank2+1]=1;
            out[tank2-1]=1;
            out[tank2-18+1]=1;
        end
        3'b010:begin 
            out[tank2+18]=1;
            out[tank2-18]=1;
            out[tank2+1]=1;
        end
        3'b011:begin 
            out[tank2+18]=1;
            out[tank2-18]=1;
            out[tank2+1+18]=1;
        end
        3'b100:begin 
            out[tank2+1]=1;
            out[tank2-1]=1;
            out[tank2+18]=1;
        end
        3'b101:begin 
            out[tank2+1]=1;
            out[tank2-1]=1;
            out[tank2+18-1]=1;
        end
        3'b110:begin 
            out[tank2+18]=1;
            out[tank2-18]=1;
            out[tank2-1]=1;
        end
        3'b111:begin 
            out[tank2+18]=1;
            out[tank2-18]=1;
            out[tank2-1-18]=1;
        end
    endcase
    end
always@(negedge clock)begin
     out1<=0;
    out1<=out+map;
end
// always@(negedge clock)begin
//     out1<=map;
// end
always @(negedge clock)begin
        out_point <=0;
        for(i=1;i<17;i=i+1)begin
            for(j=1;j<17;j=j+1)begin
            out_point[(i-1)*16+j-1]<=out1[i*18+j];
            end
        end
    end
show  show_obj1(clock, data_col, curr_col,out_point);
hex hex_obj(clock,reset,player1_score,player2_score,seg_pi,seg_data);


endmodule
