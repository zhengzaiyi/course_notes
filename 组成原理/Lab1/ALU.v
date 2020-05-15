`timescale 1ns / 1ps

module ALU
    #(parameter WIDTH = 32) 	//数据宽度
    (output reg [WIDTH-1:0] y, 		//运算结果
     output reg zf, 				//零标�?
     output reg cf, 				//进位/借位标志
     output reg of, 				//溢出标志
     input [WIDTH-1:0] a, b,	//两操作数
     input [2:0] m				//操作类型
    );
    parameter ADD = 3'h0;
    parameter SUB = 3'h1;
    parameter AND = 3'h2;
    parameter OR = 3'h3;
    parameter XOR = 3'h4;
    always @(*) begin
        {cf, zf, of} = 3'b0;
        y = 0;
        case (m)
            ADD: begin
                {cf, y} = a + b;
                of = (a[WIDTH-1] ^~ b[WIDTH-1]) ? (a[WIDTH-1] ^ y[WIDTH-1]) : 0; 
            end
            SUB: begin
                {cf, y} = a - b;
                of = (a[WIDTH-1] ^ b[WIDTH-1]) ? (a[WIDTH-1] ^ y[WIDTH-1]) : 0; 
            end
            AND: y = a & b;
            OR: y = a | b;
            XOR: y = a ^ b;
            default:;
        endcase
        zf = ~|y;
    end
endmodule
