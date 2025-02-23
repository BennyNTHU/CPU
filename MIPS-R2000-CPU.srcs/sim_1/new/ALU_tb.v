`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Benny Lee
// 
// Create Date: 2025/02/23
// Design Name: Testbench for ALU
// Module Name: ALU_tb
// Project Name: MIPS R2000 CPU
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: Testbench for the ALU module.
//              測試 AND, OR, ADD, SUB, SLT 五種運算
// 
// Dependencies: ALU.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ALU_tb;

    // Inputs
    reg  [31:0] a;
    reg  [31:0] b;
    reg  [3:0]  alu_ctrl;
    
    // Outputs
    wire [31:0] result;
    wire        zero;
    
    // Instantiate the ALU module
    ALU dut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );
    
    initial begin
        $display("Time\t\t a\t\t  b\t\t alu_ctrl \t result\t\t zero");
        $monitor("%0t\t %h\t %h\t %b\t %h\t %b", $time, a, b, alu_ctrl, result, zero);
        
        // Test AND operation: alu_ctrl = 0000
        a = 32'hF0F0_F0F0; b = 32'h0FF0_0FF0; alu_ctrl = 4'b0000;
        #10;
        
        // Test OR operation: alu_ctrl = 0001
        a = 32'hF0F0_F0F0; b = 32'h0FF0_0FF0; alu_ctrl = 4'b0001;
        #10;
        
        // Test ADD operation: alu_ctrl = 0010
        a = 32'h0000_0010; b = 32'h0000_0020; alu_ctrl = 4'b0010;
        #10;
        
        // Test SUB operation: alu_ctrl = 0110
        a = 32'h0000_0030; b = 32'h0000_0010; alu_ctrl = 4'b0110;
        #10;
        
        // Test SLT operation: alu_ctrl = 0111, a < b
        a = 32'h0000_0010; b = 32'h0000_0020; alu_ctrl = 4'b0111;
        #10;
        
        // Test SLT operation: alu_ctrl = 0111, a >= b
        a = 32'h0000_0020; b = 32'h0000_0010; alu_ctrl = 4'b0111;
        #10;
        
        $finish;
    end

endmodule
