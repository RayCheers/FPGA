`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/07 22:38:44
// Design Name: 
// Module Name: UART_Control
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


module UART_Control
(
	input 				        clk,		        //输入时钟
	input 				        rst_n,			    //复位信号，低电平有效 
    input  wire[7:0]            FIFO_IN,            //写入FIFO的数据
    input  wire                 FIFO_IN_VAILD,      //待写入数据有效
    input  wire                 ready, 
    output wire [7:0]           FIFO_OUT,           //从FIFO中读写的数据
    output wire                 FIFO_OUT_Vaild      //待读取读数据有效
);  

    //reg                         RD_FLAG ;           //读数据标志位
    wire     	                RD_EN;              //读使能
    wire             	        WR_EN;              //写使能
    wire            	        FIFO_EMPTY;         //FIFO空标志
    wire          	            FIFO_FULL ;         //FIFO满标志位
    wire [7:0]                  USED_COUNT;         //FIFO中可用数据位数
    wire                        wr_rst_busy;        //FIFO写工作
    wire                        rd_rst_busy;        //FIFO读工作

    assign WR_EN = FIFO_IN_VAILD && ~FIFO_FULL;     //写入数据有效且FIFO未满时开始写入

    // //至少1字节数据时开始读取
    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         RD_FLAG<=0;
    //     end
    //     else if(USED_COUNT>0) begin     //存满1个字节拉高RD_FLAG
    //         RD_FLAG<=1;
    //     end
    //     else if (FIFO_EMPTY) begin
    //         RD_FLAG<=0;
    //     end
    // end

    assign RD_EN = ready && ~FIFO_EMPTY;  
    assign FIFO_OUT_Vaild = RD_EN;   //每次将FIFO_OUT_Vaild拉高一个周期，输出一字节数据

    //调用FIFO以发送数据包
    FIFO_UART FIFO_UART (
    .rst(~rst_n),               // input wire rst
    .wr_clk(clk),               // input wire wr_clk
    .rd_clk(clk),               // input wire rd_clk
    .din(FIFO_IN),              // input wire [7 : 0] din
    .wr_en(WR_EN),              // input wire wr_en
    .rd_en(RD_EN),              // input wire rd_en
    .dout(FIFO_OUT),            // output wire [7 : 0] dout
    .full(FIFO_FULL),           // output wire full
    .empty(FIFO_EMPTY),         // output wire empty
    .rd_data_count(USED_COUNT),         // output wire [9 : 0] rd_data_count
    .wr_rst_busy(wr_rst_busy),          // output wire wr_rst_busy
    .rd_rst_busy(rd_rst_busy)           // output wire rd_rst_busy
    );

endmodule
