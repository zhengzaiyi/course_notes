`timescale 1ns / 1ps
module top(
    input clk, rst
);
//----------------------------variables------------------------------//
    //_后缀表示该信号所在的流水段 
    wire ALUSrcASel_ID, ALUSrcASel_EX; 
    wire [1:0] ALUSrcBSel_ID;//alu B在regout2和imm之间选择 
    wire [1:0] ALUSrcBSel_EX; 
    wire [31:0] ALUSrcA_EX, ALUSrcB_EX; 
    wire [4:0] ALUControl_ID, ALUControl_EX; 
    wire [31:0] ALUResult_EX, ALUResult_MEM, ALUResult_WB; 
    wire [1:0] RsCMPZero; 
    wire [1:0] RsCMPRt; 
    wire [31:0] IMMSignExtended_ID, IMMSignExtended_EX; 
    wire [31:0] IMMZeroExtended_ID, IMMZeroExtended_EX; 
    wire [31:0] ShamtZeroExtended_ID, ShamtZeroExtended_EX;
    wire [1:0] RegRdout1Sel_Forward_EX;//旁路单元产生的选择信号 
    wire [1:0] RegRdout2Sel_Forward_EX; 
    wire [31:0] RegRdout1_Forward_EX;//旁路数据 
    wire [31:0] RegRdout2_Forward_EX; 
    wire [4:0] RegRdaddr1_ID, RegRdaddr2_ID; 
    wire [31:0] RegRdout1_ID, RegRdout1_EX;
    wire [31:0] RegRdout2_ID, RegRdout2_EX; 
    wire [4:0] RegWtaddr_ID, RegWtaddr_EX, RegWtaddr_MEM, RegWtaddr_WB; 
    wire [31:0] RegWtin_WB; 
    wire RegWrite_ID, RegWrite_EX, RegWrite_MEM, RegWrite_WB; 
    wire RegDst_ID; 
    wire [31:0] IMemaddr; 
    wire [31:0] IMemout; 
    wire [31:0] DMemaddr_MEM; 
    wire [31:0] DMemin_MEM; 
    wire DMemRead_MEM, DMemWrite_MEM; 
    wire [31:0] DMemout_MEM; 
    wire [31:0] DMemout_WB;  
    wire DMemtoReg_EX, DMemtoReg_MEM, DMemtoReg_WB; 
    wire [31:0] PC; 
    wire [31:0] PCPlus_IF, PCPlus_ID, PCPlus_EX; 
    wire [31:0] EPC; 
    wire [31:0] nextPC; 
    wire PCEn; 
    wire [1:0] PCSrc_ID;//Control输出的，0:+4,1:Branch,2:J,3:JR 
    wire IF_ID_En, IF_ID_Flush, ID_EX_Flush; 
    wire [31:0] PCJump_ID; 
    wire [31:0] PCJR_ID; 
    wire [31:0] PCBranch_ID; 
    wire [31:0] Instr; 
    wire [5:0] Funct; 
    wire [4:0] Shamt; 
    wire [15:0] IMM16; 
    wire [4:0] Rd, Rt, Rs; 
    wire [5:0] Op; 
    wire [4:0] Rt_EX, Rs_EX;//为了旁路判断 
    wire [25:0] JumpIMM; 
    wire [31:0] IMMSignExtendedShiftLeft2;
//---------------------------CONTROL------------------------------//

// + control

// + forward

// + hazard

//--------------------------IF-----------------------------------//
    
//----------------------------IFID-------------------------------//
    dff(clk, IF_ID_En, IF_ID_Flush | rst, PCPlus_IF, PCPlus_ID);
    dff(clk, IF_ID_En, IF_ID_Flush | rst, IMemout, Instr);
//----------------------------ID-----------------------------------//

//-----------------------------IDEX--------------------------------//

//-----------------------------EX----------------------------------//

//-------------------------------EXMEM----------------------------//

//---------------------------------MEM-------------------------------//

//-----------------------------MEMWB-------------------------------//

//------------------------------WB---------------------------------//

endmodule // top