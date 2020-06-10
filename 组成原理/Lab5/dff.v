`timescale 1ns / 1ps
module dff #(parameter WIDTH = 32;)
(
    input clk, en, rst,
    input [WIDTH-1:0] datain,
    output reg [WIDTH-1:0] dataout
);
    always @(posedge clk or posedge rst) begin // 这里有点不一样
        if(rst) dataout <= 0;
        else if(en) dataout <= datain;
    end
endmodule // dff