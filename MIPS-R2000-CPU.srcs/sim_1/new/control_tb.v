`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Benny Lee
// 
// Create Date: 2025/02/23
// Design Name: MIPS R2000 Control Unit Testbench
// Module Name: control_tb
// Project Name: 
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: Testbench for the control unit module.
//              驅動不同指令，檢查各控制訊號輸出。
// 
// Dependencies: control.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module control_tb;

    // Clock與reset訊號
    reg clk;
    reg reset;
    
    // 指令輸入 (來自 IF Cache 的指令)
    reg [31:0] instr;
    
    // 控制訊號輸出
    wire RegDst;
    wire ALUSrc;
    wire MemtoReg;
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire Branch;
    wire [1:0] ALUOp;
    wire Jump;
    
    // 實例化 control 模組
    control uut (
        .clk(clk),
        .reset(reset),
        .instr(instr),
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUOp(ALUOp),
        .Jump(Jump)
    );
    
    // Clock產生器：每 5 ns 反轉 (10 ns 週期)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test Sequence
    initial begin
        $display("Time\t\t instr\t\t\t\tRegDst ALUSrc MemtoReg RegWrite MemRead MemWrite Branch ALUOp  Jump");
        $monitor("%0t\t %h\t %b    %b     %b       %b      %b      %b      %b    %b", 
                 $time, instr, RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp, Jump);
        
        // 初始設定，保持 reset 一段時間
        reset = 1;
        instr = 32'b0;
        #10;
        reset = 0;
        
        // Test Case 1: R-type 指令 (例如 add $3, $1, $2)
        // 指令格式: {opcode[6], rs[5], rt[5], rd[5], shamt[5], funct[6]}
        // R-type: opcode = 6'b000000, funct = 6'b100000 (add)
        instr = {6'b000000, 5'd1, 5'd2, 5'd3, 5'd0, 6'b100000};
        #20;
        
        // Test Case 2: lw 指令 (lw $3, 4($1))
        // 指令格式: {opcode[6], rs[5], rt[5], immediate[16]}
        // opcode = 6'b100011
        instr = {6'b100011, 5'd1, 5'd3, 16'd4};
        #20;
        
        // Test Case 3: sw 指令 (sw $3, 4($1))
        // opcode = 6'b101011
        instr = {6'b101011, 5'd1, 5'd3, 16'd4};
        #20;
        
        // Test Case 4: beq 指令 (beq $1, $2, offset)
        // opcode = 6'b000100
        instr = {6'b000100, 5'd1, 5'd2, 16'd8};
        #20;
        
        // Test Case 5: jump 指令 (jump target)
        // opcode = 6'b000010, target 為 26 bits
        instr = {6'b000010, 26'd1024};
        #20;
        
        $finish;
    end

endmodule
