`timescale 1ns / 1ps


module fifo(
// output reg [4:0] HEAD,
//  output reg[4:0]TAIL,
//  output IN, OUT,
//  output reg [4:0] addr,
//  output [7:0] DOUT,
//  output reg [2:0] current_state,
 input clk, rst,		//ʱ�ӣ���������Ч�����첽��λ���ߵ�ƽ��Ч��
 input [7:0] din,		//���������???
 input en_in, 		//�����ʹ�ܣ��ߵ�ƽ���?
 input en_out,		//������ʹ�ܣ��ߵ�ƽ��Ч
 output reg [7:0] dout, 	//����������
 output [4:0] count	//�������ݼ���
);
    parameter KEEP = 1;
    parameter PUSH = 2;
    parameter POP = 3;
    reg [4:0] HEAD, TAIL;   // circular queue
    reg [4:0] addr;
    reg [1:0] current_state;
    reg [2:0] next_state;
    reg en, we;
    reg last_is_pop1, last_is_pop2;
    wire [7:0]DOUT;
    wire IN, OUT;
    // TAKE EDGE
    signal_edge2 sig(clk, en_in, IN);
    signal_edge2 sig1(clk, en_out, OUT);
    // RAM
    blk_mem_gen_1 ram1(.addra(addr), 
                        .clka(clk), 
                        .dina(din), 
                        .douta(DOUT),
                        .ena(1),
                        .wea(we));
    assign count = (TAIL - HEAD) % 32;

    always @(*) begin
        //if(rst) next_state = KEEP;
        //else begin
            // PRI: POP(Write) < PUSH(READ) 
            //  maxsize(queue) = 32-1 = 31
            if(IN & (count < 31)) next_state = PUSH;
            else if(OUT & (count > 0)) next_state = POP;
            else next_state = KEEP;
            next_state = 4*(current_state%4==3) + next_state;
        //end
    end
    always @(posedge clk or posedge rst) begin 
        if(rst) current_state <= KEEP;
        else current_state <= next_state;
    end
    always @(*) begin
        dout = 0;
        {we, en} = 2'b00;
        if(rst) begin
            {HEAD, TAIL, addr, en, we} = 17'b0;
            //$readmemb("RST.vex", ram1);
        end
        else begin
            case (current_state%4)
                KEEP: {en, we} = 2'b0;
            PUSH: begin
                    addr = TAIL;
                    TAIL = (TAIL+1) % 32;
                    we = 1;
                end
                POP: begin
                    addr = HEAD;
                    we = 0;
                    // dout = DOUT;
                    HEAD = (HEAD+1) % 32;            
                end
                default: ;
            endcase
            if(current_state>3) dout = DOUT;
        end
    end

endmodule

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

module mux2
#(parameter N = 5)
(
    input s,
    input [N-1:0] a,
    input [N-1:0] b,
    output reg [N-1:0] y
);
    always @(*)
        if(s) y = b;
        else y = a;
endmodule 