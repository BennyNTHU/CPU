`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Benny Lee
// 
// Create Date: 2025/02/23
// Design Name: MIPS R2000 CPU Top Testbench
// Module Name: top_tb
// Project Name: MIPS R2000 CPU
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: Testbench for the top-level module of the MIPS R2000 CPU.
//              此 testbench 驅動 clock 與 reset 信號，並實例化 top 模組。
//              你可以透過層級存取觀察例如 pipeline_unit.pc_out 等內部訊號。
// 
// Dependencies: top.v, control.v, pipeline.v, if_cache.v, mem.v, ALU.v, alu_control.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top_tb;

    // 產生 clock 與 reset 信號
    reg clk;
    reg reset;
    
    // 實例化 top 模組 (注意：top 模組僅有 clk 與 reset 輸入)
    top uut (
        .clk(clk),
        .reset(reset)
    );
    
    // Clock 產生器: 10 ns 週期
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Reset 產生與釋出
    initial begin
        reset = 1;
        #20;
        reset = 0;
    end
    
    // 觀察部分內部訊號 (例如 pipeline 中的 pc_out)
    // 注意：此處假設 top.v 中 pipeline_unit 的實例名稱為 pipeline_unit，
    // 且其有 pc_out 輸出。如果你的命名不同，請調整存取名稱。
    initial begin
        $monitor("Time=%0t | PC = %h", $time, uut.pipeline_unit.pc_out);
    end
    
    // 模擬一定時間後結束
    initial begin
        #2000;
        $finish;
    end

endmodule
