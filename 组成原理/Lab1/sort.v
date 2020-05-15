`timescale 1ns / 1ps

module sort
    #(parameter N = 4) 			        //数据宽度
    (output [N-1:0] s0, s1, s2, s3, 	//排序后的四个数据（�?�增�???
     output reg done, 				        //排序结束标志
     input [N-1:0] x0, x1, x2, x3,	    //原始输入数据
     input clk, rst				        //时钟（上升沿有效）�?�复位（高电平有效）
     //output reg [2:0] current_state,
     // output cf,
     //output wire [N-1:0] op_num1, op_num2
    );
    wire [N-1:0] op_num1, op_num2;
    wire of;
    wire [N:0] result;
    wire [N-1:0] i0, i1, i2, i3;                  // register input
    reg en0, en1, en2, en3;                     // register write enable
    wire [N-1:0] r0, r1, r2, r3;                   // register output
    reg [3:0] current_state;                    // current_state register
    reg [1:0] m0, m1, m2, m3, m4, m5;
    parameter LOAD = 0;
    parameter CX01 = 1;
    parameter CX12 = 2;
    parameter CX23 = 3;
    parameter CX01s = 4;
    parameter CX12s = 5;
    parameter CX01t = 6;
    parameter HLT = 7;
    register #(N) R0 (clk, rst, en0, i0, r0);
	register #(N) R1 (clk, rst, en1, i1, r1);
	register #(N) R2 (clk, rst, en2, i2, r2);
    register #(N) R3 (clk, rst, en3, i3, r3);
    mux4_8 #(N) M0 (i0, x0, r1, r2, r3, m0);
    mux4_8 #(N) M1 (i1, r0, x1, r2, r3, m1);
    mux4_8 #(N) M2 (i2, r0, r1, x2, r3, m2);
    mux4_8 #(N) M3 (i3, r0, r1, r2, x3, m3);
    mux4_8 #(N) M4 (op_num1, r0, r1, r2, r3, m4);
    mux4_8 #(N) M5 (op_num2, r0, r1, r2, r3, m5);
    ALU #(N) alu(.of(of), .a(op_num1), .b(op_num2), .m(1), .y(result));
    assign s0 = r0;
    assign s1 = r1;
    assign s2 = r2;
    assign s3 = r3;
    always @(posedge clk or posedge rst) begin
        if(rst) begin 
            current_state = LOAD;
            done = 0;
        end
        else begin
            case (current_state)
                HLT: current_state = HLT;
                LOAD: current_state = CX01;
                CX01: current_state = CX12;
                CX12: current_state = CX23;
                CX23: current_state = CX01s;
                CX01s: current_state = CX12s;
                CX12s: current_state = CX01t;
                CX01t: current_state = HLT;
                default:;
            endcase
        end
    end 
    always @(*) begin
        {m0, m1, m2, m3, m4, m5, en0, en1, en2, en3, done} = 15'b0;
        case (current_state) 
            LOAD: begin
                m0 = 0; en0 = 1;
                m1 = 1; en1 = 1;
                m2 = 2; en2 = 1;
                m3 = 3; en3 = 1;
            end
            CX01, CX01s, CX01t: begin
                m4 = 0; m5 = 1;
                m0 = 1; m1 = 0;
                en0 = of^result[N-1]; en1 = of^result[N-1];
            end
            CX12, CX12s: begin
                m4 = 1; m5 = 2;
                m1 = 2; m2 = 1;
                en1 = of^result[N-1]; en2 = of^result[N-1];
            end
            CX23: begin
                m4 = 2; m5 = 3;
                m2 = 3; m3 = 2;
                en2 = of^result[N-1]; en3 = of^result[N-1];
            end
            HLT: done = 1; 
            default:;
        endcase
    end
endmodule
