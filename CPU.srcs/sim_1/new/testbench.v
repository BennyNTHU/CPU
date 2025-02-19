`timescale 1ns / 1ps

module RISC_V_CPU_Testbench();

    reg clk, reset;
    
    // 建立 CPU 實例
    RISC_V_CPU cpu (
        .clk(clk),
        .reset(reset)
    );

    // 時脈產生器
    always #5 clk = ~clk; // 10ns 週期 (100MHz)

    initial begin
        // 初始化
        clk = 0;
        reset = 1;
        #10;
        reset = 0;

        // 模擬指令記憶體初始化
        cpu.instruction_cache.cache_mem[0] = 64'h002081B3; // ADD x3, x1, x2
        cpu.instruction_cache.cache_mem[1] = 64'h40320233; // SUB x4, x4, x3
        cpu.instruction_cache.cache_mem[2] = 64'h00410133; // ADD x2, x2, x4
        cpu.instruction_cache.cache_mem[3] = 64'h00000063; // BEQ x0, x0, 0 (NOP)
        cpu.instruction_cache.cache_mem[4] = 64'hFFFFFFFF; // HALT (模擬停止)

        // 初始化寄存器
        cpu.registers[1] = 64'd10;
        cpu.registers[2] = 64'd20;
        cpu.registers[4] = 64'd50;

        // 模擬一段時間
        #100;

        // 顯示寄存器狀態
        $display("Register x3 = %d", cpu.registers[3]);  // 應該是 x1 + x2 = 30
        $display("Register x4 = %d", cpu.registers[4]);  // 應該是 x4 - x3 = 50 - 30 = 20
        $display("Register x2 = %d", cpu.registers[2]);  // 應該是 x2 + x4 = 20 + 20 = 40

        // 測試數據快取
        cpu.data_cache.cache_mem[5] = 64'd100; // 初始化記憶體位址 5

        // 執行 LW (讀取)
        cpu.data_cache.mem_read = 1;
        cpu.data_cache.address = 64'd5;
        #10;
        $display("Memory Read from Address 5: %d", cpu.data_cache.read_data); // 應該是 100

        // 測試 SW (寫入)
        cpu.data_cache.mem_write = 1;
        cpu.data_cache.write_data = 64'd200;
        cpu.data_cache.address = 64'd5;
        #10;
        cpu.data_cache.mem_write = 0;

        // 再次讀取以驗證
        cpu.data_cache.mem_read = 1;
        #10;
        $display("Memory Read from Address 5 (after write): %d", cpu.data_cache.read_data); // 應該是 200

        // 停止模擬
        $finish;
    end

endmodule
