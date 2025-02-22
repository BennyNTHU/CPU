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
// Description: Decodes ALUOp + Funct into ALU control signals
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module alu_control(
    input  wire [1:0] ALUOp,      // 來自控制單元
    input  wire [5:0] Funct,      // R-type 指令的 funct 欄位
    output reg  [3:0] alu_ctrl
);
    always @(*) begin
        case (ALUOp)
            2'b00: alu_ctrl = 4'b0010; // lw/sw -> add
            2'b01: alu_ctrl = 4'b0110; // beq   -> sub
            2'b10: begin
                // R-type
                case (Funct)
                    6'b100000: alu_ctrl = 4'b0010; // add
                    6'b100010: alu_ctrl = 4'b0110; // sub
                    6'b100100: alu_ctrl = 4'b0000; // and
                    6'b100101: alu_ctrl = 4'b0001; // or
                    6'b101010: alu_ctrl = 4'b0111; // slt
                    default:   alu_ctrl = 4'b1111; // 未定義
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end
endmodule
