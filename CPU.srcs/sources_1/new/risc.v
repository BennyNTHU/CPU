module RISC_V_CPU (
    input clk, reset
);
    reg [63:0] pc;
    reg [63:0] registers [0:31]; // 32 個 64-bit 寄存器
    wire [63:0] instruction, read_data1, read_data2, alu_result, mem_data;
    wire [3:0] alu_ctrl;

    // **IF 階段**
    Cache instruction_cache (
        .clk(clk),
        .address(pc),
        .mem_read(1'b1),
        .mem_write(1'b0),
        .read_data(instruction)
    );

    // **ID 階段**
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd = instruction[11:7];
    assign read_data1 = registers[rs1];
    assign read_data2 = registers[rs2];

    // **EX 階段**
    ALU alu_unit (
        .opA(read_data1),
        .opB(read_data2),
        .alu_ctrl(alu_ctrl),
        .result(alu_result)
    );

    // **MEM 階段**
    Cache data_cache (
        .clk(clk),
        .address(alu_result),
        .write_data(read_data2),
        .mem_read(1'b1),
        .mem_write(1'b0),
        .read_data(mem_data)
    );

    // **WB 階段**
    always @(posedge clk) begin
        if (rd != 0) registers[rd] <= mem_data;
    end

    // **PC 更新**
    always @(posedge clk or posedge reset) begin
        if (reset) pc <= 0;
        else pc <= pc + 4; // 預設 PC += 4
    end

endmodule
