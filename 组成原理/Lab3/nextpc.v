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


module nextpc(
    input [31:0] PC,
    input jump,
    input [25:0] jumpimm,
    input branch,
    input zero,
    input [31:0] sign_ext,
    output [31:0] pcnext
    );
    wire [31:0] pcplus4, pcbeq, pctmp;
    wire [31:0] shleft;
    wire pcsrc;

    assign pcsrc = branch & zero;
    assign shleft = sign_ext<<2;
    assign pcplus4 = PC+4;
    
    ALU PCOFFSET(.y(pcbeq), .a(shleft), .b(pcplus4), .m(0));
    assign pctmp = pcsrc ? pcbeq : pcplus4;
    assign pcnext = jump ? {{pcplus4[31:28]}, {{2'b00, jumpimm}<<2}} : pctmp;
endmodule
