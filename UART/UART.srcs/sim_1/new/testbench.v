`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/08 17:17:12
// Design Name: 
// Module Name: testbench
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


module testbench();

reg                         clk;
reg                         rst_n;
reg [7:0]                   din;
reg                         din_vld;

wire                        uart_rxd;           //用来连接上位机和从机
wire                        uart_txd;
wire [7:0]                  rx_data;            //接收到的数据
wire [15:0]                 LED;
wire [7:0]                  AN;
wire [7:0]                  seg_ment;

parameter       CYCLE=10;

//例化从机
UART UART(
    .clk(clk),
    .rst_n(rst_n),
    .uart_rxd(uart_rxd),
    .BTNC(1),
    .SW(8'd11),
    .uart_txd(uart_txd),
    .LED(LED),
    .AN(AN),
    .seg_ment(seg_ment)
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
