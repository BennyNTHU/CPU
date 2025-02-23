`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Benny Lee
// 
// Create Date: 2025/02/23
// Design Name: Pipeline Testbench
// Module Name: pipeline_tb
// Project Name: MIPS R2000 CPU
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: Testbench for the pipeline module.
//              此 testbench 驅動 pipeline 的控制訊號與指令，並模擬
//              外部資料記憶體回應（mem_data_in），以驗證 IF、ID、EX、MEM、WB
//              各階段的基本功能運作。
// 
// Dependencies: pipeline.v, ALU.v, alu_control.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module pipeline_tb;

    // Clock與reset訊號
    reg clk;
    reg reset;

    // 模擬自控制單元的控制訊號
    reg        RegDst;
    reg        ALUSrc;
    reg        MemtoReg;
    reg        RegWrite;
    reg        MemRead;
    reg        MemWrite;
    reg        Branch;
    reg [1:0]  ALUOp;
    reg        Jump;

    // 指令輸入 (來自 IF Cache)
    reg [31:0] instruction;

    // Data Memory 介面 (模擬外部資料記憶體)
    reg [31:0] mem_data_in;
    wire [31:0] mem_data_out;
    wire [31:0] mem_addr;

    // Pipeline 輸出，目前的 PC 值，供外部觀察
    wire [31:0] pc_out;

    // 實例化 pipeline 模組
    pipeline uut (
        .clk(clk),
        .reset(reset),
        // 控制訊號
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUOp(ALUOp),
        .Jump(Jump),
        // 指令輸入
        .instruction(instruction),
        // Data Memory 介面
        .mem_data_in(mem_data_in),
        .mem_data_out(mem_data_out),
        .mem_addr(mem_addr),
        // 輸出目前 PC 值
        .pc_out(pc_out)
    );

    // Clock產生：週期 10 ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // 初始設定與 reset
        reset       = 1;
        RegDst      = 0;
        ALUSrc      = 0;
        MemtoReg    = 0;
        RegWrite    = 0;
        MemRead     = 0;
        MemWrite    = 0;
        Branch      = 0;
        ALUOp       = 2'b00;
        Jump        = 0;
        instruction = 32'b0;
        mem_data_in = 32'b0;
        
        #20;
        reset = 0;
        
        //---------------------------------------------------------
        // Cycle 1: 執行 R-type 指令 add $3, $1, $2
        // 指令格式: opcode=0, rs=1, rt=2, rd=3, shamt=0, funct=32 (100000)
        // 組合: {6'b000000, 5'd1, 5'd2, 5'd3, 5'd0, 6'b100000}
        instruction = {6'b000000, 5'd1, 5'd2, 5'd3, 5'd0, 6'b100000};
        // 控制訊號設定 (R-type)
        RegDst   = 1;
        ALUSrc   = 0;
        MemtoReg = 0;
        RegWrite = 1;
        MemRead  = 0;
        MemWrite = 0;
        Branch   = 0;
        ALUOp    = 2'b10;  // 表示 R-type 指令
        Jump     = 0;
        
        // 等待 50 ns 以觀察 pipeline 流程
        #50;
        
        //---------------------------------------------------------
        // Cycle 2: 執行 lw 指令 lw $3, 4($1)
        // 指令格式: opcode=35 (100011), rs=1, rt=3, immediate=4
        instruction = {6'b100011, 5'd1, 5'd3, 16'd4};
        // 控制訊號設定 (lw)
        RegDst   = 0;  // 目的暫存器由 rt 指定
        ALUSrc   = 1;  // ALU 第二輸入來自立即數
        MemtoReg = 1;  // 寫回資料來自 Data Memory
        RegWrite = 1;
        MemRead  = 1;
        MemWrite = 0;
        Branch   = 0;
        ALUOp    = 2'b00;  // lw 會用 ADD 計算位址
        Jump     = 0;
        // 模擬 Data Memory 回傳值 (例如: 0x12345678)
        mem_data_in = 32'h12345678;
        
        #50;
        
        //---------------------------------------------------------
        // Cycle 3: 執行 sw 指令 sw $3, 8($1)
        // 指令格式: opcode=43 (101011), rs=1, rt=3, immediate=8
        instruction = {6'b101011, 5'd1, 5'd3, 16'd8};
        // 控制訊號設定 (sw)
        // sw 不寫回暫存器，因此 RegWrite = 0；MemWrite = 1
        RegDst   = 0;  // 無意義
        ALUSrc   = 1;  // 立即數作為位址偏移
        MemtoReg = 0;  // 無意義
        RegWrite = 0;
        MemRead  = 0;
        MemWrite = 1;
        Branch   = 0;
        ALUOp    = 2'b00;  // 使用 ADD 計算位址
        Jump     = 0;
        
        #50;
        
        $finish;
    end

endmodule
