`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Benny Lee
// 
// Create Date: 2025/02/23
// Design Name: MIPS R2000 CPU Top Module
// Module Name: top
// Project Name: 
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: Top module for a MIPS R2000 CPU
//              整合 Control, Pipeline, IF Cache, 及 Data Memory 模組
// 
// Dependencies: control.v, pipeline.v, if_cache.v, mem.v, ALU.v, alu_control.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top(
    input  wire clk,
    input  wire reset
);

    // =========================================================================
    // 控制訊號（來自 Control Unit）
    // =========================================================================
    wire        RegDst;
    wire        ALUSrc;
    wire        MemtoReg;
    wire        RegWrite;
    wire        MemRead;
    wire        MemWrite;
    wire        Branch;
    wire [1:0]  ALUOp;
    wire        Jump;

    // =========================================================================
    // 指令與資料記憶體介面訊號
    // =========================================================================
    // IF Cache 與 Pipeline 之間的指令總線
    wire [31:0] instruction;

    // Data Memory 介面
    wire [31:0] mem_data_in;   // 從 Data Memory 讀出
    wire [31:0] mem_data_out;  // 要寫入 Data Memory 的資料
    wire [31:0] mem_addr;      // 資料存取位址

    // Pipeline 的 PC 輸出，作為 IF Cache 的取指位址
    wire [31:0] pc_out;

    // =========================================================================
    // 模組實例化
    // =========================================================================

    // ----------------------
    // Control Unit
    // ----------------------
    control control_unit (
        .clk       (clk),
        .reset     (reset),
        .instr     (instruction),
        .RegDst    (RegDst),
        .ALUSrc    (ALUSrc),
        .MemtoReg  (MemtoReg),
        .RegWrite  (RegWrite),
        .MemRead   (MemRead),
        .MemWrite  (MemWrite),
        .Branch    (Branch),
        .ALUOp     (ALUOp),
        .Jump      (Jump)
    );

    // ----------------------
    // Pipeline Datapath
    // ----------------------
    // 注意：本 pipeline 模組新增一個輸出端口 pc_out，
    // 用以將目前的 PC 傳遞給 IF Cache。
    pipeline pipeline_unit (
        .clk         (clk),
        .reset       (reset),
        // 來自 Control Unit 的控制訊號
        .RegDst      (RegDst),
        .ALUSrc      (ALUSrc),
        .MemtoReg    (MemtoReg),
        .RegWrite    (RegWrite),
        .MemRead     (MemRead),
        .MemWrite    (MemWrite),
        .Branch      (Branch),
        .ALUOp       (ALUOp),
        .Jump        (Jump),
        // 指令輸入（來自 IF Cache）
        .instruction (instruction),
        // Data Memory 介面
        .mem_data_in (mem_data_in),
        .mem_data_out(mem_data_out),
        .mem_addr    (mem_addr),
        // 新增：輸出目前 PC 值
        .pc_out      (pc_out)
    );

    // ----------------------
    // IF Cache (Instruction Memory)
    // ----------------------
    if_cache if_cache_unit (
        .clk         (clk),
        .reset       (reset),
        // 從 Pipeline 輸出的 PC 作為取指位址
        .if_addr     (pc_out),
        .instruction (instruction)
    );

    // ----------------------
    // Data Memory (以 Set-Associative 方式實作)
    // ----------------------
    mem mem_unit (
        .clk         (clk),
        .reset       (reset),
        .mem_read    (MemRead),
        .mem_write   (MemWrite),
        .address     (mem_addr),
        .write_data  (mem_data_out),
        .read_data   (mem_data_in)
    );

endmodule
