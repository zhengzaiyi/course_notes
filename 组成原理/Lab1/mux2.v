`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/26 15:58:10
// Design Name: 
// Module Name: mux2
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


module mux2		    //模块名：mux2
    #(parameter WIDTH = 32) //参数声明：数据宽度
    (output [WIDTH-1:0] y,	   //端口声明：输出数据
    input [WIDTH-1:0] a, b,   //两路输入数据
    input s	                 //数据选择控制
    );
    assign y = s? b : a;	  //逻辑功能描述
endmodule

