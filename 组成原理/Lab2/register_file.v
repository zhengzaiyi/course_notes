`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/02 11:26:22
// Design Name: 
// Module Name: register_file
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


module register_file
 #(parameter WIDTH = 32) 	//���ݿ���
(input clk,						//ʱ�ӣ���������Ч��
 input [4:0] ra0,				//���˿�0��ַ
 output [WIDTH-1:0] rd0, 	//���˿�0����
 input [4:0] ra1, 				//���˿�1��ַ
 output [WIDTH-1:0] rd1, 	//���˿�1����
 input [4:0] wa, 				//д�˿ڵ�ַ
 input we,					//дʹ�ܣ��ߵ�ƽ��Ч
 input [WIDTH-1:0] wd 		//д�˿�����
 );

reg [WIDTH-1:0] REGS[31:0];
integer i;
assign rd0 = REGS[ra0];
assign rd1 = REGS[ra1];
always @(posedge clk) begin
    REGS[0] = 0;
    if(we & wa) begin
        REGS[wa] = wd;
    end
end
endmodule
