module debouncing
    #(parameter bitwidth=20, parameter delayT=250000)
    (clk_sys, key_b, key);

    input wire clk_sys, key_b;
    output reg key;
    reg [bitwidth-1:0] count = delayT;
    reg already_up = 1'b1;
	 
	always @(negedge clk_sys) begin
        if ((count==delayT)&(~key_b)&(key)) count <= 0;
        if (count<delayT) count <= count + 1'b1;
	end
    always @(negedge clk_sys) begin
        if ((count==delayT-1)&(~key_b)&(already_up)) begin key <= 1'b0; already_up <= 1'b0; end
        if (key_b) already_up <= 1'b1;
        if (~key) key <= 1'b1;
    end
	 
endmodule