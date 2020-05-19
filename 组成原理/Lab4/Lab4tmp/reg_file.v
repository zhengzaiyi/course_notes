`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/11 19:27:08
// Design Name: 
// Module Name: reg_file
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


module reg_file(
input clk,
input rst,
input [4:0] ra1,
input [4:0] ra2,
input [4:0] ra3,
input [4:0] wa,
input [31:0] wd,
input we,
output reg [31:0] rd1,
output reg [31:0] rd2,
output reg [31:0] rd3
);
reg [31:0] REG [31:0];
always@(posedge clk or posedge rst)
begin
    if (rst) begin
        REG[0] <= 32'b0;
        REG[1] <= 32'b0;
        REG[2] <= 32'b0;
        REG[3] <= 32'b0;
        REG[4] <= 32'b0;
        REG[5] <= 32'b0;
        REG[6] <= 32'b0;
        REG[7] <= 32'b0;
        REG[8] <= 32'b0;
        REG[9] <= 32'b0;
        REG[10] <= 32'b0;
        REG[11] <= 32'b0;
        REG[12] <= 32'b0;
        REG[13] <= 32'b0;
        REG[14] <= 32'b0;
        REG[15] <= 32'b0;
        REG[16] <= 32'b0;
        REG[17] <= 32'b0;
        REG[18] <= 32'b0;
        REG[19] <= 32'b0;
        REG[20] <= 32'b0;
        REG[21] <= 32'b0;
        REG[22] <= 32'b0;
        REG[23] <= 32'b0;
        REG[24] <= 32'b0;
        REG[25] <= 32'b0;
        REG[26] <= 32'b0;
        REG[27] <= 32'b0;
        REG[28] <= 32'b0;
        REG[29] <= 32'b0;
        REG[30] <= 32'b0;
        REG[31] <= 32'b0;
    end
    else if(we)
        REG[wa]<= wd;
end

always@(*)
begin
    if(ra1)
        rd1 = REG[ra1];
    else
        rd1 = 32'h0;
end

always@(*)begin
    if(ra2)
        rd2 = REG[ra2];
    else
        rd2 = 32'h0;
end
always@(*)begin
    if(ra3)
        rd3 = REG[ra3];
    else
        rd3 = 32'h0;
end
endmodule
