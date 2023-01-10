`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/24 18:21:03
// Design Name: 
// Module Name: SegmentDisplay
// Project Name: 
// Target Devices: NEXYS A7
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SegmentDisplay
#(
	parameter CLK_FRE = 100,    	 	    //clock frequency(MHz)
	parameter REFRESH_TIME = 1	 		    //resresh frequency for every single segment(ms)
)
(
	input 				    clk,			//clock input
	input 				    rst_n,			//asynchronous reset input, low active 
    input  wire[7:0]        data,           //8位待显示二进制数
    //input  wire[19:0]       BAUD_RATE,       //8位待显示十进制数
	output reg [7:0] 	    seg_cs,		    //control device
    output reg [7:0]        seg_ment
);
    
    localparam              CYCLE = CLK_FRE * 1000 * REFRESH_TIME;
    parameter               Dig_0 = 8'b0000_0011, Dig_1 = 8'b1001_1111, Dig_2 = 8'b0010_0101,
                            Dig_3 = 8'b0000_1101, Dig_4 = 8'b1001_1001, Dig_5 = 8'b0100_1001,
                            Dig_6 = 8'b0100_0001, Dig_7 = 8'b0001_1111, Dig_8 = 8'b0000_0001,
                            Dig_9 = 8'b0000_1001;       //放置0-9十位数字

    reg  [30:0]  		    cycle_cnt;    			 //cycle_cnt需要14位(100 000)
	reg  [2:0]  			seg_cnt;  		 	     //seg_cnt最大为8，需要3位
    reg [7:0]               display[0:7];            //数码管显示信号
	wire 				    add_cycle_cnt;					
	wire 				    end_cycle_cnt;           //cycle_cnt计数结束标志
	wire 				    add_seg_cnt;					
	wire 				    end_seg_cnt;             //seg_cnt计数结束标志
    
    //显示接收到的数据(0和1的形式)
    always @(posedge clk)begin
        case(data[0])
            1'b0: display[0] <= Dig_0;
            1'b1: display[0] <= Dig_1;
        endcase
        case(data[1])
            1'b0: display[1] <= Dig_0;
            1'b1: display[1] <= Dig_1;
        endcase
        case(data[2])
            1'b0: display[2] <= Dig_0;
            1'b1: display[2] <= Dig_1;
        endcase
        case(data[3])
            1'b0: display[3] <= Dig_0;
            1'b1: display[3] <= Dig_1;
        endcase
        case(data[4])
            1'b0: display[4] <= Dig_0;
            1'b1: display[4] <= Dig_1;
        endcase
        case(data[5])
            1'b0: display[5] <= Dig_0;
            1'b1: display[5] <= Dig_1;
        endcase
        case(data[6])
            1'b0: display[6] <= Dig_0;
            1'b1: display[6] <= Dig_1;
        endcase
        case(data[7])
            1'b0: display[7] <= Dig_0;
            1'b1: display[7] <= Dig_1;
        endcase
    end
    
    // 将待显示数字与数码管连接
    // 显示波特率
    // integer dig_data = BAUD_RATE;
    // localparam dig_data_0 = dig_data % 10;
    // localparam dig_data_1 = (dig_data - dig_data_0)/10 % 10;
    // localparam dig_data_2 = (dig_data - dig_data_0 - dig_data_1*10)/100 % 10;
    // localparam dig_data_3 = (dig_data - dig_data_0 - dig_data_1*10-dig_data_2*100)/1000 % 10;
    // localparam dig_data_4 = (dig_data - dig_data_0 - dig_data_1*10-dig_data_2*100-dig_data_3*1000)/10000 % 10;
    // localparam dig_data_5 = (dig_data - dig_data_0 - dig_data_1*10-dig_data_2*100-dig_data_3*1000-dig_data_4*10000)/100000 % 10;
    // localparam dig_data_6 = (dig_data - dig_data_0 - dig_data_1*10-dig_data_2*100-dig_data_3*1000-dig_data_4*10000-dig_data_5*100000)/1000000 % 10;
    // localparam dig_data_7 = (dig_data - dig_data_0 - dig_data_1*10-dig_data_2*100-dig_data_3*1000-dig_data_4*10000-dig_data_5*100000-dig_data_6*1000000)/10000000 % 10;
    // always @(posedge clk)begin
    //     case(dig_data_0)
    //         4'd0: display[0] <= Dig_0;
    //         4'd1: display[0] <= Dig_1;
    //         4'd2: display[0] <= Dig_2;
    //         4'd3: display[0] <= Dig_3;
    //         4'd4: display[0] <= Dig_4;
    //         4'd5: display[0] <= Dig_5;
    //         4'd6: display[0] <= Dig_6;
    //         4'd7: display[0] <= Dig_7;
    //         4'd8: display[0] <= Dig_8;
    //         4'd9: display[0] <= Dig_9;
    //     endcase
    //     case(dig_data_1)
    //         4'd0: display[1] <= Dig_0;
    //         4'd1: display[1] <= Dig_1;
    //         4'd2: display[1] <= Dig_2;
    //         4'd3: display[1] <= Dig_3;
    //         4'd4: display[1] <= Dig_4;
    //         4'd5: display[1] <= Dig_5;
    //         4'd6: display[1] <= Dig_6;
    //         4'd7: display[1] <= Dig_7;
    //         4'd8: display[1] <= Dig_8;
    //         4'd9: display[1] <= Dig_9;
    //     endcase
    //     case(dig_data_2)
    //         4'd0: display[2] <= Dig_0;
    //         4'd1: display[2] <= Dig_1;
    //         4'd2: display[2] <= Dig_2;
    //         4'd3: display[2] <= Dig_3;
    //         4'd4: display[2] <= Dig_4;
    //         4'd5: display[2] <= Dig_5;
    //         4'd6: display[2] <= Dig_6;
    //         4'd7: display[2] <= Dig_7;
    //         4'd8: display[2] <= Dig_8;
    //         4'd9: display[2] <= Dig_9;
    //     endcase
    //     case(dig_data_3)
    //         4'd0: display[3] <= Dig_0;
    //         4'd1: display[3] <= Dig_1;
    //         4'd2: display[3] <= Dig_2;
    //         4'd3: display[3] <= Dig_3;
    //         4'd4: display[3] <= Dig_4;
    //         4'd5: display[3] <= Dig_5;
    //         4'd6: display[3] <= Dig_6;
    //         4'd7: display[3] <= Dig_7;
    //         4'd8: display[3] <= Dig_8;
    //         4'd9: display[3] <= Dig_9;
    //     endcase
    //     case(dig_data_4)
    //         4'd0: display[4] <= Dig_0;
    //         4'd1: display[4] <= Dig_1;
    //         4'd2: display[4] <= Dig_2;
    //         4'd3: display[4] <= Dig_3;
    //         4'd4: display[4] <= Dig_4;
    //         4'd5: display[4] <= Dig_5;
    //         4'd6: display[4] <= Dig_6;
    //         4'd7: display[4] <= Dig_7;
    //         4'd8: display[4] <= Dig_8;
    //         4'd9: display[4] <= Dig_9;
    //     endcase
    //     case(dig_data_5)
    //         4'd0: display[5] <= Dig_0;
    //         4'd1: display[5] <= Dig_1;
    //         4'd2: display[5] <= Dig_2;
    //         4'd3: display[5] <= Dig_3;
    //         4'd4: display[5] <= Dig_4;
    //         4'd5: display[5] <= Dig_5;
    //         4'd6: display[5] <= Dig_6;
    //         4'd7: display[5] <= Dig_7;
    //         4'd8: display[5] <= Dig_8;
    //         4'd9: display[5] <= Dig_9;
    //     endcase
    //     case(dig_data_6)
    //         4'd0: display[6] <= Dig_0;
    //         4'd1: display[6] <= Dig_1;
    //         4'd2: display[6] <= Dig_2;
    //         4'd3: display[6] <= Dig_3;
    //         4'd4: display[6] <= Dig_4;
    //         4'd5: display[6] <= Dig_5;
    //         4'd6: display[6] <= Dig_6;
    //         4'd7: display[6] <= Dig_7;
    //         4'd8: display[6] <= Dig_8;
    //         4'd9: display[6] <= Dig_9;
    //     endcase
    //     case(dig_data_7)
    //         4'd0: display[7] <= Dig_0;
    //         4'd1: display[7] <= Dig_1;
    //         4'd2: display[7] <= Dig_2;
    //         4'd3: display[7] <= Dig_3;
    //         4'd4: display[7] <= Dig_4;
    //         4'd5: display[7] <= Dig_5;
    //         4'd6: display[7] <= Dig_6;
    //         4'd7: display[7] <= Dig_7;
    //         4'd8: display[7] <= Dig_8;
    //         4'd9: display[7] <= Dig_9;
    //     endcase
    // end

    //cycle_cnt负责计数每段亮的持续时间
	always @(posedge clk or negedge rst_n)begin  //在每个时钟沿变化
		if(!rst_n) begin    //复位时cycle_cnt清零
			cycle_cnt <= 0;
		end
		else if (add_cycle_cnt)begin   
			if(end_cycle_cnt)    //计满时cycle_cnt清零
				cycle_cnt <= 0;     
			else            //正常情况下cycle_cnt正常计数
				cycle_cnt <= cycle_cnt+1;
		end
	end
	assign add_cycle_cnt = 1;           
	assign end_cycle_cnt = add_cycle_cnt && cycle_cnt == CYCLE-1;    
	
	//seg_cnt负责计数位数，通过seg_cnt来计数
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) begin   			 //复位时seg_cnt清零
			seg_cnt <= 0;
		end
		else if (add_seg_cnt)begin   
			if(end_seg_cnt)    		//计满时seg_cnt清零
				seg_cnt <= 0;     
			else           		    //正常情况下seg_cnt正常计数
				seg_cnt <= seg_cnt+1;
		end
	end
	assign add_seg_cnt = end_cycle_cnt;            //seg_cnt的加一条件是seg_cnt计满
	assign end_seg_cnt = add_seg_cnt && seg_cnt == 8-1;    //seg_cnt计数8bit，为8次cycle_cnt

    //数码管片选信号
    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)
            seg_cs <= 8'b1111_1111;
        else if(seg_cnt == 3'd0)
            seg_cs <= 8'b0111_1111;
        else if(seg_cnt == 3'd1)
            seg_cs <= 8'b1011_1111;
        else if(seg_cnt == 3'd2)
            seg_cs <= 8'b1101_1111;
        else if(seg_cnt == 3'd3)
            seg_cs <= 8'b1110_1111;
        else if(seg_cnt == 3'd4)
            seg_cs <= 8'b1111_0111;
        else if(seg_cnt == 3'd5)
            seg_cs <= 8'b1111_1011;
        else if(seg_cnt == 3'd6)
            seg_cs <= 8'b1111_1101;
        else if(seg_cnt == 3'd7)
            seg_cs <= 8'b1111_1110;
    end

    //数码管段选信号
    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)
            seg_ment <= 8'b1111_1111;         
        else if(seg_cnt == 3'd0)
            seg_ment <= display[7];         
        else if(seg_cnt == 3'd1)
            seg_ment <= display[6];         
        else if(seg_cnt == 3'd2)
            seg_ment <= display[5];         
        else if(seg_cnt == 3'd3)
            seg_ment <= display[4];         
        else if(seg_cnt == 3'd4)
            seg_ment <= display[3];         
        else if(seg_cnt == 3'd5)
            seg_ment <= display[2];         
        else if(seg_cnt == 3'd6)
            seg_ment <= display[1];         
        else if(seg_cnt == 3'd7)
            seg_ment <= display[0];         
    end

endmodule
