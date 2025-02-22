`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Benny Lee
// 
// Create Date: 2025/02/23
// Design Name: MIPS R2000 Data Memory (Set-Associative)
// Module Name: mem
// Project Name: 
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: Data Memory module with 2-way set-associative cache.
//              實作 write-through, write-allocate 策略，
//              當 cache miss 時從主記憶體讀取並更新 cache。
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module mem(
    input  wire        clk,
    input  wire        reset,
    input  wire        mem_read,     // 資料讀取控制訊號
    input  wire        mem_write,    // 資料寫入控制訊號
    input  wire [31:0] address,      // 資料存取位址
    input  wire [31:0] write_data,   // 要寫入的資料
    output reg  [31:0] read_data     // 讀取出的資料
);

    //-------------------------------------------------------------------------
    // 參數定義
    //-------------------------------------------------------------------------
    parameter NUM_SETS    = 16;         // Set 數量 (4 bits index)
    parameter WAYS        = 2;          // 2-way associative
    parameter OFFSET_BITS = 2;          // 4 bytes per block
    parameter INDEX_BITS  = 4;          // log2(NUM_SETS) = 4
    parameter TAG_BITS    = 32 - OFFSET_BITS - INDEX_BITS; // 26 bits tag
    parameter MEM_WORDS   = 256;        // 主記憶體大小 (256 個 32-bit 字)

    //-------------------------------------------------------------------------
    // Cache arrays: 每個 set 有 2 個 ways
    //-------------------------------------------------------------------------
    // 有效位元
    reg valid [0:NUM_SETS-1][0:WAYS-1];
    // Tag 存放陣列
    reg [TAG_BITS-1:0] tag_array [0:NUM_SETS-1][0:WAYS-1];
    // 資料存放陣列 (每個 cache line 儲存一個 32-bit 字)
    reg [31:0] cache_data [0:NUM_SETS-1][0:WAYS-1];
    // 每個 set 的 LRU 位元：對於 2-way，只需要 1 bit，若為 0，表示第 0 路為最近使用，
    // victim 選擇則為 1；反之亦然。
    reg lru [0:NUM_SETS-1];

    //-------------------------------------------------------------------------
    // 模擬主記憶體 (直接用一個陣列表示)
    //-------------------------------------------------------------------------
    reg [31:0] main_mem [0:MEM_WORDS-1];

    //-------------------------------------------------------------------------
    // 地址解碼：將 address 拆解成 tag 與 index
    //-------------------------------------------------------------------------
    wire [INDEX_BITS-1:0] index  = address[OFFSET_BITS+INDEX_BITS-1:OFFSET_BITS]; 
    wire [TAG_BITS-1:0]   tag_in = address[31:OFFSET_BITS+INDEX_BITS];
    // 將 address 的 [31:2] 當作主記憶體的字位址 (假設 MEM_WORDS 足夠大)
    wire [7:0] main_mem_index = address[9:2]; // 當 MEM_WORDS = 256

    //-------------------------------------------------------------------------
    // Hit 判斷 (combinational)
    //-------------------------------------------------------------------------
    integer way;
    reg hit;
    reg hit_way; // 由於 2-way，只需 1 bit (0 或 1)
    always @(*) begin
        hit = 0;
        hit_way = 0;
        for (way = 0; way < WAYS; way = way + 1) begin
            if ( valid[index][way] && (tag_array[index][way] == tag_in) ) begin
                hit = 1;
                hit_way = way[0];
            end
        end
    end

    //-------------------------------------------------------------------------
    // 主同步區塊：處理讀/寫操作及 cache 填充 (fill)
    //-------------------------------------------------------------------------
    integer i, j;
    always @(posedge clk) begin
        if (reset) begin
            read_data <= 32'b0;
            // 初始化 cache 與 LRU
            for (i = 0; i < NUM_SETS; i = i + 1) begin
                lru[i] <= 0;
                for (j = 0; j < WAYS; j = j + 1) begin
                    valid[i][j] <= 1'b0;
                    tag_array[i][j] <= {TAG_BITS{1'b0}};
                    cache_data[i][j] <= 32'b0;
                end
            end
            // 初始化主記憶體 (可依需要設定初始值)
            for (i = 0; i < MEM_WORDS; i = i + 1) begin
                main_mem[i] <= 32'b0;
            end
        end else begin
            // 處理讀取操作 (優先讀)
            if (mem_read) begin
                if (hit) begin
                    // Hit：從 cache 中讀取資料
                    read_data <= cache_data[index][hit_way];
                    // 更新 LRU：若從 way 0 命中，則標記 victim 為 1，否則為 0
                    lru[index] <= (hit_way == 1'b0) ? 1'b1 : 1'b0;
                end else begin
                    // Miss：從主記憶體讀取，並以 write-allocate 方式填入 cache
                    read_data <= main_mem[main_mem_index];
                    cache_data[index][lru[index]] <= main_mem[main_mem_index];
                    tag_array[index][lru[index]] <= tag_in;
                    valid[index][lru[index]] <= 1'b1;
                    // 更新 LRU：填入後切換 victim指標
                    lru[index] <= ~lru[index];
                end
            end

            // 處理寫入操作 (write-through 策略)
            if (mem_write) begin
                if (hit) begin
                    // 寫命中：更新 cache 與主記憶體
                    cache_data[index][hit_way] <= write_data;
                    main_mem[main_mem_index] <= write_data;
                    lru[index] <= (hit_way == 1'b0) ? 1'b1 : 1'b0;
                end else begin
                    // 寫未命中：直接寫入主記憶體，同時進行 write-allocate
                    main_mem[main_mem_index] <= write_data;
                    cache_data[index][lru[index]] <= write_data;
                    tag_array[index][lru[index]] <= tag_in;
                    valid[index][lru[index]] <= 1'b1;
                    lru[index] <= ~lru[index];
                end
            end
        end
    end

endmodule
