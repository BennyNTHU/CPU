`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Benny Lee 
// 
// Create Date: 2025/02/23
// Design Name: MIPS R2000 Control Unit
// Module Name: control
// Project Name: 
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: Control unit for MIPS R2000 CPU
//              此單元根據輸入指令解碼產生對應的控制訊號
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module control(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] instr,       // 來自 IF Cache 的指令

    // Output signals to datapath
    output wire        RegDst,
    output wire        ALUSrc,
    output wire        MemtoReg,
    output wire        RegWrite,
    output wire        MemRead,
    output wire        MemWrite,
    output wire        Branch,
    output wire [1:0]  ALUOp,
    output wire        Jump
);

    // 取出 opcode 與 funct (對於 R-type 指令)
    wire [5:0] opcode = instr[31:26];
    wire [5:0] funct  = instr[5:0];
    
    // 控制訊號暫存暫存器
    reg regDst;
    reg aluSrc;
    reg memToReg;
    reg regWrite;
    reg memRead;
    reg memWrite;
    reg branch;
    reg jump;
    reg [1:0] aluOp;
    
    always @(*) begin
        if (reset) begin
            // 當復位時，所有控制訊號歸零
            regDst   = 1'b0;
            aluSrc   = 1'b0;
            memToReg = 1'b0;
            regWrite = 1'b0;
            memRead  = 1'b0;
            memWrite = 1'b0;
            branch   = 1'b0;
            jump     = 1'b0;
            aluOp    = 2'b00;
        end else begin
            // 預設值 (若無匹配到任何指令)
            regDst   = 1'b0;
            aluSrc   = 1'b0;
            memToReg = 1'b0;
            regWrite = 1'b0;
            memRead  = 1'b0;
            memWrite = 1'b0;
            branch   = 1'b0;
            jump     = 1'b0;
            aluOp    = 2'b00;
            
            case (opcode)
                6'b000000: begin // R-type 指令 (如 add, sub, etc.)
                    regDst   = 1'b1;
                    aluSrc   = 1'b0;
                    memToReg = 1'b0;
                    regWrite = 1'b1;
                    memRead  = 1'b0;
                    memWrite = 1'b0;
                    branch   = 1'b0;
                    jump     = 1'b0;
                    aluOp    = 2'b10; // 透過 funct 欄位進一步解碼
                end
                6'b100011: begin // lw (load word)
                    regDst   = 1'b0;
                    aluSrc   = 1'b1;
                    memToReg = 1'b1;
                    regWrite = 1'b1;
                    memRead  = 1'b1;
                    memWrite = 1'b0;
                    branch   = 1'b0;
                    jump     = 1'b0;
                    aluOp    = 2'b00;
                end
                6'b101011: begin // sw (store word)
                    // RegDst 與 MemtoReg 無意義
                    aluSrc   = 1'b1;
                    regWrite = 1'b0;
                    memRead  = 1'b0;
                    memWrite = 1'b1;
                    branch   = 1'b0;
                    jump     = 1'b0;
                    aluOp    = 2'b00;
                end
                6'b000100: begin // beq (branch if equal)
                    // RegDst 與 MemtoReg 無意義
                    aluSrc   = 1'b0;
                    regWrite = 1'b0;
                    memRead  = 1'b0;
                    memWrite = 1'b0;
                    branch   = 1'b1;
                    jump     = 1'b0;
                    aluOp    = 2'b01;
                end
                6'b000010: begin // jump
                    // 所有其他控制訊號皆不啟動
                    regWrite = 1'b0;
                    memRead  = 1'b0;
                    memWrite = 1'b0;
                    branch   = 1'b0;
                    jump     = 1'b1;
                    aluOp    = 2'b00;
                end
                default: begin
                    // 其他未實作指令，預設全部不啟用
                    regDst   = 1'b0;
                    aluSrc   = 1'b0;
                    memToReg = 1'b0;
                    regWrite = 1'b0;
                    memRead  = 1'b0;
                    memWrite = 1'b0;
                    branch   = 1'b0;
                    jump     = 1'b0;
                    aluOp    = 2'b00;
                end
            endcase
        end
    end
    
    // 將暫存控制訊號指派給輸出埠
    assign RegDst   = regDst;
    assign ALUSrc   = aluSrc;
    assign MemtoReg = memToReg;
    assign RegWrite = regWrite;
    assign MemRead  = memRead;
    assign MemWrite = memWrite;
    assign Branch   = branch;
    assign ALUOp    = aluOp;
    assign Jump     = jump;

endmodule
