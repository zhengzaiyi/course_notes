`timescale 1ns / 1ps

module control(
    input clk, rst, zero,
    input [5:0] opcode,
    input [5:0] FUNC,
    output reg IorD, 
    output reg MemRead, 
    output reg MemWrite, 
    output reg IRWrite, 
    output reg RegDst, 
    output reg MemtoReg, 
    output reg RegWrite,
    output reg ALUSrcA, 
    output reg [1:0] ALUSrcB, 
    output reg [2:0] ALUcontrol, 
    output reg Branch, 
    output reg PCWrite,
    output reg PCWriteCond,  
    output reg [1:0] PCSource,
    output PCwe
);
    reg [3:0] c_state, n_state;
    assign PCwe = (zero & PCWriteCond) | PCWrite;
    always @(posedge clk or posedge rst) begin
        if(rst) c_state <= 15;
        else c_state <= n_state;
    end
    //------n_state---------//
    always @(*) begin
        case (c_state)
            4'd0: n_state=1;
            4'd1: // decode
                case (opcode)
                    6'b000000: n_state=4'd6; //R-ex
                    6'b100011: n_state = 4'd2;//lw 
                    6'b101011: n_state = 4'd2;//sw
                    6'b000100: n_state = 4'd8;//beq 
                    6'b000010: n_state = 4'd9;//jump
                    6'b001000: n_state = 4'd10;//addi
                    default: ;
                endcase 
            4'd2: //MEMaddr
                case (opcode)
                    6'b100011: n_state=4'd3;
                    6'b101011: n_state=4'd5; 
                    default: ;
                endcase
            4'd3: //memread 
                n_state = 4'd4; 
            4'd4: //memwriteback 
                n_state = 4'd0; 
            4'd5: //memwrite 
                n_state = 4'd0; 
            4'd6: //e0ecute 
                n_state = 4'd7; 
            4'd7: //aluwriteback 
                n_state = 4'd0;
            4'd8: //branch 
                n_state = 4'd0; 
            4'd9: //jump 
                n_state = 4'd0; 
            4'd10: //addi
                n_state = 4'd11; 
            4'd11: //addi writeback 
                n_state = 4'd0;
            4'd15: // rst
                n_state = 4'd0;
            default: ;
        endcase
    end
    //------signal----------//
    always @(*)begin 
        if(rst) begin 
            IorD = 1'b0; 
            PCSource = 2'b11; //nextPC=0;
            PCWrite = 1'b1; 
        end 
        else 
            case(c_state) 
                4'd0://fetch 
                begin 
                    PCWriteCond = 0;
                    IorD = 1'b0; // Memaddr: PC 
                    MemRead = 1'b1; // Mem read 
                    MemWrite = 1'b0; 
                    IRWrite = 1'b1; // save Instr 
                    RegDst = 1'b0; 
                    MemtoReg = 1'b0; 
                    RegWrite = 1'b0; 
                    ALUSrcA = 1'b0; // srcA: PC 
                    ALUSrcB = 2'b01; // srcB: 4 
                    ALUcontrol = 3'b000; // ALU's func: add 
                    Branch = 1'b0; 
                    PCWrite = 1'b1; // enable update PC 
                    PCSource = 2'b00; // select ne0tPC=PC+4 
                end 
                4'd1://decode 
                begin 
                    PCWriteCond = 0;
                    IorD = 1'b0; 
                    MemRead = 1'b0; 
                    MemWrite = 1'b0; 
                    IRWrite = 1'b0;
                    RegDst = 1'b0; 
                    MemtoReg = 1'b0; 
                    RegWrite = 1'b0; 
                    ALUSrcA = 1'b0; // srcA: PC 
                    ALUSrcB = 2'b11; // srcB: SignE0tended<<2 
                    ALUcontrol = 3'b000; // ALU's func: add 
                    Branch = 1'b0; 
                    PCWrite = 1'b0; 
                    PCSource = 2'b00; 
                end 
                4'd2: //memaddr 
                begin 
                    PCWriteCond = 0;
                    IorD = 1'b0; 
                    MemRead = 1'b0; 
                    MemWrite = 1'b0; 
                    IRWrite = 1'b0; 
                    RegDst = 1'b0; 
                    MemtoReg = 1'b0; 
                    RegWrite = 1'b0; 
                    ALUSrcA = 1'b1; // srcA: RegRdout1
                    ALUSrcB = 2'b10; // srcB: SignExtended 
                    ALUcontrol = 3'b000; // add 
                    Branch = 1'b0; 
                    PCWrite = 1'b0; 
                    PCSource = 2'b00; 
                end 
                4'd3: //memread 
                begin 
                    PCWriteCond = 0;
                    IorD = 1'b1; // ALUResult_DFF 
                    MemRead = 1'b1; //  Mem read 
                    MemWrite = 1'b0; 
                    IRWrite = 1'b0; 
                    RegDst = 1'b0; 
                    MemtoReg = 1'b0; 
                    RegWrite = 1'b0; 
                    ALUSrcA = 1'b0; 
                    ALUSrcB = 2'b00; 
                    ALUcontrol = 3'b000; 
                    Branch = 1'b0; 
                    PCWrite = 1'b0; 
                    PCSource = 2'b00; 
                end 
                4'd4: //memwriteback 
                begin 
                    PCWriteCond = 0;
                    IorD = 1'b0; 
                    MemRead = 1'b0;
                    MemWrite = 1'b0; 
                    IRWrite = 1'b0; 
                    RegDst = 1'b0; // RegWdaddr: Rt 
                    MemtoReg = 1'b1; // RegWdin: Memout 
                    RegWrite = 1'b1; // enable Reg write 
                    ALUSrcA = 1'b0; 
                    ALUSrcB = 2'b00; 
                    ALUcontrol = 3'd6; 
                    Branch = 1'b0; 
                    PCWrite = 1'b0; 
                    PCSource = 2'b00; 
                end 
                4'd5: //memwrite 
                begin 
                    PCWriteCond = 0;
                    IorD = 1'b1; // Memaddr: ALUResult_DFF 
                    MemRead = 1'b0; 
                    MemWrite = 1'b1; // enable Mem write 
                    IRWrite = 1'b0; 
                    RegDst = 1'b0; 
                    MemtoReg = 1'b0; 
                    RegWrite = 1'b0; 
                    ALUSrcA = 1'b0; 
                    ALUSrcB = 2'b00; 
                    ALUcontrol = 3'd6; 
                    Branch = 1'b0; 
                    PCWrite = 1'b0; 
                    PCSource = 2'b00; 
                end 
                4'd6: //R type e0ecute 
                begin 
                    PCWriteCond = 0;
                    IorD = 1'b0;
                    MemRead = 1'b0; 
                    MemWrite = 1'b0; 
                    IRWrite = 1'b0; 
                    RegDst = 1'b0; 
                    MemtoReg = 1'b0; 
                    RegWrite = 1'b0; 
                    ALUSrcA = 1'b1; // srcA: RegRdout1_DFF 
                    ALUSrcB = 2'b00; // srcB: RegRdout2_DFF 
                    case(FUNC) // ALU's func: decided by 'Funct' 
                        6'b100000: ALUcontrol = 5'h00;//add 
                        6'b100010: ALUcontrol = 5'h01;//sub 
                        6'b100100: ALUcontrol = 5'h02;//and 
                        6'b100101: ALUcontrol = 5'h03;//or 
                        6'b100110: ALUcontrol = 5'h04;//xor 
                        default:;
                    endcase 
                    Branch = 1'b0; 
                    PCWrite = 1'b0; 
                    PCSource = 2'b00; 
                end 
                4'd7: //aluwriteback 
                begin 
                    PCWriteCond = 0;
                    IorD = 1'b0; 
                    MemRead = 1'b0; 
                    MemWrite = 1'b0; 
                    IRWrite = 1'b0; 
                    RegDst = 1'b1; // RegWdaddr: Rd 
                    MemtoReg = 1'b0; // RegWdin: ALUResult_DFF 
                    RegWrite = 1'b1; // enable Reg write 
                    ALUSrcA = 1'b0; 
                    ALUSrcB = 2'b00; 
                    ALUcontrol = 3'd6; 
                    Branch = 1'b0; 
                    PCWrite = 1'b0; 
                    PCSource = 2'b00; 
                end 
                4'd8: //branch begin
                begin
                    IorD = 0; 
                    PCWriteCond = 1; 
                    MemRead = 1'b0; 
                    MemWrite = 1'b0; 
                    IRWrite = 1'b0; 
                    RegDst = 1'b0; 
                    MemtoReg = 1'b0; 
                    RegWrite = 1'b0; 
                    ALUSrcA = 1'b1; 
                    ALUSrcB = 2'b00; 
                    ALUcontrol = 3'b001; 
                    Branch = 1'b1; 
                    PCWrite = 1'b0; 
                    PCSource = 2'b01; 
                end 
                4'd9: //jump 
                begin 
                    PCWriteCond = 0;
                    IorD = 1'b0; 
                    MemRead = 1'b0; 
                    MemWrite = 1'b0; 
                    IRWrite = 1'b0; 
                    RegDst = 1'b0; 
                    MemtoReg = 1'b0;
                    RegWrite = 1'b0; 
                    ALUSrcA = 1'b0;
                    ALUSrcB = 2'b00; 
                    ALUcontrol = 3'd6; 
                    Branch = 1'b0; 
                    PCWrite = 1'b1; // enable update PC 
                    PCSource = 2'b10; // select ne0tPC = PCJump 
                end 
                4'd10: //addi execute 
                begin 
                    PCWriteCond = 0;
                    IorD = 1'b0; 
                    MemRead = 1'b0; 
                    MemWrite = 1'b0; 
                    IRWrite = 1'b0; 
                    RegDst = 1'b0; 
                    MemtoReg = 1'b0; 
                    RegWrite = 1'b0; 
                    ALUSrcA = 1'b1; 
                    ALUSrcB = 2'b10; 
                    ALUcontrol = 3'b000; 
                    Branch = 1'b0; 
                    PCWrite = 1'b0; 
                    PCSource = 2'b00; 
                end 
                4'd11: //addi regwriteback 
                begin 
                    PCWriteCond = 0;
                    IorD = 1'b0; 
                    MemRead = 1'b0; 
                    MemWrite = 1'b0; 
                    IRWrite = 1'b0; 
                    RegDst = 1'b0; // RegWdaddr: Rt 
                    MemtoReg = 1'b0; // RegWdin: ALUResult_DFF 
                    RegWrite = 1'b1; // enable Reg write 
                    ALUSrcA = 1'b0; 
                    ALUSrcB = 2'b00; 
                    ALUcontrol = 3'd6; 
                    Branch = 1'b0; 
                    PCWrite = 1'b0; 
                    PCSource = 2'b00; 
                end
                default:; 
            endcase 
    end
endmodule
