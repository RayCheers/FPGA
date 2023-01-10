`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UESTC
// Engineer: Group 9
// 
// Create Date: 2022/12/20 22:06:46
// Design Name: 
// Module Name: UART
// Project Name: UART analoged by RS232
// Target Devices: NEXYS A7
// Tool Versions: Vivado 2018.3
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_TX
#(
	parameter CLK_FRE = 100    	 	                //时钟频率(MHz)
)
(
	input 				        clk,		        //输入时钟
	input 				        rst_n,			    //复位信号，低电平有效 
    input wire [7:0]            tx_data,            //待发送的数据
	input wire [19:0]		    CYCLE,		        //每bit持续的时钟周期
    input wire                  TX_Vaild,           //发送有效标志位
	output reg      			uart_txd,		    //数据发送引脚
    output reg                  TX_OVER             //数据发送完成标志
);

    localparam                  SEND_FRE = 50;          //数据发送频率(Hz)

    //state machine code
    localparam                  S_IDLE       = 1;      //空闲状态
    localparam                  S_START      = 2;      //起始位状态
    localparam                  S_SEND_BYTE  = 3;      //数据位状态
    localparam                  S_STOP       = 4;      //停止位状态

    reg [2:0]                   state;                 //状态
    reg [2:0]                   next_state;            //下一个状态
    reg [7:0]                   tx_data_latch;         //带发送数据锁存
    //reg [26:0]                  send_fre_cnt;          //发送频率计数器
    reg [15:0]  	            cycle_cnt;    		   //时钟周期计数器
    reg [3:0]  		            bit_cnt;    		   //bit计数器
    reg                         TX_START;              //发送开始标志

    //状态机运转
    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            state <= S_IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    //待发送数据锁存
    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)
            tx_data_latch <= 8'd0;
        else if(state == S_IDLE && TX_Vaild);
            tx_data_latch <= tx_data;
    end
    
    // //send_fre_cnt负责计数发送频率所需时钟周期
	// always @(posedge clk or negedge rst_n)begin
	// 	if(!rst_n)                      //复位时send_fre_cnt清零
	// 		send_fre_cnt <= 0;
	// 	else if(send_fre_cnt == CLK_FRE * 1000_000 / SEND_FRE - 1)begin   //计满时send_fre_cnt清零
	// 		send_fre_cnt <= 0;
    //     end
	// 	else begin              
	// 		send_fre_cnt <= send_fre_cnt+1;         //正常情况下send_fre_cnt正常计数    
    //     end
	// end
    
    //TX_START信号，输入信号有效时开始发送
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            TX_START <= 0;
        else if(TX_Vaild)begin
            TX_START <= 1;
        end
        else begin
            TX_START <= 0;
        end
    end

    //TX_OVER信号，发送结束时持续一个时钟的高电平
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            TX_OVER <= 1;
        else if(state != S_IDLE)begin
            TX_OVER <= 0;
        end
        else begin
            TX_OVER <= 1;
        end
    end

    //发送状态机
    always @(*)begin
        case(state)
            S_IDLE:
                if(TX_START == 1'b1)
                    next_state <= S_START;
                else
                    next_state <= S_IDLE;
            S_START:
                if(cycle_cnt == CYCLE-1)
                    next_state <= S_SEND_BYTE;
                else
                    next_state <= S_START;
            S_SEND_BYTE:
                if(cycle_cnt == CYCLE-1 && bit_cnt == 3'd7)
                    next_state <= S_STOP;
                else
                    next_state <= S_SEND_BYTE;
            S_STOP:
			    if(cycle_cnt == CYCLE - 1)begin
				    next_state <= S_IDLE;
                end
		    	else
				    next_state <= S_STOP;
		    default:
			        next_state <= S_IDLE;    
        endcase
    end
    
    //cycle_cnt负责计数每bit的位宽
    always@(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)
            cycle_cnt <= 16'd0;
        else if((state == S_SEND_BYTE && cycle_cnt == CYCLE - 1) || next_state != state)    //发送数据时开始计数
            cycle_cnt <= 16'd0;
        else
            cycle_cnt <= cycle_cnt + 16'd1;	
    end
    
    //bit_cnt负责计数待发送数据的位数
    always@(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)
            begin
                bit_cnt <= 3'd0;
            end
        else if(state == S_SEND_BYTE)
            if(cycle_cnt == CYCLE - 1)
                bit_cnt <= bit_cnt + 3'd1;
            else
                bit_cnt <= bit_cnt;
        else
            bit_cnt <= 3'd0;
    end

    //装载要发送的数据
    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)
		    uart_txd <= 1'b1;       //空闲为高电平
	    else
            case(state)
                S_IDLE,S_STOP:
                    uart_txd <= 1'b1;
                S_START:
                    uart_txd <= 1'b0;
                S_SEND_BYTE:
                    uart_txd <= tx_data_latch[bit_cnt];
                default:
                    uart_txd <= 1'b1;
            endcase
    end

endmodule
