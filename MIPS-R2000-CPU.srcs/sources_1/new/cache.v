`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/23
// Design Name: MIPS R2000 Cache (or simple SRAM)
// Module Name: cache
// Project Name: 
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: A simplified cache or memory module for instructions/data
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module cache(
    input  wire        clk,
    input  wire        reset,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    output wire [31:0] read_data,

    // 如果要支援指令同樣由此模組提供，則可以直接輸出指令
    // 或拆成 I-Cache / D-Cache
    output wire [31:0] instruction
);
    // 在此定義快取陣列或 SRAM，或者只是暫時的暫存器 (reg)
    // 目前僅保留介面, 不做實際實作

endmodule
