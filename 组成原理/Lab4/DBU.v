`timescale 1ns / 1ps
module DBU(
    input succ,
    input step,
    input [2:0] sel,
    input m_rf,
    input inc,clk,rst,dec,
    output reg [31:0] out,
    output reg [7:0] m_rf_addr,
    output [11:0] led
);
    wire [31:0] nextPC, Instr, RegRdout1, RegRdout2, ALUResult, Readdata, PC;
    wire Zero, ALUSrc, MemWrite, MemtoReg, RegWrite, Jump, Branch, RegDst;
    wire [2:0] ALUOp;
    wire clk1, run, INC, DEC; // redge
    wire [31:0] rf_data, m_data;
    assign led = {Jump, Branch, RegDst, RegWrite, 1, MemtoReg, MemWrite, ALUOp, ALUSrc};
    signal_edge2 edge1(.clk(clk),.button(step),.button_redge(clk1));
    signal_edge2 edge2(.clk(clk),.button(inc),.button_redge(INC));
    signal_edge2 edge3(.clk(clk),.button(dec),.button_redge(DEC));
    assign run = succ?1:clk1;
    top1 TOP(
        .clk(succ?clk:clk1),
        .rst_n(rst),
        .nextPC(nextPC),
        .Instr(Instr),
        .RegRdout1(RegRdout1),
        .RegRdout2(RegRdout2),
        .ALUResult(ALUResult),
        .Readdata(Readdata),
        .PC(PC),
        .Zero(Zero),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .Branch(Branch),
        .RegDst(RegDst),
        .ALUControl(ALUOp),
        .ra3(m_rf_addr[5:0]),
        .rd3(rf_data),
        .rd_mem_addr(m_rf_addr),
        .m_data(m_data)
    );
    always @(*) begin
        out=0;
        case (sel)
            0: out = m_rf?m_data:rf_data;
            1: out = nextPC;
            2: out = PC;
            3: out = Instr;
            4: out = RegRdout1;
            5: out = RegRdout2;
            6: out = ALUResult;
            7: out = Readdata;
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
    input rst_n,
    input [4:0] ra3,
    input [7:0] rd_mem_addr,
    output [31:0] rd3,
    output ALUSrc, 
    output [2:0] ALUControl, 
    output [31:0] ALUResult, 
    output Zero,
    output [31:0] SignExtented, shleft, 
    output [31:0] RegRdout1,
    output [31:0] RegRdout2, 
    output [4:0] wa, 
    output RegWrite, 
    output RegDst,
    output [31:0] Readdata, 
    output MemWrite,
    output MemtoReg, 
    output [31:0] Instr, 
    output reg [31:0] PC=0, 
    output [31:0] nextPC,
    output [5:0] Funct,
    output [15:0] IMM16, 
    output [4:0] Rd, 
    output [4:0] Rt, 
    output [4:0] Rs, 
    output [5:0] Op,
    output [25:0] JumpIMM, 
    output Jump, 
    output Branch,
    output [31:0] m_data 
); 
    
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
    nextpc nextpc1(PC,Jump,JumpIMM,Branch,Zero,SignExtented,nextPC); 
    always @(posedge clk or posedge rst_n) 
        if(rst_n) begin 
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
        .rst(rst_n),
        .ra1(Rs),
        .ra2(Rt),
        .ra3(ra3),
        .wa(wa),
        .we(RegWrite),
        .rd1(RegRdout1),
        .rd2(RegRdout2),
        .rd3(rd3),
        .wd(MemtoReg?Readdata:ALUResult)
    );
    ALU ALU1(
        .a(RegRdout1),
        .b(ALUSrc?SignExtented:RegRdout2),
        .y(ALUResult),
        .zf(Zero),
        .m(ALUControl)
    );
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
    dist_mem_gen_2 DMem(
        .clk(clk),
        .we(MemWrite),
        .a(ALUResult[9:2]),
        .d(RegRdout2),
        .spo(Readdata),
        .dpra(rd_mem_addr),
        .dpo(m_data)
    ); 
endmodule