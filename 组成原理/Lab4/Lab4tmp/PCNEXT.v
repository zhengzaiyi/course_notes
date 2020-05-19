`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/11 19:27:33
// Design Name: 
// Module Name: pc_reg
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


module PCNEXT( 
    input [1:0] PCSource;
    input [31:0] ALUresult, ALUOut,
    input PCWrite, PCWriteCond, zero,
    input clk, rst,
    input [25:0] jumpimm,
    input [31:0] sign_ext,
    output reg [31:0] nextpc,
    output PCwe
);
    wire [31:0] pcbeq, pcjump;
    
    assign PCwe = PCWrite | (PCWriteCond & zero);
    assign pcjump = {{pcplus4[31:28]}, {{2'b00, jumpimm}<<2}};
    // get nextpc
    always @(*) begin
        case (PCSource)
            0: nextpc = ALUresult;
            1: nextpc = ALUOut;
            2: nextpc = pcjump;
            default: nextpc = 0;
        endcase
    end
endmodule
