
module TankGameInput(
    input wire clk,  // 游戏的时钟信号
    input wire reset,  // 游戏的重置信号
    // 玩家1的控制输入
    input wire p1_forward,
    input wire p1_backward,
    input wire p1_turn_left,
    input wire p1_turn_right,
    input wire p1_shoot,
    // 玩家2的控制输入
    input wire p2_forward,
    input wire p2_backward,
    input wire p2_turn_left,
    input wire p2_turn_right,
    input wire p2_shoot,
    input wire [323:0]array,
    // 输出坦克的位置和姿态
    output wire [9:0] tank1_array,
    output wire [9:0] tank2_array,
    output reg [2:0] tank1_angle,
    output reg [2:0] tank2_angle,
    // 输出子弹的位置和方向
    output wire [9:0] bullet1_array,
    output wire [9:0] bullet2_array,
    output reg [2:0] bullet1_direction,
    output reg [2:0] bullet2_direction,
    // 输出子弹的存在状态
    output reg bullet1_active,
    output reg bullet2_active,
    //输出玩家得分
    output reg [4:0]player1_score,
    output reg [4:0]player2_score
);

reg [4:0] tank1_position[0:1];
reg [4:0] tank2_position[0:1];
reg [4:0] bullet1_position[0:1];
reg [4:0] bullet2_position[0:1];

reg[4:0]newBullet1_position[0:1];
reg[4:0]newBullet2_position[0:1];


reg [17:0] map[0:17];

integer i;
integer j;
always @(*) begin
    for (i = 0; i < 18; i = i + 1) begin
		for (j=0;j<18;j=j+1)begin
			map[j][i] = array[i*18+j];
		  end
    end
end

// 暂时假设坦克和子弹的移动速度是固定的
parameter TANK_SPEED = 1;  // 坦克每次移动的格数
parameter BULLET_SPEED = 1;  // 子弹每次移动的格数

// 坦克的移动方向定义
parameter UP = 3'd0;
parameter UP_right=3'd1;
parameter RIGHT = 3'd2;
parameter RIGHT_right=3'd3;
parameter DOWN = 3'd4;
parameter DOWN_right = 3'd5;
parameter LEFT = 3'd6;
parameter LEFT_right=3'd7;

parameter BULLET_LIFETIME = 1500000000; // 子弹的生存时间计数（以时钟周期为单位）
parameter BULLET_SPEED_DIV = 25000000; // 子弹速度分频器

reg [31:0] bullet1_counter = 0; // 子弹1的生存时间计数器
reg [31:0] bullet2_counter = 0; // 子弹2的生存时间计数器

reg [31:0] bullet1_speed_counter = 0; // 子弹1的速度计数器
reg [31:0] bullet2_speed_counter = 0; // 子弹2的速度计数器


// 初始化坦克和子弹的位置和方向
// initial begin
//     // 设置坦克的初始位置
//     tank1_position[0] = 5'd2;  // X位置
//     tank1_position[1] = 5'd16; // Y位置
//     tank2_position[0] = 5'd15; // X位置
//     tank2_position[1] = 5'd1;  // Y位置
//     // 设置坦克的初始姿态角度（例如，0表示向上，2表示向右）
//     tank1_angle = 3'd0;
//     tank2_angle = 3'd4;

//     // 设置子弹的初始位置为非活动状态
//     bullet1_position[0] = 5'd0;
//     bullet1_position[1] = 5'd0;
//     bullet2_position[0] = 5'd0;
//     bullet2_position[1] = 5'd0;

//     // 设置子弹的初始运动方向
//     bullet1_direction = 3'd0;
//     bullet2_direction = 3'd0;

//     // 设置子弹的活动状态为非活动
//     bullet1_active = 1'b0;
//     bullet2_active = 1'b0;
// end


