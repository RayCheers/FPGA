`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/05 20:54:47
// Design Name: 
// Module Name: UART_ABR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Auto Band Rate
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_ABR
(
    input                   clk,
    input                   rst_n,
    input                   uart_rxd,
    input                   cap_en,
    output reg [31:0]       freq_cap          //对输入信号波特率测得的频率
);
 
    reg [31:0]              tmp_cap; 
    reg [31:0]              sequence_cap[2:0];    //捕获5次取最小值作为波特率输出
    reg [2:0]               cap_cnt;

    // reg cap_finish;
    reg                     S0_RXD, S1_RXD;         //同步寄存器，消除亚稳态
    reg                     TMP0_RXD, TMP1_RXD;     //数据寄存器，移位寄存器
    reg                     cap_state;           //0:idle 1:work
    wire                    neg_RXD;            //下降沿

    always@(posedge clk or negedge rst_n)       //同步寄存器，消除亚稳态
        if(!rst_n)
            begin
                S0_RXD <= 1'b0;
                S1_RXD <= 1'b0;
            end
        else
            begin
                S0_RXD <= uart_rxd;     //次态
                S1_RXD <= S0_RXD;       //现态
            end

    always@(posedge clk or negedge rst_n)       //数据寄存器
        if(!rst_n)
            begin
                TMP0_RXD <= 1'b0;
                TMP1_RXD <= 1'b0;
            end
        else
            begin
                TMP0_RXD <= S1_RXD;
                TMP1_RXD <= TMP0_RXD;
            end

    //共打两拍再检测输入脚
    assign neg_RXD = (!TMP0_RXD) & TMP1_RXD;        //下降沿检测

    always@(posedge clk or negedge rst_n)   //cap工作状态
        if(!rst_n)begin
            cap_state <= 0;
            end
        else if(neg_RXD)                    //下降沿开始测频
            cap_state <= 1;
        else if (TMP0_RXD)        //高电平退出测频
            cap_state <= 0;

    always@(posedge clk or negedge rst_n)//以100Mhz时钟测输入引脚低电平脉宽
        if(!rst_n)
            begin
                tmp_cap <= 32'd0;
            end
        else if(cap_state)                //串口工作状态（接受）时计数
            begin
                if(TMP0_RXD)        //计完一次频率
                    begin
                    sequence_cap[cap_cnt] <= tmp_cap;
                    tmp_cap <= 32'd0;
                    cap_cnt <= cap_cnt + 1;//0 1 2 3,4测完5次后为4
                    end
                else
                tmp_cap <= tmp_cap + 1'b1;           //每过一个时钟周期tmp_cnt加1
            end
    
    integer i;
    reg[31:0] min_cap;

    always@(cap_cnt)                    //测完一个序列便从测频序列里找出最小脉宽即为bps
        begin
            if (cap_cnt == 3'd5)begin
                min_cap = sequence_cap[0];      
                for (i=1;i<5;i=i+1)
                    if (sequence_cap[i] < min_cap && sequence_cap[i] > 10)
                        min_cap = sequence_cap[i];          //选出最小的计数周期
                if (cap_en)                 //手动控制更新baud
                    freq_cap = min_cap;
            end
        end

endmodule