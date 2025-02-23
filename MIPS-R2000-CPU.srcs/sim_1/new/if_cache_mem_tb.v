`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Benny Lee
// 
// Create Date: 2025/02/23
// Design Name: IF Cache & Data Memory Testbench
// Module Name: if_cache_mem_tb
// Project Name: MIPS R2000 CPU
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: 
//   Testbench for testing the instruction cache (if_cache.v) and the 
//   data memory (mem.v) modules.
// 
// Dependencies: if_cache.v, mem.v
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module if_cache_mem_tb;

    // Clock and reset signals
    reg clk;
    reg reset;
    
    //====================================================================
    // For if_cache (Instruction Cache)
    //====================================================================
    reg  [31:0] if_addr;           // 取指地址
    wire [31:0] instruction;       // 輸出指令

    //====================================================================
    // For mem (Data Memory / Cache)
    //====================================================================
    reg         mem_read;          // 資料讀取控制訊號
    reg         mem_write;         // 資料寫入控制訊號
    reg  [31:0] address;           // 資料存取位址
    reg  [31:0] write_data;        // 要寫入的資料
    wire [31:0] read_data;         // 從 mem 模組讀出的資料

    //====================================================================
    // Clock Generation
    //====================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 週期 10 ns
    end

    //====================================================================
    // Instantiate if_cache (Instruction Cache)
    //====================================================================
    if_cache u_if_cache (
        .clk(clk),
        .reset(reset),
        .if_addr(if_addr),
        .instruction(instruction)
    );

    //====================================================================
    // Instantiate mem (Data Memory / Set-Associative Cache)
    //====================================================================
    mem u_mem (
        .clk(clk),
        .reset(reset),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    //====================================================================
    // Test Sequence
    //====================================================================
    initial begin
        // 初始設定：啟動 reset
        reset      = 1;
        if_addr    = 32'h0;
        mem_read   = 0;
        mem_write  = 0;
        address    = 32'h0;
        write_data = 32'h0;
        #20;   // 讓 reset 持續一段時間
        reset = 0;
        
        //-------------------------------
        // Test Part 1: if_cache (Instruction Cache)
        //-------------------------------
        $display("=== Testing if_cache (Instruction Cache) ===");
        
        // 模擬讀取不同的取指位址
        if_addr = 32'h00000000;
        #10;
        $display("if_addr = %h, instruction = %h", if_addr, instruction);
        
        if_addr = 32'h00000004;
        #10;
        $display("if_addr = %h, instruction = %h", if_addr, instruction);
        
        if_addr = 32'h00000008;
        #10;
        $display("if_addr = %h, instruction = %h", if_addr, instruction);
        
        //-------------------------------
        // Test Part 2: mem (Data Memory / Cache)
        //-------------------------------
        $display("=== Testing mem (Data Memory / Cache) ===");
        
        // Test Case 1: 讀取 miss (假設主記憶體初始值為 0)
        address  = 32'h00000010;
        mem_read = 1;
        #10;
        mem_read = 0;
        $display("Test Case 1: Read miss at address %h, read_data = %h", address, read_data);
        
        // Test Case 2: 寫入操作 (write-through & write-allocate)
        address    = 32'h00000010;
        write_data = 32'hDEADBEEF;
        mem_write  = 1;
        #10;
        mem_write  = 0;
        
        // Test Case 3: 讀取 hit (應回傳剛寫入的值)
        address  = 32'h00000010;
        mem_read = 1;
        #10;
        mem_read = 0;
        $display("Test Case 3: Read hit at address %h, read_data = %h", address, read_data);
        
        // Test Case 4: 另一個地址（不同 index），預期 miss讀取主記憶體初始值
        address  = 32'h00000100;
        mem_read = 1;
        #10;
        mem_read = 0;
        $display("Test Case 4: Read miss at address %h, read_data = %h", address, read_data);
        
        // Test Case 5: 對新地址進行寫入並讀回驗證
        address    = 32'h00000100;
        write_data = 32'hCAFEBABE;
        mem_write  = 1;
        #10;
        mem_write  = 0;
        address    = 32'h00000100;
        mem_read   = 1;
        #10;
        mem_read   = 0;
        $display("Test Case 5: Read hit at address %h after write, read_data = %h", address, read_data);
        
        $finish;
    end

endmodule
