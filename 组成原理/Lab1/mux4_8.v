`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/26 16:03:50
// Design Name: 
// Module Name: mux4_8
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


module mux4_8
    #(parameter WIDTH = 32)
    (output reg [WIDTH - 1:0] y, 
    input [WIDTH - 1:0] a, b, c, d, 
    input [1:0] s
    );
always @(*) begin
    case (s)
        0: y = a;
        1: y = b;
        2: y = c;
        3: y = d; 
    endcase
end
endmodule