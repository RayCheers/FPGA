`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/08 12:13:20
// Design Name: 
// Module Name: Test_UART_FIFO
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


module Test_UART_FIFO();
reg         clk;
reg         rst_n;
reg [7:0]   din;
reg         din_vld;
wire        uart_rxd;   //用来连接上位机的tx和从机的rx
wire        uart_txd;

parameter       CYCLE=10;

wire                        RX_Vaild;           //接收完成标志
wire [7:0]                  rx_data;            //接收到的数据
wire [7:0]                  TX_Vaild;           //发送数据有效标志
wire [7:0]                  tx_data;            //待发送的数据
wire                        TX_OVER;        //数据发送结束标志
wire [7:0]                  FIFO_OUT;           //FIFO的输出

//例化从机（顶层模块，包含了一个uart_rx和一个uart_tx）
//调用串口控制模块(FIFO)
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
    .CYCLE(20'd10416),
    .rx_data(rx_data),
    .RX_Vaild(RX_Vaild)
    );

//调用串口发送模块
UART_TX  UART_TX(
    .clk(clk),
    .rst_n(rst_n),
    .tx_data(tx_data),
    .CYCLE(20'd10416),
    .TX_Vaild(TX_Vaild),
    .uart_txd(uart_txd),
    .TX_OVER(TX_OVER)
    );

//例化上位机（用来给从机发送数据）
UART_TX UART_TX_PC(
    .clk              (clk),
    .rst_n            (rst_n),
    .tx_data          (din),
    .CYCLE            (20'd10416),
    .TX_Vaild         (din_vld),
    .uart_txd         (uart_rxd)
);

always #(CYCLE/2)  clk=~clk;

initial begin
    clk=1;
    rst_n=1;
    #200;
    rst_n=0;
    din_vld=0;
    #(CYCLE*10);
    rst_n=1;

    send(8'h11);
    send(8'h22);
    send(8'h33);
    send(8'h44);
    send(8'h55);
    send(8'h66);
    send(8'h77);
    send(8'h88);
    #2000000;
    $stop;

end

task send;
    input [7:0] send_data;
    begin
        din = send_data;
        din_vld = 1;
        #CYCLE;
        din_vld = 0;
        #(CYCLE*120000);
    end
endtask


endmodule
