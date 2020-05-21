`timescale 1ns / 1ps
module DBU(
    input succ,
    input step,
    input [2:0] sel,
    input m_rf,
    input inc,clk,rst,dec,
    output reg [31:0] out,
    output reg [8:0] m_rf_addr,
    output [15:0] led
);
    wire PCwe, IorD, MemWrite, IRWrite, RegDst, MemtoReg, RegWrite, ALUSrcA, Zero;
    wire [1:0] PCSource, ALUSrcB;
    wire [2:0] ALUcontrol;
    wire clk1, run, INC, DEC; // redge
    wire [31:0] rf_data, m_data, A, B, IR, ALUOut, MDR, PC;
    assign led = {PCSource, PCwe, IorD, MemWrite, IRWrite, RegDst, MemtoReg, RegWrite, ALUcontrol, ALUSrcA, ALUSrcB, Zero};
    signal_edge2 edge1(.clk(clk),.button(step),.button_redge(clk1));
    signal_edge2 edge2(.clk(clk),.button(inc),.button_redge(INC));
    signal_edge2 edge3(.clk(clk),.button(dec),.button_redge(DEC));
    assign run = succ?1:clk1;
    top1 TOP(
        .clk(succ?clk:clk1),
        .rst(rst),
        .IR(IR),
        .A(A),
        .B(B),
        .ALUOut(ALUOut),
        .MDR(MDR),
        .PC(PC),
        .Zero(Zero),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .RegDst(RegDst),
        .ALUcontrol(ALUcontrol),
        .ra3(m_rf_addr[5:0]),
        .rd3(rf_data),
        .rd_mem_addr(m_rf_addr),
        .m_data(m_data),
        .PCwe(PCwe)
    );
    always @(*) begin
        out=0;
        case (sel)
            0: out = m_rf?m_data:rf_data;
            1: out = PC;
            2: out = IR;
            3: out = MDR;
            4: out = A;
            5: out = B;
            6: out = ALUOut;
            7: ;
            default:; 
        endcase
    end
    always @(posedge clk or posedge rst) begin
        if(rst) m_rf_addr = 0;
        else if(INC) m_rf_addr = m_rf_addr+1;
        else if(DEC) m_rf_addr = m_rf_addr-1;
        else m_rf_addr = m_rf_addr;
    end
endmodule // DBU
module signal_edge2( 
    input clk,
    input button,
    output button_redge
); 

    reg button_r1,button_r2;
 
    always@(posedge clk) 
        button_r1 <= button; 
    always@(posedge clk) 
        button_r2 <= button_r1;
    assign button_redge = button_r1 & (~button_r2); 
endmodule

module top1(
    input clk,
    input rst,
    input [8:0]  rd_mem_addr,
    output [31:0] rd3, m_data,
    input [5:0] ra3, 
    output reg [31:0] IR, PC, MDR, A, B, ALUOut,
    output PCwe, IorD, MemWrite, IRWrite, RegDst, MemtoReg, RegWrite, ALUSrcA, Zero, PCWrite,
    output [1:0] PCSource, ALUSrcB,
    output [2:0] ALUcontrol
);
//------------------variable------------------//
    // reg [31:0] IR, MDR; // mem data register
    // reg [31:0] PC;
    // reg [31:0] A, B, ALUOut;
    wire [4:0] Rd, Rt, Rs;
    wire [25:0] JumpIMM;
    wire [15:0] IMM16; 
    wire [5:0] Op, Funct;
    wire [31:0] SignExtented, shleft, Memdata;
    wire [31:0] ALUresult;

    // wire Zero;
    
    // wire IorD; 
    wire MemRead; 
    // wire MemWrite; 
    // wire IRWrite; 
    // wire RegDst; 
    // wire MemtoReg; 
    // wire RegWrite;
    // wire ALUSrcA; 
    // wire [1:0] ALUSrcB; 
    // wire [2:0] ALUcontrol; 
     wire Branch; 
    // wire PCWrite;
    wire PCWriteCond;  
    // wire [1:0] PCSource;
    // wire PCwe;
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
                     .ALUcontrol(ALUcontrol),
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
    MEM1 MEM(.clk(clk), 
             .spo(Memdata), 
             .we(MemWrite),
             .dpra(rd_mem_addr),
             .dpo(m_data),
             .a(IorD?ALUOut[10:2]:PC[10:2]),
             .d(B));
//----------------IR MDR--------------------//
    always @(posedge clk) 
        MDR <= Memdata;
    always @(posedge clk)
        if(IRWrite) IR <= Memdata;
//----------------REGFILE-------------------//
    wire [31:0] rd1, rd2;
    always @(posedge clk) A <= rd1;
    always @(posedge clk) B <= rd2;
    reg_file REG(.clk(clk),
                 .rst(rst),
                 .ra1(Rs),
                 .ra2(Rt),
                 .ra3(ra3),
                 .rd1(rd1),
                 .rd2(rd2),
                 .rd3(rd3),
                 .we(RegWrite),
                 .wd(MemtoReg ? MDR : ALUOut),
                 .wa(RegDst?Rd:Rt));
//----------------ALU-----------------------//
    wire [31:0] ALUB;
    mux4 alub(.a(B),.b(4),.c(SignExtented),.d(shleft),.sel(ALUSrcB),.y(ALUB));
    ALU alu(.a(ALUSrcA?A:PC),
            .b(ALUB),
            .m(ALUcontrol),
            .y(ALUresult),
            .zf(Zero));
    always @(posedge clk) ALUOut = ALUresult;
endmodule // top