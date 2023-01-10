`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/07 13:59:47
// Design Name: 
// Module Name: Test_UART_TX
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


module Test_UART_TX();

//输入信号
reg             clk;
reg             rst_n;
reg [7:0]       tx_data;
reg [31:0]      BAUD_RATE;

//输出信号
wire      			uart_txd;		    //数据发送引脚

//时钟周期，单位为ns
parameter CYCLE = 10;

//复位时间
parameter rst_time = 1000;

//模块例化
//调用串口发送模块
UART_TX  UART_TX(
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .BAUD_RATE(BAUD_RATE),
        .uart_txd(uart_txd)
    );
//生成本地时钟
initial begin
    clk = 0;
    forever begin
        #(CYCLE/2)
        clk = ~clk;
    end
end

//产生复位信号
initial begin
    rst_n = 1;
end


//产生输入信号
//tx_data
initial begin
    #1;
    //赋初值
    tx_data = 8'b10101010;
end

initial begin
    #1;
    BAUD_RATE = 32'd14400;
end
endmodule
