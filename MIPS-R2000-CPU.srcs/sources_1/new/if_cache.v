`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Benny Lee
// 
// Create Date: 2025/02/23
// Design Name: MIPS R2000 IF Cache
// Module Name: if_cache
// Project Name: 
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: Instruction Cache using direct-mapped scheme.
//              當 cache miss 時，模擬填入預設值 32'hDEADBEEF。
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module if_cache(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] if_addr,       // 指令記憶體存取位址 (來自 IF 階段)
    output wire [31:0] instruction    // 取出的 32-bit 指令
);

    //--------------------------------------------------------------------------
    // 參數定義：假設快取有 64 行，每行 4 bytes (1 word)
    //--------------------------------------------------------------------------
    parameter CACHE_LINES = 64;
    parameter OFFSET_BITS = 2;  // 4 bytes 每行
    parameter INDEX_BITS  = 6;  // 2^6 = 64 行
    parameter TAG_BITS    = 32 - OFFSET_BITS - INDEX_BITS;  // 24 bits tag

    //--------------------------------------------------------------------------
    // Cache 資料結構：有效位、tag 與資料陣列
    //--------------------------------------------------------------------------
    reg                   valid [0:CACHE_LINES-1];
    reg [TAG_BITS-1:0]    tag_array [0:CACHE_LINES-1];
    reg [31:0]            data_array [0:CACHE_LINES-1];

    //--------------------------------------------------------------------------
    // 地址解碼：拆解出 index 與 tag
    //--------------------------------------------------------------------------
    wire [INDEX_BITS-1:0] index  = if_addr[OFFSET_BITS+INDEX_BITS-1:OFFSET_BITS];
    wire [TAG_BITS-1:0]   tag_in = if_addr[31:OFFSET_BITS+INDEX_BITS];

    //--------------------------------------------------------------------------
    // Hit 判斷：如果該 index 的 valid 為 1 且 tag 相符，則命中
    //--------------------------------------------------------------------------
    wire hit = valid[index] && (tag_array[index] == tag_in);

    //--------------------------------------------------------------------------
    // Cache 讀取與缺失填充 (synchronous)
    //--------------------------------------------------------------------------
    // 注意：在真實系統中，缺失時會向較慢的 ROM 發出請求，
    // 這裡簡單以 32'hDEADBEEF 代表缺失回應，並更新 cache。
    always @(posedge clk) begin
        if (reset) begin
            integer i;
            for(i = 0; i < CACHE_LINES; i = i + 1) begin
                valid[i]      <= 1'b0;
                tag_array[i]  <= {TAG_BITS{1'b0}};
                data_array[i] <= 32'b0;
            end
        end else begin
            if (!hit) begin
                // 模擬 cache miss：填入預設值，並更新 tag 與 valid
                data_array[index] <= 32'hDEADBEEF;
                tag_array[index]  <= tag_in;
                valid[index]      <= 1'b1;
            end
        end
    end

    //--------------------------------------------------------------------------
    // 輸出：若命中則輸出快取資料，否則輸出預設缺失值
    //--------------------------------------------------------------------------
    assign instruction = (hit) ? data_array[index] : 32'hDEADBEEF;

endmodule
