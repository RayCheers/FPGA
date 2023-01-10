`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/27 13:21:03
// Design Name: 
// Module Name: Button
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


module Button
#(
    parameter               T10MS = 19'd500_000
)
(
    input                   clk, rst_n,
    input                   button,
    output [1:0]            oTrig
 );

    reg                     F2,F1;
    reg [3:0]               i;
    reg                     isPress, isRelease;
    reg [18:0]              C1;
    wire                    isH2L = ( F2 == 0 && F1 == 1 );
    wire                    isL2H = ( F2 == 1 && F1 == 0 );

    always @ ( posedge clk or negedge rst_n )
        if( !rst_n )
            { F2, F1 } <= 2'b00;
        else
            { F2, F1 } <= { F1, button };

    always @ ( posedge clk or negedge rst_n )begin
        if( !rst_n )
        begin
            i <= 4'd0;
            { isPress,isRelease } <= 2'b11;
            C1 <= 19'd0;
        end
        else begin
            case(i)
                0:          // H2L check
                    if( isH2L ) i <= i + 1'b1;
                1:          // H2L debounce
                    if( C1 == T10MS -1 ) begin 
                        C1 <= 19'd0; 
                        i <= i + 1'b1; 
                    end
                else C1 <= C1 + 1'b1;
                2: begin 
                    isPress <= 1'b1; 
                    i <= i + 1'b1; 
                end
                3: begin 
                    isPress <= 1'b0; 
                    i <= i + 1'b1; 
                end
                4:          // L2H check
                if( isL2H ) 
                    i <= i + 1'b1;
                5:          // L2H debounce
                if( C1 == T10MS -1 ) begin 
                    C1 <= 19'd0; 
                    i <= i + 1'b1; 
                end
                else 
                    C1 <= C1 + 1'b1;
                6: begin        // button trigger prees up
                    isRelease <= 1'b1; 
                    i <= i + 1'b1; 
                end
                7: begin        // button trigger prees down
                    isRelease <= 1'b0; 
                    i <= 4'd0; 
                end
            endcase
        end
    end

    assign oTrig = { isPress, isRelease };


endmodule
