`timescale 1ns / 1ps
module top( 
    input clk, 
    input rst 
); 
    wire ALUSrc; 
    wire [2:0] ALUControl; 
    wire [31:0] ALUResult; 
    wire Zero; 
    wire [31:0] SignExtented, shleft; 
    wire [31:0] RegRdout1; 
    wire [31:0] RegRdout2; 
    wire [4:0] wa; 
    wire RegWrite; 
    wire RegDst;
    wire [31:0] Readdata; 
    wire MemWrite; 
    wire MemtoReg; 
    wire [31:0] Instr; 
    reg [31:0] PC=0; 
    wire [31:0] nextPC; 
    wire [5:0] Funct; 
    wire [15:0] IMM16; 
    wire [4:0] Rd; 
    wire [4:0] Rt; 
    wire [4:0] Rs; 
    wire [5:0] Op;
    wire [25:0] JumpIMM; 
    wire Jump; 
    wire Branch; 
    integer first; 
    // -------IMEM------------------//
    dist_mem_gen_1 IMem(
        .a(PC[9:2]),
        .spo(Instr)
    );
    // --------ASSIGN----------//
    assign JumpIMM = Instr[25:0]; 
    assign Funct = Instr[5:0]; 
    assign IMM16 = Instr[15:0]; 
    assign Rd = Instr[15:11]; 
    assign Rt = Instr[20:16]; 
    assign Rs = Instr[25:21]; 
    assign Op = Instr[31:26];
    assign SignExtented = IMM16[15]?{16'hffff,IMM16}:{16'h0,IMM16};
    assign shleft = SignExtented<<2;
    // ------------PC---------------//
    nextpc nextpclogic(PC,Jump,JumpIMM,Branch,Zero,SignExtented,nextPC); 
    always @(posedge clk or posedge rst) 
        if(rst) begin 
            first <= 1; 
            PC <= 0; 
        end 
        else if(first == 1) begin 
            first <= 0; PC <= PC; 
        end 
        else PC <= nextPC; 
    
    //--------------REGFILE-----------------------//
    assign wa = RegDst?Rd:Rt; 
    reg_file REG(
        .clk(clk),
        .rst(rst),
        .ra1(Rs),
        .ra2(Rt),
        .wa(wa),
        .we(RegWrite),
        .rd1(RegRdout1),
        .rd2(RegRdout2),
        .wd(MemtoReg?Readdata:ALUResult)
    );
    //-----------ALU-------------//
    ALU ALU1(
        .a(RegRdout1),
        .b(ALUSrc?SignExtented:RegRdout2),
        .y(ALUResult),
        .zf(Zero),
        .m(ALUControl)
    );
    //-----------------control----------//
    control Control(
        .opcode(Op),
        .memtoreg(MemtoReg),
        .memwrite(MemWrite),
        .branch(Branch),
        .alucontrol(ALUControl),
        .alusrc(ALUSrc),
        .regdst(RegDst),
        .regwrite(RegWrite),
        .jump(Jump)
    );
    //---------DMEM------------//
    dist_mem_gen_0 DMem(
        .clk(clk),
        .we(MemWrite),
        .a(ALUResult[9:2]),
        .d(RegRdout2),
        .spo(Readdata)
    ); 
endmodule