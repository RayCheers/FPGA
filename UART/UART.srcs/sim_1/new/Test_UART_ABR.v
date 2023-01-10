`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/06 19:51:29
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


module Test_UART_ABR();

//输入信号
reg                 clk;
reg                 rst_n;
reg                 uart_rxd;
reg                 cap_en;

//输出信号
wire [31:0]     	freq_cap;		    //数据发送引脚

//时钟周期，单位为ns
parameter CLK_CYCLE = 10;

//复位时间
parameter rst_time = 1000;

//模块例化
//调用串口发送模块
UART_ABR  UART_ABR(
        .clk(clk),
        .rst_n(rst_n),
        .uart_rxd(uart_rxd),
        .cap_en(cap_en),
        .freq_cap(freq_cap)
    );
//生成本地时钟
initial begin
    clk = 0;
    forever begin
        #(CLK_CYCLE/2)
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
    cap_en = 1;
end

//
task bauder();
    input [9:0] data;
    output rxd;

    integer i;

    forever begin
        #1000;
        for(i=0; i<=9;i=i+1)begin
            repeat(10416)@(posedge clk);  //延迟波特周期
            rxd = data[i];
        end
        if(i == 9)  i = 0;
    end

endtask

initial begin
    #10;
    bauder(10'b0101010101,uart_rxd);
end

endmodule
