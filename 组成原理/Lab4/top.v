`timescale 1ns / 1ps
module top(
    input clk,
    input rst
);
//------------------variable------------------//
    reg [31:0] IR, MDR; // mem data register
    reg [31:0] PC;
    reg [31:0] A, B, ALUOut;
    wire [4:0] Rd, Rt, Rs;
    wire [25:0] JumpIMM;
    wire [15:0] IMM16; 
    wire [5:0] Op, Funct;
    wire [31:0] SignExtented, shleft, Memdata;
    wire [31:0] ALUresult;

    wire Zero;
    
    wire [1:0] IorD; 
    wire MemRead; 
    wire MemWrite; 
    wire IRWrite; 
    wire RegDst; 
    wire MemtoReg; 
    wire RegWrite;
    wire ALUSrcA; 
    wire [1:0] ALUSrcB; 
    wire [2:0] ALUControl; 
    wire Branch; 
    wire PCWrite;
    wire PCWriteCond;  
    wire [1:0] PCSource;
    wire PCwe;
    
    wire k;
    assign k = 1;
//-----------------Control--------------------//
    control control1(.clk(clk),
                     .rst(rst),
                     .zero(Zero),
                     .IorD(IorD),
                     .MemRead(MemRead),
                     .MemWrite(MemWrite),
                     .RegWrite(RegWrite),
                     .IRWrite(IRWrite),
                     .RegDst(RegDst),
                     .MemtoReg(MemtoReg),
                     .ALUSrcA(ALUSrcA),
                     .ALUSrcB(ALUSrcB),
                     .ALUcontrol(ALUControl),
                     .Branch(Branch),
                     .PCWrite(PCWrite),
                     .PCWriteCond(PCWriteCond),
                     .PCSource(PCSource),
                     .PCwe(PCwe),
                     .FUNC(Funct),
                     .opcode(Op));
//-----------------ASSIGN---------------------//
    assign JumpIMM = IR[25:0]; 
    assign Funct = IR[5:0]; 
    assign IMM16 = IR[15:0]; 
    assign Rd = IR[15:11]; 
    assign Rt = IR[20:16]; 
    assign Rs = IR[25:21]; 
    assign Op = IR[31:26];
    assign SignExtented = IMM16[15]?{16'hffff,IMM16}:{16'h0,IMM16};
    assign shleft = SignExtented<<2;
//-----------------PC-----------------------//
    wire [31:0] PCin;
    mux4 PCmux(.a(ALUresult), 
               .b(ALUOut), 
               .c({PC[31:28],{2'b00,JumpIMM}<<2}),
               .d(0),
               .sel(PCSource),
               .y(PCin));
    always @(posedge clk or posedge rst) begin
        if(rst) PC = 0;
        else if(PCwe) PC=PCin;
    end
//----------------Memory--------------------//
    wire [31:0] rd1, rd2;
    wire [8:0] memaddr;
    mux4 #(9)(.a(PC[10:2]),.b(ALUOut),.c(rd1),.d(0),.sel(IorD),.y(memaddr));
    MEM1 MEM(.clk(clk), .spo(Memdata), .we(MemWrite),.a(memaddr),.d(B));
//----------------IR MDR--------------------//
    always @(posedge clk) 
        MDR <= Memdata;
    always @(posedge clk)
        if(IRWrite) IR <= Memdata;
//----------------REGFILE-------------------//
    
    always @(posedge clk) A <= rd1;
    always @(posedge clk) B <= rd2;
    reg_file REG(.clk(clk),
                 .rst(rst),
                 .ra1(Rs),
                 .ra2(Rt),
                 .rd1(rd1),
                 .rd2(rd2),
                 .we(RegWrite),
                 .wd(MemtoReg ? MDR : ALUOut),
                 .wa(RegDst?Rd:Rt));
//----------------ALU-----------------------//
    wire [31:0] ALUA, ALUB;
    mux4 alub(.a(B),.b(4),.c(SignExtented),.d(shleft),.sel(ALUSrcB),.y(ALUB));
    mux4 alua(.a(PC),.b(A),.c(MDR), .d(0), .sel(ALUSrcA),.y(ALUA));
    ALU alu(.a(ALUA),
            .b(ALUB),
            .m(ALUControl),
            .y(ALUresult),
            .zf(Zero));
    always @(posedge clk) ALUOut = ALUresult;
endmodule // top