function can_move;
    input [4:0] new_x;
    input [4:0] new_y;
    input [2:0] angle;
    begin
        // 如果新位置上有墙壁，则返回0，否则返回1
        //can_move = (map[new_y][new_x] == 0);
        case (angle)
            UP, UP_right: // UP_RIGHT和UP_LEFT将沿UP方向移动
                if(map[new_x][new_y]==1||map[new_x+1][new_y]==1||map[new_x-1][new_y]==1||map[new_x-1][new_y-1]==1||map[new_x][new_y-1]==1||map[new_x+1][new_y-1]==1)begin
                    can_move=0;
                end
                else can_move=1;
            RIGHT, RIGHT_right: // DOWN_RIGHT和UP_RIGHT将沿RIGHT方向移动
                if(map[new_x][new_y]==1||map[new_x][new_y-1]==1||map[new_x][new_y+1]==1||map[new_x+1][new_y-1]==1||map[new_x+1][new_y]==1||map[new_x+1][new_y+1]==1)begin
                    can_move=0;
                end
                else can_move=1;    
            DOWN, DOWN_right: // DOWN_RIGHT和DOWN_LEFT将沿DOWN方向移动
                if(map[new_x][new_y]==1||map[new_x+1][new_y]==1||map[new_x-1][new_y]==1||map[new_x-1][new_y+1]==1||map[new_x][new_y+1]==1||map[new_x+1][new_y+1]==1)begin
                    can_move=0;
                end
                else can_move=1;
            LEFT, LEFT_right: // DOWN_LEFT和UP_LEFT将沿LEFT方向移动
                if(map[new_x][new_y]==1||map[new_x][new_y-1]==1||map[new_x][new_y+1]==1||map[new_x-1][new_y-1]==1||map[new_x-1][new_y]==1||map[new_x-1][new_y+1]==1)begin
                    can_move=0;
                end
                else can_move=1;
        endcase
    end
endfunction

function integer hit;
    input [4:0] bullet_x;
    input [4:0] bullet_y;
    input [4:0] tank1_position_x;
    input [4:0] tank1_position_y;
    input [2:0] angle;

    begin
        hit = ((angle == UP || angle == UP_right) && 
               (bullet_x >= tank1_position_x - 1 && bullet_x <= tank1_position_x + 1) &&
               (bullet_y >= tank1_position_y - 1 && bullet_y <= tank1_position_y)) ||
              ((angle == DOWN || angle == DOWN_right) && 
               (bullet_x >= tank1_position_x - 1 && bullet_x <= tank1_position_x + 1) &&
               (bullet_y >= tank1_position_y && bullet_y <= tank1_position_y + 1)) ||
              ((angle == LEFT || angle == LEFT_right) && 
               (bullet_x >= tank1_position_x - 1 && bullet_x <= tank1_position_x) &&
               (bullet_y >= tank1_position_y - 1 && bullet_y <= tank1_position_y + 1)) ||
              ((angle == RIGHT || angle == RIGHT_right) && 
               (bullet_x >= tank1_position_x && bullet_x <= tank1_position_x + 1) &&
               (bullet_y >= tank1_position_y - 1 && bullet_y <= tank1_position_y + 1));
    end
endfunction



// 检测子弹是否会撞到墙壁的函数
function will_hit_wall;
    input [4:0] new_x;
    input [4:0] new_y;
    begin
        // 如果下一个位置上有墙壁，则返回1，否则返回0
        will_hit_wall = (map[new_x][new_y] == 1);
    end
endfunction

