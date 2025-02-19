module Cache (
    input clk,
    input [63:0] address,
    input [63:0] write_data,
    input mem_read, mem_write,
    output reg [63:0] read_data
);

    reg [63:0] cache_mem [0:255]; // 假設 256 行，每行 64-bit
    reg [63:0] tag_mem [0:255];

    always @(posedge clk) begin
        if (mem_write) begin
            cache_mem[address[7:0]] <= write_data;
            tag_mem[address[7:0]] <= address[63:8]; 
        end
        if (mem_read) begin
            if (tag_mem[address[7:0]] == address[63:8])
                read_data <= cache_mem[address[7:0]]; // 命中
            else
                read_data <= 64'hDEADBEEF; // 模擬 Cache Miss
        end
    end
endmodule
