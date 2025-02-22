`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Benny Lee
// 
// Create Date: 2025/02/23
// Design Name: MIPS R2000 Pipeline Datapath
// Module Name: pipeline
// Project Name: 
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: 5-stage pipelined datapath (IF, ID, EX, MEM, WB)
//              Hazard & Exception not yet implemented.
//              此版本已整合 ALU、alu_control，並新增 pc_out 輸出供 IF Cache 使用。
// 
// Dependencies: ALU.v, alu_control.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module pipeline(
    input  wire        clk,
    input  wire        reset,

    // Control signals from control unit
    input  wire        RegDst,
    input  wire        ALUSrc,
    input  wire        MemtoReg,
    input  wire        RegWrite,
    input  wire        MemRead,
    input  wire        MemWrite,
    input  wire        Branch,
    input  wire [1:0]  ALUOp,
    input  wire        Jump,

    // Instruction input from IF stage (if_cache)
    input  wire [31:0] instruction,

    // Memory interface for data access (from data memory)
    input  wire [31:0] mem_data_in,   // Data read from Data Memory
    output wire [31:0] mem_data_out,  // Data to write to Data Memory
    output wire [31:0] mem_addr,      // Memory address for data access

    // 新增：輸出目前的 PC 值，供 IF Cache 使用
    output wire [31:0] pc_out
);

    // =========================================================================
    // (1) IF Stage
    // =========================================================================
    // PC: 簡易的程式計數器 (每個 cycle 加 4)
    reg [31:0] pc;
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 0;
        else
            pc <= pc + 4;  // 後續可加入分支/跳躍修正
    end

    // 將目前 PC 直接輸出給 IF Cache
    assign pc_out = pc;

    // IF/ID Pipeline Register：儲存從 IF 階段取得的指令與 PC+4
    reg [31:0] IFID_instr;
    reg [31:0] IFID_pc_next;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IFID_instr   <= 32'b0;
            IFID_pc_next <= 32'b0;
        end else begin
            IFID_instr   <= instruction; // 從 IF Cache 取得指令
            IFID_pc_next <= pc + 4;
        end
    end

    // =========================================================================
    // (2) ID Stage
    // =========================================================================
    // 指令欄位解析 (假設標準 MIPS 格式)
    wire [4:0] rs   = IFID_instr[25:21];
    wire [4:0] rt   = IFID_instr[20:16];
    wire [4:0] rd   = IFID_instr[15:11];
    wire [15:0] imm = IFID_instr[15:0];
    // Sign-extend immediate
    wire [31:0] sign_ext_imm = {{16{imm[15]}}, imm};

    // 簡易的寄存器檔 (Register File)
    reg [31:0] regfile [0:31];
    wire [31:0] reg_data1 = regfile[rs];
    wire [31:0] reg_data2 = regfile[rt];

    // ID/EX Pipeline Registers：傳遞控制訊號與資料
    reg        IDEX_RegDst;
    reg        IDEX_ALUSrc;
    reg        IDEX_MemtoReg;
    reg        IDEX_RegWrite;
    reg        IDEX_MemRead;
    reg        IDEX_MemWrite;
    reg        IDEX_Branch;
    reg [1:0]  IDEX_ALUOp;
    reg        IDEX_Jump;
    reg [31:0] IDEX_reg_data1;
    reg [31:0] IDEX_reg_data2;
    reg [31:0] IDEX_sign_ext_imm;
    reg [4:0]  IDEX_rs;
    reg [4:0]  IDEX_rt;
    reg [4:0]  IDEX_rd;
    reg [31:0] IDEX_pc_next;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IDEX_RegDst       <= 0;
            IDEX_ALUSrc       <= 0;
            IDEX_MemtoReg     <= 0;
            IDEX_RegWrite     <= 0;
            IDEX_MemRead      <= 0;
            IDEX_MemWrite     <= 0;
            IDEX_Branch       <= 0;
            IDEX_ALUOp        <= 2'b00;
            IDEX_Jump         <= 0;
            IDEX_reg_data1    <= 32'b0;
            IDEX_reg_data2    <= 32'b0;
            IDEX_sign_ext_imm <= 32'b0;
            IDEX_rs           <= 5'b0;
            IDEX_rt           <= 5'b0;
            IDEX_rd           <= 5'b0;
            IDEX_pc_next      <= 32'b0;
        end else begin
            IDEX_RegDst       <= RegDst;
            IDEX_ALUSrc       <= ALUSrc;
            IDEX_MemtoReg     <= MemtoReg;
            IDEX_RegWrite     <= RegWrite;
            IDEX_MemRead      <= MemRead;
            IDEX_MemWrite     <= MemWrite;
            IDEX_Branch       <= Branch;
            IDEX_ALUOp        <= ALUOp;
            IDEX_Jump         <= Jump;
            IDEX_reg_data1    <= reg_data1;
            IDEX_reg_data2    <= reg_data2;
            IDEX_sign_ext_imm <= sign_ext_imm;
            IDEX_rs           <= rs;
            IDEX_rt           <= rt;
            IDEX_rd           <= rd;
            IDEX_pc_next      <= IFID_pc_next;
        end
    end

    // =========================================================================
    // (3) EX Stage
    // =========================================================================
    // 呼叫 ALU 控制單元，根據 IDEX_ALUOp 與（此處簡化使用 sign_ext_imm 的低 6 位作為 Funct）產生 alu_ctrl
    wire [3:0] alu_ctrl;
    alu_control alu_ctrl_unit (
        .ALUOp    (IDEX_ALUOp),
        .Funct    (IDEX_sign_ext_imm[5:0]),
        .alu_ctrl (alu_ctrl)
    );

    // 選擇 ALU 輸入 B
    wire [31:0] alu_src_b = (IDEX_ALUSrc) ? IDEX_sign_ext_imm : IDEX_reg_data2;

    // 呼叫 ALU 模組 (來自 ALU.v)
    wire [31:0] alu_result;
    wire        alu_zero;
    ALU alu_inst (
        .a        (IDEX_reg_data1),
        .b        (alu_src_b),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),
        .zero     (alu_zero)
    );

    // 決定目的暫存器 (RegDst 控制)
    wire [4:0] reg_dest = (IDEX_RegDst) ? IDEX_rd : IDEX_rt;

    // 計算 branch 位址 (簡單示範：PC+4 + immediate<<2)
    wire [31:0] branch_addr = IDEX_pc_next + (IDEX_sign_ext_imm << 2);

    // EX/MEM Pipeline Registers
    reg        EXMEM_MemtoReg;
    reg        EXMEM_RegWrite;
    reg        EXMEM_MemRead;
    reg        EXMEM_MemWrite;
    reg        EXMEM_Branch;
    reg        EXMEM_Jump;
    reg [31:0] EXMEM_alu_result;
    reg [31:0] EXMEM_reg_data2;
    reg [4:0]  EXMEM_reg_dest;
    reg        EXMEM_zero;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EXMEM_MemtoReg   <= 0;
            EXMEM_RegWrite   <= 0;
            EXMEM_MemRead    <= 0;
            EXMEM_MemWrite   <= 0;
            EXMEM_Branch     <= 0;
            EXMEM_Jump       <= 0;
            EXMEM_alu_result <= 32'b0;
            EXMEM_reg_data2  <= 32'b0;
            EXMEM_reg_dest   <= 5'b0;
            EXMEM_zero       <= 1'b0;
        end else begin
            EXMEM_MemtoReg   <= IDEX_MemtoReg;
            EXMEM_RegWrite   <= IDEX_RegWrite;
            EXMEM_MemRead    <= IDEX_MemRead;
            EXMEM_MemWrite   <= IDEX_MemWrite;
            EXMEM_Branch     <= IDEX_Branch;
            EXMEM_Jump       <= IDEX_Jump;
            EXMEM_alu_result <= alu_result;
            EXMEM_reg_data2  <= IDEX_reg_data2;
            EXMEM_reg_dest   <= reg_dest;
            EXMEM_zero       <= alu_zero;
        end
    end

    // =========================================================================
    // (4) MEM Stage
    // =========================================================================
    // 與外部 Data Memory 互動
    assign mem_addr     = EXMEM_alu_result;
    assign mem_data_out = EXMEM_reg_data2;

    // MEM/WB Pipeline Registers
    reg        MEMWB_MemtoReg;
    reg        MEMWB_RegWrite;
    reg [31:0] MEMWB_alu_result;
    reg [31:0] MEMWB_mem_data;
    reg [4:0]  MEMWB_reg_dest;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEMWB_MemtoReg   <= 0;
            MEMWB_RegWrite   <= 0;
            MEMWB_alu_result <= 32'b0;
            MEMWB_mem_data   <= 32'b0;
            MEMWB_reg_dest   <= 5'b0;
        end else begin
            MEMWB_MemtoReg   <= EXMEM_MemtoReg;
            MEMWB_RegWrite   <= EXMEM_RegWrite;
            MEMWB_alu_result <= EXMEM_alu_result;
            MEMWB_mem_data   <= mem_data_in;  // 從 Data Memory 讀取
            MEMWB_reg_dest   <= EXMEM_reg_dest;
        end
    end

    // =========================================================================
    // (5) WB Stage
    // =========================================================================
    // 寫回寄存器檔
    wire [31:0] wb_data = (MEMWB_MemtoReg) ? MEMWB_mem_data : MEMWB_alu_result;
    always @(posedge clk) begin
        if (MEMWB_RegWrite && (MEMWB_reg_dest != 5'b0))
            regfile[MEMWB_reg_dest] <= wb_data;
    end

endmodule
