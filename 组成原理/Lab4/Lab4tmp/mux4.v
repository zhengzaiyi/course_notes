`timescale 1ns / 1ps
module mux4 #(parameter WIDTH = 32)
(
    input [WIDTH:0] a,
    input [WIDTH:0] b,
    input [WIDTH:0] c,
    input [WIDTH:0] d,
    input [1:0] sel,
    output reg [WIDTH:0] y
);
always @(*) begin
    case (sel)
        0: y=a;
        1: y=b;
        2: y=c;
        3: y=d;
        default:; 
    endcase
end
endmodule // mux4