// 子弹反射逻辑的函数
function [2:0] reflect_bullet;
    input [4:0] b_x;
    input [4:0] b_y;
    input [2:0] direction;
    reg vertical_wall, horizontal_wall, corner;
    begin
        // 判断墙壁类型
        vertical_wall = (map[b_x][b_y-1] == 1 || map[b_x][b_y+1] == 1);
        horizontal_wall = (map[b_x-1][b_y] == 1 || map[b_x+1][b_y] == 1);
        corner = vertical_wall && horizontal_wall; // 同时满足竖墙和横墙

        // 根据子弹方向和墙壁的相对位置来决定新的方向
        if (direction == UP || direction == RIGHT || direction == DOWN || direction == LEFT) begin
            // 直线方向反射
            case (direction)
                UP: reflect_bullet = DOWN;
                RIGHT: reflect_bullet = LEFT;
                DOWN: reflect_bullet = UP;
                LEFT: reflect_bullet = RIGHT;
            endcase
        end else if (corner) begin
            // 拐角反射
            case (direction)
                UP_right: reflect_bullet = DOWN_right;
                RIGHT_right: reflect_bullet = LEFT_right;
                DOWN_right: reflect_bullet = UP_right;
                LEFT_right: reflect_bullet = RIGHT_right;
            endcase
        end else if (vertical_wall) begin
            // 竖墙反射
            case (direction)
                UP_right: reflect_bullet = LEFT_right;
                RIGHT_right: reflect_bullet = DOWN_right;
                DOWN_right: reflect_bullet = RIGHT_right;
                LEFT_right: reflect_bullet = UP_right;
            endcase
        end else if (horizontal_wall) begin
            // 横墙反射
            case (direction)
                UP_right: reflect_bullet = RIGHT_right;
                RIGHT_right: reflect_bullet = UP_right;
                DOWN_right: reflect_bullet = LEFT_right;
                LEFT_right: reflect_bullet = DOWN_right;
            endcase
        end else begin
            // 其他情况，保持原方向
            reflect_bullet = direction;
        end
    end
endfunction




