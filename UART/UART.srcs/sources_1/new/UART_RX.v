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


module UART_RX
#(
	parameter CLK_FRE = 100	 			 			//时钟频率(MHz)
)
(
	input 				        clk,		        //输入时钟
	input 				        rst_n,			    //复位信号，低电平有效 
	input 						uart_rxd,			//数据输入引脚
	input wire[19:0]			CYCLE,				//每bit持续的时钟周期
	output reg [7:0] 			rx_data,			//接受到的
	output reg 					RX_Vaild = 0		//接收完成标志位
);

	reg 						uart_rxd_ff0;		
	reg 						uart_rxd_ff1;
	reg 						uart_rxd_ff2;
	reg 						rx_start;			//开始接收标志位
	reg [19:0]  				cycle_cnt;    		//时钟周期计数器
	reg [3:0]  					bit_cnt;  		 	//bit计数器
	wire 						neg_edge;			//下降沿
	wire 						pos_edge;			//上升沿
	
	//uart_rxd边沿检测
	always @(posedge clk or negedge rst_n)begin
		if(rst_n == 1'b0)begin
			uart_rxd_ff0 <= 1;				
			uart_rxd_ff1 <= 1;              //空闲时uart_rxd为高电平
			uart_rxd_ff2 <= 1;
		end
		else begin
			uart_rxd_ff0 <= uart_rxd;
			uart_rxd_ff1 <= uart_rxd_ff0;
			uart_rxd_ff2 <= uart_rxd_ff1;
		end
	end
	assign neg_edge = uart_rxd_ff1 == 0 && uart_rxd_ff2 == 1; 		//下降沿
	assign pos_edge = uart_rxd_ff1 == 1 && uart_rxd_ff2 == 0;		//上升沿
	
	//rx_start信号
	always @(posedge clk or negedge rst_n)begin  
		if(rst_n == 1'b0)begin
			rx_start <= 0;
		end
		else if(neg_edge)begin		//检测到下降沿开始接收
			rx_start <= 1;
		end
		else if(rx_start && cycle_cnt == CYCLE-1 && bit_cnt == 8)begin
			rx_start <= 0;			//数据接收完后拉低
		end
	end

	//RX_Vaild信号
	always @(posedge clk or negedge rst_n)begin  
		if(rst_n == 1'b0)begin
			RX_Vaild <= 0;
		end
		else if(cycle_cnt == CYCLE-1 && bit_cnt == 8)begin		//接受完成后RX_Vaild拉高一个时钟
			RX_Vaild <= 1;
		end
		else begin
			RX_Vaild <= 0;
		end
	end
	
	//cycle_cnt负责计数每bit的位宽
	always @(posedge clk or negedge rst_n)begin  
		if(!rst_n) begin    
			cycle_cnt <= 0;
		end
		else if (rx_start)begin   		//开始接收
			if(cycle_cnt == CYCLE-1)    
				cycle_cnt <= 0;     
			else           
				cycle_cnt <= cycle_cnt+1;
		end
	end     			 
	
	//bit_cnt负责计数bit数
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) begin   			
			bit_cnt <= 0;
		end
		else if (rx_start && cycle_cnt == CYCLE-1)begin   
			if(bit_cnt == 8)    		
				bit_cnt <= 0;     
			else           		  
				bit_cnt <= bit_cnt+1;
		end
	end
	
	//received data
	always @(posedge clk or negedge rst_n)begin
		if (rst_n == 1'b0)begin
			rx_data <= 8'h00;        		 
		end
		else if (rx_start && cycle_cnt == CYCLE/2-1 && bit_cnt <= 8)begin    //取每bit的中点进行采样
			rx_data[bit_cnt-1] <= uart_rxd_ff1;
		end
	end
	
endmodule
