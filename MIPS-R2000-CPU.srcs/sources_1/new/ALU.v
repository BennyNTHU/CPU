`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Benny Lee
// 
// Create Date: 2025/02/23
// Design Name: MIPS R2000 ALU
// Module Name: ALU
// Project Name: 
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: A simple ALU for MIPS pipeline EX stage
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ALU(
    input  wire [31:0] a,        // ALU input A
    input  wire [31:0] b,        // ALU input B
    input  wire [3:0]  alu_ctrl, // ALU control signal (from ALU Control unit)
    output reg  [31:0] result,
    output wire        zero      // result == 0 ?
);

    // zero flag 當 result == 0 時為 1
    assign zero = (result == 32'b0);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a & b;     // AND
            4'b0001: result = a | b;     // OR
            4'b0010: result = a + b;     // ADD
            4'b0110: result = a - b;     // SUB
            4'b0111: result = (a < b) ? 32'b1 : 32'b0; // SLT
            default: result = 32'b0;     // 預設回傳 0
        endcase
    end

endmodule