// 玩家控制逻辑
always @(posedge clk) begin
    if (reset) begin
        // 重置坦克和子弹的位置和方向
        // 重置子弹1的状态
        bullet1_active <= 0;
        bullet1_position[0] <= 0; // 初始化X坐标
        bullet1_position[1] <= 0; // 初始化Y坐标
        bullet1_direction <= 0;
        bullet1_counter <= 0;
        bullet1_speed_counter <= 0;
		  
        // 重置子弹2的状态
        bullet2_active <= 0;
        bullet2_position[0] <= 0; // 初始化X坐标
        bullet2_position[1] <= 0; // 初始化Y坐标
        bullet2_direction <= 0;
        bullet2_counter <= 0;
        bullet2_speed_counter <= 0;

        // 重置玩家得分
        player1_score <= 0;
        player2_score <= 0;

        // 重置其他需要重置的状态
        // 重置坦克1的位置
        tank1_position[0] <= 2; // 设置tank1的初始X坐标
        tank1_position[1] <= 16; // 设置tank1的初始Y坐标
        tank1_angle<=0;

        // 重置坦克2的位置
        tank2_position[0] <= 15; // 设置tank2的初始X坐标
        tank2_position[1] <= 1; // 设置tank2的初始Y坐标
        tank2_angle<=4;
    end else begin
        // 玩家1的坦克控制
        // 前进逻辑
        case (tank1_angle)
            UP, UP_right: // UP_RIGHT和UP_LEFT将沿UP方向移动
                if (p1_forward && can_move(tank1_position[0], tank1_position[1] - TANK_SPEED,tank1_angle)) begin
                    tank1_position[1] <= tank1_position[1] - TANK_SPEED; // 向上移动
                end else if (p1_backward && can_move(tank1_position[0], tank1_position[1] + TANK_SPEED,tank1_angle)) begin
                    tank1_position[1] <= tank1_position[1] + TANK_SPEED; // 向下移动
                end
            DOWN, DOWN_right: // DOWN_RIGHT和DOWN_LEFT将沿DOWN方向移动
                if (p1_forward && can_move(tank1_position[0], tank1_position[1] + TANK_SPEED,tank1_angle)) begin
                    tank1_position[1] <= tank1_position[1] + TANK_SPEED; // 向下移动
                end else if (p1_backward && can_move(tank1_position[0], tank1_position[1] - TANK_SPEED,tank1_angle)) begin
                    tank1_position[1] <= tank1_position[1] - TANK_SPEED; // 向上移动
                end
            LEFT, LEFT_right: // DOWN_LEFT和UP_LEFT将沿LEFT方向移动
                if (p1_forward && can_move(tank1_position[0] - TANK_SPEED, tank1_position[1],tank1_angle)) begin
                    tank1_position[0] <= tank1_position[0] - TANK_SPEED; // 向左移动
                end else if (p1_backward && can_move(tank1_position[0] + TANK_SPEED, tank1_position[1],tank1_angle)) begin
                    tank1_position[0] <= tank1_position[0] + TANK_SPEED; // 向右移动
                end
            RIGHT, RIGHT_right: // DOWN_RIGHT和UP_RIGHT将沿RIGHT方向移动
                if (p1_forward && can_move(tank1_position[0] + TANK_SPEED, tank1_position[1],tank1_angle)) begin
                    tank1_position[0] <= tank1_position[0] + TANK_SPEED; // 向右移动
                end else if (p1_backward && can_move(tank1_position[0] - TANK_SPEED, tank1_position[1],tank1_angle)) begin
                    tank1_position[0] <= tank1_position[0] - TANK_SPEED; // 向左移动
                end
        endcase
        
        // 旋转逻辑（未改变）
        if (p1_turn_left && can_move(tank1_position[0],tank1_position[1],(tank1_angle - 1'b1) % 8)) begin
            tank1_angle <= (tank1_angle - 1'b1) % 8; // 假设角度0-7循环
        end

        if (p1_turn_right && can_move(tank1_position[0],tank1_position[1],(tank1_angle + 1'b1) % 8)) begin
            tank1_angle <= (tank1_angle + 1'b1) % 8;
        end

        


        // ...处理射击逻辑...
        // ...处理玩家2的控制逻辑...
         case (tank2_angle)
            UP, UP_right: // UP_RIGHT将沿UP方向移动
                if (p2_forward && can_move(tank2_position[0], tank2_position[1] - TANK_SPEED, tank2_angle)) begin
                    tank2_position[1] <= tank2_position[1] - TANK_SPEED; // 向上移动
                end else if (p2_backward && can_move(tank2_position[0], tank2_position[1] + TANK_SPEED, tank2_angle)) begin
                    tank2_position[1] <= tank2_position[1] + TANK_SPEED; // 向下移动
                end
            DOWN, DOWN_right: // DOWN_RIGHT将沿DOWN方向移动
                if (p2_forward && can_move(tank2_position[0], tank2_position[1] + TANK_SPEED, tank2_angle)) begin
                    tank2_position[1] <= tank2_position[1] + TANK_SPEED; // 向下移动
                end else if (p2_backward && can_move(tank2_position[0], tank2_position[1] - TANK_SPEED, tank2_angle)) begin
                    tank2_position[1] <= tank2_position[1] - TANK_SPEED; // 向上移动
                end
            LEFT, LEFT_right: // LEFT_RIGHT将沿LEFT方向移动
                if (p2_forward && can_move(tank2_position[0] - TANK_SPEED, tank2_position[1], tank2_angle)) begin
                    tank2_position[0] <= tank2_position[0] - TANK_SPEED; // 向左移动
                end else if (p2_backward && can_move(tank2_position[0] + TANK_SPEED, tank2_position[1], tank2_angle)) begin
                    tank2_position[0] <= tank2_position[0] + TANK_SPEED; // 向右移动
                end
            RIGHT, RIGHT_right: // RIGHT_RIGHT将沿RIGHT方向移动
                if (p2_forward && can_move(tank2_position[0] + TANK_SPEED, tank2_position[1], tank2_angle)) begin
                    tank2_position[0] <= tank2_position[0] + TANK_SPEED; // 向右移动
                end else if (p2_backward && can_move(tank2_position[0] - TANK_SPEED, tank2_position[1], tank2_angle)) begin
                    tank2_position[0] <= tank2_position[0] - TANK_SPEED; // 向左移动
                end
        endcase
        
        // 玩家2的坦克旋转逻辑
        if (p2_turn_left && can_move(tank2_position[0], tank2_position[1], (tank2_angle - 1'b1) % 8)) begin
            tank2_angle <= (tank2_angle - 1'b1) % 8; // 假设角度0-7循环
        end
        if (p2_turn_right && can_move(tank2_position[0], tank2_position[1], (tank2_angle + 1'b1) % 8)) begin
            tank2_angle <= (tank2_angle + 1'b1) % 8;
        end


        // 玩家1的射击逻辑
        // 玩家1的射击逻辑
        if (p1_shoot && !bullet1_active) begin
            bullet1_active <= 1'b1; // 激活子弹
            bullet1_direction <= tank1_angle; // 子弹方向与坦克方向相同
            // 设置子弹初始位置为坦克炮管前方
            case(tank1_angle)
                UP: begin
                    bullet1_position[0] <= tank1_position[0]; 
                    bullet1_position[1] <= tank1_position[1] - 2;
                end
                UP_right: begin
                    bullet1_position[0] <= tank1_position[0] + 2; 
                    bullet1_position[1] <= tank1_position[1] - 2;
                end
                RIGHT: begin
                    bullet1_position[0] <= tank1_position[0] + 2; 
                    bullet1_position[1] <= tank1_position[1];
                end
                RIGHT_right: begin
                    bullet1_position[0] <= tank1_position[0] + 2; 
                    bullet1_position[1] <= tank1_position[1] + 2;
                end
                DOWN: begin
                    bullet1_position[0] <= tank1_position[0]; 
                    bullet1_position[1] <= tank1_position[1] + 2;
                end
                DOWN_right: begin
                    bullet1_position[0] <= tank1_position[0] - 2; 
                    bullet1_position[1] <= tank1_position[1] + 2;
                end
                LEFT: begin
                    bullet1_position[0] <= tank1_position[0] - 2; 
                    bullet1_position[1] <= tank1_position[1];
                end
                LEFT_right: begin
                    bullet1_position[0] <= tank1_position[0] - 2; 
                    bullet1_position[1] <= tank1_position[1] - 2;
                end
            endcase
        end

			
			
        // 子弹1的运动逻辑
        if (bullet1_active) begin
            bullet1_counter <= bullet1_counter + 1;
            bullet1_speed_counter <= bullet1_speed_counter + 1;

            // 检查子弹是否达到最大生存时间
            if (bullet1_counter >= BULLET_LIFETIME) begin
                bullet1_active <= 0; // 停用子弹
                bullet1_counter <= 0; // 重置生存时间计数器
            end else if ((bullet1_speed_counter >= BULLET_SPEED_DIV)) begin
                bullet1_speed_counter <= 0; // 重置速度计数器
					
                
				

                // 检查是否撞到墙壁并处理反弹
                if (will_hit_wall(newBullet1_position[0], newBullet1_position[1])) begin
							// 如果新位置会撞墙，更新子弹方向
							bullet1_direction <= reflect_bullet(newBullet1_position[0], newBullet1_position[1], bullet1_direction);
					  end else begin
							// 如果新位置不会撞墙，更新子弹位置到新位置
							bullet1_position[0] <= newBullet1_position[0];
							bullet1_position[1] <= newBullet1_position[1];
					  end

                // 检查是否击中敌方坦克
                // ... 敌方坦克碰撞逻辑 ...
                if (hit(bullet1_position[0],bullet1_position[1],tank1_position[0],tank1_position[1],tank1_angle)) begin
                    bullet1_active <= 0; // 停用子弹
                    // 执行击中坦克的额外逻辑，比如增加玩家1的分数
                    player2_score <= player2_score + 1;
                    //reset
                    bullet1_active <= 0;
                    bullet1_position[0] <= 0; // 初始化X坐标
                    bullet1_position[1] <= 0; // 初始化Y坐标
                    bullet1_direction <= 0;
                    bullet1_counter <= 0;
                    bullet1_speed_counter <= 0;

                    // 重置子弹2的状态
                    bullet2_active <= 0;
                    bullet2_position[0] <= 0; // 初始化X坐标
                    bullet2_position[1] <= 0; // 初始化Y坐标
                    bullet2_direction <= 0;
                    bullet2_counter <= 0;
                    bullet2_speed_counter <= 0;

                    // 重置其他需要重置的状态
                    // 重置坦克1的位置
                    tank1_position[0] <= 2; // 设置tank1的初始X坐标
                    tank1_position[1] <= 16; // 设置tank1的初始Y坐标
                    tank1_angle<=0;

                    // 重置坦克2的位置
                    tank2_position[0] <= 15; // 设置tank2的初始X坐标
                    tank2_position[1] <= 1; // 设置tank2的初始Y坐标
                    tank2_angle<=4;

                end else if(hit(bullet1_position[0],bullet1_position[1],tank2_position[0],tank2_position[1],tank2_angle)) begin
                    bullet2_active<=0;
                    player1_score<=player1_score+1;
                    //reset
                    //reset
                    bullet1_active <= 0;
                    bullet1_position[0] <= 0; // 初始化X坐标
                    bullet1_position[1] <= 0; // 初始化Y坐标
                    bullet1_direction <= 0;
                    bullet1_counter <= 0;
                    bullet1_speed_counter <= 0;

                    // 重置子弹2的状态
                    bullet2_active <= 0;
                    bullet2_position[0] <= 0; // 初始化X坐标
                    bullet2_position[1] <= 0; // 初始化Y坐标
                    bullet2_direction <= 0;
                    bullet2_counter <= 0;
                    bullet2_speed_counter <= 0;
                    
                    // 重置其他需要重置的状态
                    // 重置坦克1的位置
                    tank1_position[0] <= 2; // 设置tank1的初始X坐标
                    tank1_position[1] <= 16; // 设置tank1的初始Y坐标
                    tank1_angle<=0;

                    // 重置坦克2的位置
                    tank2_position[0] <= 15; // 设置tank2的初始X坐标
                    tank2_position[1] <= 1; // 设置tank2的初始Y坐标
                    tank2_angle<=4;

                end
        end
        end
        


					  // 玩家2的射击逻辑
			if (p2_shoot && !bullet2_active) begin
				 bullet2_active <= 1'b1; // 激活子弹
				 bullet2_direction <= tank2_angle; // 子弹方向与坦克方向相同
				 // 设置子弹初始位置为坦克炮管前方
				 case(tank2_angle)
					  UP: begin
							bullet2_position[0] <= tank2_position[0]; 
							bullet2_position[1] <= tank2_position[1] - 2;
					  end
					  UP_right: begin
							bullet2_position[0] <= tank2_position[0] + 2; 
							bullet2_position[1] <= tank2_position[1] - 2;
					  end
					  RIGHT: begin
							bullet2_position[0] <= tank2_position[0] + 2; 
							bullet2_position[1] <= tank2_position[1];
					  end
					  RIGHT_right: begin
							bullet2_position[0] <= tank2_position[0] + 2; 
							bullet2_position[1] <= tank2_position[1] + 2;
					  end
					  DOWN: begin
							bullet2_position[0] <= tank2_position[0]; 
							bullet2_position[1] <= tank2_position[1] + 2;
					  end
					  DOWN_right: begin
							bullet2_position[0] <= tank2_position[0] - 2; 
							bullet2_position[1] <= tank2_position[1] + 2;
					  end
					  LEFT: begin
							bullet2_position[0] <= tank2_position[0] - 2; 
							bullet2_position[1] <= tank2_position[1];
					  end
					  LEFT_right: begin
							bullet2_position[0] <= tank2_position[0] - 2; 
							bullet2_position[1] <= tank2_position[1] - 2;
					  end
				 endcase
			end

			// 子弹2的运动逻辑
			if (bullet2_active) begin
				 bullet2_counter <= bullet2_counter + 1;
				 bullet2_speed_counter <= bullet2_speed_counter + 1;

				 // 检查子弹是否达到最大生存时间
				 if (bullet2_counter >= BULLET_LIFETIME) begin
					  bullet2_active <= 0; // 停用子弹
					  bullet2_counter <= 0; // 重置生存时间计数器
				 end else if ((bullet2_speed_counter >= BULLET_SPEED_DIV)) begin
					  bullet2_speed_counter <= 0; // 重置速度计数器

					  // 检查是否撞到墙壁并处理反弹
					  if (will_hit_wall(newBullet2_position[0], newBullet2_position[1])) begin
							// 如果新位置会撞墙，更新子弹方向
							bullet2_direction <= reflect_bullet(newBullet2_position[0], newBullet2_position[1], bullet2_direction);
					  end else begin
							// 如果新位置不会撞墙，更新子弹位置到新位置
							bullet2_position[0] <= newBullet2_position[0];
							bullet2_position[1] <= newBullet2_position[1];
					  end

					  // 检查是否击中敌方坦克
					  if (hit(bullet2_position[0], bullet2_position[1], tank1_position[0], tank1_position[1], tank1_angle)) begin
							bullet2_active <= 0; // 停用子弹
							player2_score <= player2_score + 1; // 增加玩家1的得分
							// 重置坦克和子弹的状态
							// ...重置逻辑...
							//reset
                    bullet1_active <= 0;
                    bullet1_position[0] <= 0; // 初始化X坐标
                    bullet1_position[1] <= 0; // 初始化Y坐标
                    bullet1_direction <= 0;
                    bullet1_counter <= 0;
                    bullet1_speed_counter <= 0;

                    // 重置子弹2的状态
                    bullet2_active <= 0;
                    bullet2_position[0] <= 0; // 初始化X坐标
                    bullet2_position[1] <= 0; // 初始化Y坐标
                    bullet2_direction <= 0;
                    bullet2_counter <= 0;
                    bullet2_speed_counter <= 0;

                    // 重置其他需要重置的状态
                    // 重置坦克1的位置
                    tank1_position[0] <= 2; // 设置tank1的初始X坐标
                    tank1_position[1] <= 16; // 设置tank1的初始Y坐标
                    tank1_angle<=0;

                    // 重置坦克2的位置
                    tank2_position[0] <= 15; // 设置tank2的初始X坐标
                    tank2_position[1] <= 1; // 设置tank2的初始Y坐标
                    tank2_angle<=4;
					  end else if(hit(bullet2_position[0], bullet2_position[1], tank2_position[0], tank2_position[1], tank2_angle)) begin
							bullet1_active <= 0; // 停用子弹1
							player1_score <= player1_score + 1; // 增加玩家2的得分
							// 重置坦克和子弹的状态
							//reset
                    bullet1_active <= 0;
                    bullet1_position[0] <= 0; // 初始化X坐标
                    bullet1_position[1] <= 0; // 初始化Y坐标
                    bullet1_direction <= 0;
                    bullet1_counter <= 0;
                    bullet1_speed_counter <= 0;

                    // 重置子弹2的状态
                    bullet2_active <= 0;
                    bullet2_position[0] <= 0; // 初始化X坐标
                    bullet2_position[1] <= 0; // 初始化Y坐标
                    bullet2_direction <= 0;
                    bullet2_counter <= 0;
                    bullet2_speed_counter <= 0;
                    
                    // 重置其他需要重置的状态
                    // 重置坦克1的位置
                    tank1_position[0] <= 2; // 设置tank1的初始X坐标
                    tank1_position[1] <= 16; // 设置tank1的初始Y坐标
                    tank1_angle<=0;

                    // 重置坦克2的位置
                    tank2_position[0] <= 15; // 设置tank2的初始X坐标
                    tank2_position[1] <= 1; // 设置tank2的初始Y坐标
                    tank2_angle<=4;

					  end
				 end
			end


    end
    end
always@(posedge clk)begin
	if(reset)begin
			newBullet1_position[0]<=0;
		  newBullet1_position[1]<=0;
		  newBullet2_position[0]<=0;
		  newBullet2_position[1]<=0;
	end else begin
	// 根据子弹方向更新子弹位置
	
			 case (bullet1_direction)
				  UP:begin
					  //bullet1_position[1] <= bullet1_position[1] - 1;
					  newBullet1_position[0]<=bullet1_position[0] ;
					  newBullet1_position[1]<=bullet1_position[1]-1;
				  end
				  DOWN: begin
						//bullet1_position[1] <= bullet1_position[1] + 1;
						newBullet1_position[0]<=bullet1_position[0]; 
						newBullet1_position[1]<=bullet1_position[1]+1;
				  end
				  LEFT: begin 
						//bullet1_position[0] <= bullet1_position[0] - 1;
						newBullet1_position[0]<=bullet1_position[0]-1 ;
						newBullet1_position[1]<=bullet1_position[1];
						end
				  RIGHT:begin
						//bullet1_position[0] <= bullet1_position[0] + 1;
						newBullet1_position[0]<=bullet1_position[0]+1 ;
						newBullet1_position[1]<=bullet1_position[1];
						end
				  UP_right: begin
						//bullet1_position[0] <= bullet1_position[0] + 1;
						//bullet1_position[1] <= bullet1_position[1] - 1;
						newBullet1_position[0]<=bullet1_position[0]+1 ;
						newBullet1_position[1]<=bullet1_position[1]-1;
				  end
				  RIGHT_right: begin
						//bullet1_position[0] <= bullet1_position[0] + 1;
						//bullet1_position[1] <= bullet1_position[1] + 1;
						newBullet1_position[0]<=bullet1_position[0]+1 ;
						newBullet1_position[1]<=bullet1_position[1]+1;
				  end
				  DOWN_right: begin
						//bullet1_position[0] <= bullet1_position[0] - 1;
						//bullet1_position[1] <= bullet1_position[1] + 1;
						newBullet1_position[0]<=bullet1_position[0]-1 ;
						newBullet1_position[1]<=bullet1_position[1]+1;
				  end
				  LEFT_right: begin
						//bullet1_position[0] <= bullet1_position[0] - 1;
						//bullet1_position[1] <= bullet1_position[1] - 1;
						newBullet1_position[0]<=bullet1_position[0]-1 ;
						newBullet1_position[1]<=bullet1_position[1]-1;
				  end
			 endcase
			 
			 // 根据子弹方向更新子弹位置
              case (bullet2_direction)
				  UP:begin
					  //bullet1_position[1] <= bullet1_position[1] - 1;
					  newBullet2_position[0]<=bullet2_position[0] ;
					  newBullet2_position[1]<=bullet2_position[1]-1;
				  end
				  DOWN: begin
						//bullet1_position[1] <= bullet1_position[1] + 1;
						newBullet2_position[0]<=bullet2_position[0]; 
						newBullet2_position[1]<=bullet2_position[1]+1;
				  end
				  LEFT: begin 
						//bullet1_position[0] <= bullet1_position[0] - 1;
						newBullet2_position[0]<=bullet2_position[0]-1 ;
						newBullet2_position[1]<=bullet2_position[1];
						end
				  RIGHT:begin
						//bullet1_position[0] <= bullet1_position[0] + 1;
						newBullet2_position[0]<=bullet2_position[0]+1 ;
						newBullet2_position[1]<=bullet2_position[1];
						end
				  UP_right: begin
						//bullet1_position[0] <= bullet1_position[0] + 1;
						//bullet1_position[1] <= bullet1_position[1] - 1;
						newBullet2_position[0]<=bullet2_position[0]+1 ;
						newBullet2_position[1]<=bullet2_position[1]-1;
				  end
				  RIGHT_right: begin
						//bullet1_position[0] <= bullet1_position[0] + 1;
						//bullet1_position[1] <= bullet1_position[1] + 1;
						newBullet2_position[0]<=bullet2_position[0]+1 ;
						newBullet2_position[1]<=bullet2_position[1]+1;
				  end
				  DOWN_right: begin
						//bullet1_position[0] <= bullet1_position[0] - 1;
						//bullet1_position[1] <= bullet1_position[1] + 1;
						newBullet2_position[0]<=bullet2_position[0]-1 ;
						newBullet2_position[1]<=bullet2_position[1]+1;
				  end
				  LEFT_right: begin
						//bullet1_position[0] <= bullet1_position[0] - 1;
						//bullet1_position[1] <= bullet1_position[1] - 1;
						newBullet2_position[0]<=bullet2_position[0]-1 ;
						newBullet2_position[1]<=bullet2_position[1]-1;
				  end
			 endcase
			end
end

// 这里还需要添加更多逻辑来处理坦克和子弹的具体移动和旋转，
// 以及子弹的发射和运动。这可能涉及复杂的数学运算，
// 取决于您如何定义坦克和子弹的运动规则。
// ...
assign tank1_array=tank1_position[1]*18+tank1_position[0];
assign tank2_array=tank2_position[1]*18+tank2_position[0];
assign bullet1_array= bullet1_position[1]*18+bullet1_position[0];
assign bullet2_array= bullet2_position[1]*18+bullet2_position[0];


endmodule


