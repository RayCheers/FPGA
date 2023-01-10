`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/24 22:14:17
// Design Name: 
// Module Name: UART
// Project Name: 
// Target Devices: 
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


module UART
(   
	input 				        clk,		        //输入时钟
	input 				        rst_n,			    //复位信号，低电平有效 
	input  wire  			    uart_rxd,		    //数据接收引脚
    input  wire                 BTNC,               //按键BTNC
    input  wire [7:0]           SW,                 //七位开关

    output wire      			uart_txd,		    //数据发送引脚
	output reg [15:0] 	        LED,		    	//16位板载LED
    output wire [7:0] 	        AN,		            //数码管段选
    output wire [7:0]           seg_ment            //数码管片选
);

    wire                        RX_Vaild;           //接收完成标志
    wire [7:0]                  rx_data;            //接收到的数据
    wire [7:0]                  TX_Vaild;           //发送数据有效标志
    wire [7:0]                  tx_data;            //待发送的数据
    wire                        TX_OVER;            //数据发送结束标志
    wire [7:0]                  FIFO_OUT;           //FIFO的输出
    wire [19:0]                 ABR;                //计算出的波特率
    
    //调用串口控制模块(FIFO缓冲)
    UART_Control UART_Control(
        .clk(clk),
        .rst_n(rst_n),
        .FIFO_IN(rx_data),
        .FIFO_IN_VAILD(RX_Vaild),
        .ready(TX_OVER),
        .FIFO_OUT(tx_data),
        .FIFO_OUT_Vaild(TX_Vaild)
    );

    //调用串口接收模块
    UART_RX  UART_RX(
        .clk(clk),
        .rst_n(rst_n),
        .uart_rxd(uart_rxd),
        .CYCLE(ABR),
        .rx_data(rx_data),
        .RX_Vaild(RX_Vaild)
        );

    //调用串口发送模块
    UART_TX  UART_TX(
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .CYCLE(ABR),
        .TX_Vaild(TX_Vaild),
        .uart_txd(uart_txd),
        .TX_OVER(TX_OVER)
        );
    
    //调用自适应波特率模块
    UART_ABR UART_ABR(
        .clk(clk),
        .rst_n(rst_n),
        .uart_rxd(uart_rxd),
        .cap_en(BTNC),
        .freq_cap(ABR)
        );

    //调用数码管显示模块
    SegmentDisplay   SegmentDisplay(
        .clk(clk),
        .rst_n(rst_n),
        .data(rx_data),             //显示串口接收到的数(8位二进制)
        //.BAUD_RATE(ABR),          //数码管显示波特率
        .seg_cs(AN),
        .seg_ment(seg_ment)
        );
    
    // Button Button_BTNR(
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .button(BTNR),
    //     .oTrig(BTNR_EN)
    // );

    //由rx_data信号控制LED的亮灭
	integer i;
	always @(*)begin
		for (i=0;i<=7;i=i+1)begin
			LED[i] <= rx_data[i];   //LED[7:0]显示接收到的8位数据
            LED[i+8] <= BTNC;       //灯亮表示在调整波特率
		end
	end
endmodule
