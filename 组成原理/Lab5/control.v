`timescale 1ns / 1ps
`def lw = 6'b100011
`def sw = 6'b101011
`def addi = 6'b001000
`def R = 6'b000000
`def beq = 6'b000100
`def j = 6'b000010
// pcsrc
`def plus4 = 0
`def Br = 1
`def jump = 2
// regdst
`def Rt = 0
`def Rd = 1
// alusrcasel
`def rd1 = 0
`def SZE = 1
// alusrcbsel
`def rd2 = 0
`def SE = 1
`def ZE = 2
// dmemtoreg
`def ALUOUT = 0
`def MEMOUT = 1
module control(
    input clk, rst,
    input [5:0] Op,
    input [4:0] Rt, 
    input [5:0] Funct, 
    input [1:0] RsCMPRt, 
    input [1:0] RsCMPZero, 
    output reg [1:0] PCSrc, 
    //ID 
    output reg RegDst,      
    //EX 
    output reg ALUSrcASel,  
    output reg [1:0] ALUSrcBSel,
    output reg [4:0] ALUControl, 
    //MEM 
    output reg DMemRead,
    output reg DMemWrite,
    //WB 
    output reg DMemtoReg,
    output reg RegWrite
);
reg [1:0] tmpsrc;

always @(*) begin
    if (rst) begin
        PCSrc <= 0;
        RegDst <= 0;
        ALUSrcASel <= 0;
        ALUSrcBSel <= 0;
        ALUControl <= 6;
        DMemRead <= 0;
        DMemWrite <= 0;
        DMemtoReg <= 0;
        RegWrite <= 1;
    end
    else
        case (Op)
            lw: begin  
                PCSrc <= plus4;
                RegDst <= Rt;
                ALUSrcASel <= rd1;
                ALUSrcBSel <= SE;
                ALUControl <= 0;
                DMemRead <= 1;
                DMemWrite <= 0;
                DMemtoReg <= 1;
                RegWrite <= 1; 
            end
            sw: begin  
                PCSrc <= plus4;
                RegDst <= 0;    // 这里不确定
                ALUSrcASel <= rd1;
                ALUSrcBSel <= SE;
                ALUControl <= 0;
                DMemRead <= 0;
                DMemWrite <= 1;
                DMemtoReg <= 0;
                RegWrite <= 0; 
            end
            addi: begin  
                PCSrc <= plus4;
                RegDst <= Rt;
                ALUSrcASel <= rd1;
                ALUSrcBSel <= SE;
                ALUControl <= 0;
                DMemRead <= 0;
                DMemWrite <= 0;
                DMemtoReg <= 0;
                RegWrite <= 1; 
            end
            R: begin  // addi
                PCSrc <= plus4;
                RegDst <= Rd;
                ALUSrcASel <= rd1;
                ALUSrcBSel <= rd2;
                ALUControl <= 0; // add
                DMemRead <= 0;  
                DMemWrite <= 0;
                DMemtoReg <= 0;
                RegWrite <= 1; 
            end
            beq: begin  
                PCSrc <= Br;
                RegDst <= 0;
                ALUSrcASel <= RsCMPRt[0];
                ALUSrcBSel <= 0;
                ALUControl <= 0;
                DMemRead <= 0;
                DMemWrite <= 0;
                DMemtoReg <= 0;
                RegWrite <= 0; 
            end
            j: begin  
                PCSrc <= jump;
                RegDst <= 0;    // nonsense
                ALUSrcASel <= 0;// nonsense
                ALUSrcBSel <= 0;// nonsense
                ALUControl <= 6;// nonsense
                DMemRead <= 0;
                DMemWrite <= 0;
                DMemtoReg <= 0; // nonsense
                RegWrite <= 0; 
            end 
            default:; 
        endcase
    
end
endmodule // control