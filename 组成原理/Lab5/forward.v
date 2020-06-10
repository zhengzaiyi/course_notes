`timescale 1ns / 1ps
module forward(
    input [4:0] Rs_EX, Rt_EX,
    input [4:0] RegWtaddr_MEM, RegWtaddr_WB,
    input RegWrite_MEM, RegWrite_WB,
    output reg[1:0] RegRdout1Sel_Forward_EX, RegRdout2Sel_Forward_EX
);
    always @(*) begin 
        RegRdout1Sel_Forward_EX[0] = RegWrite_WB && (RegWtaddr_WB != 0) && (RegWtaddr_MEM != Rs_EX) && (RegWtaddr_WB == Rs_EX); 
        RegRdout1Sel_Forward_EX[1] = RegWrite_MEM && (RegWtaddr_MEM != 0) && (RegWtaddr_MEM == Rs_EX); 
        RegRdout2Sel_Forward_EX[0] = RegWrite_WB && (RegWtaddr_WB != 0) && (RegWtaddr_MEM != Rt_EX) && (RegWtaddr_WB == Rt_EX); 
        RegRdout2Sel_Forward_EX[1] = RegWrite_MEM && (RegWtaddr_MEM != 0) && (RegWtaddr_MEM == Rt_EX); 
    end

endmodule // forward