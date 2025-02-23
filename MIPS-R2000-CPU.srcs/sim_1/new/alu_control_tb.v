`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Benny Lee
// 
// Create Date: 2025/02/23
// Design Name: alu_control Testbench
// Module Name: alu_control_tb
// Project Name: MIPS R2000 CPU
// Target Devices: None
// Tool Versions: Vivado 2024.2
// Description: Testbench for the alu_control module. It tests various
//              combinations of ALUOp and Funct fields and verifies the
//              corresponding alu_ctrl output.
// 
// Dependencies: alu_control.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module alu_control_tb;

    // Inputs
    reg [1:0] ALUOp;
    reg [5:0] Funct;
    
    // Output
    wire [3:0] alu_ctrl;
    
    // Instantiate the Unit Under Test (UUT)
    alu_control uut (
        .ALUOp(ALUOp),
        .Funct(Funct),
        .alu_ctrl(alu_ctrl)
    );
    
    initial begin
        $display("Time\t ALUOp  Funct\t alu_ctrl");
        $monitor("%0t\t %b\t %b\t %b", $time, ALUOp, Funct, alu_ctrl);
        
        // Test case 1: lw/sw -> ALUOp = 2'b00, expecting ADD (4'b0010)
        ALUOp = 2'b00; Funct = 6'bxxxxxx; // Funct ignored in this case
        #10;
        
        // Test case 2: beq -> ALUOp = 2'b01, expecting SUB (4'b0110)
        ALUOp = 2'b01; Funct = 6'bxxxxxx;
        #10;
        
        // Test case 3: R-type ADD: ALUOp = 2'b10, Funct = 6'b100000 -> ADD (4'b0010)
        ALUOp = 2'b10; Funct = 6'b100000;
        #10;
        
        // Test case 4: R-type SUB: ALUOp = 2'b10, Funct = 6'b100010 -> SUB (4'b0110)
        ALUOp = 2'b10; Funct = 6'b100010;
        #10;
        
        // Test case 5: R-type AND: ALUOp = 2'b10, Funct = 6'b100100 -> AND (4'b0000)
        ALUOp = 2'b10; Funct = 6'b100100;
        #10;
        
        // Test case 6: R-type OR: ALUOp = 2'b10, Funct = 6'b100101 -> OR (4'b0001)
        ALUOp = 2'b10; Funct = 6'b100101;
        #10;
        
        // Test case 7: R-type SLT: ALUOp = 2'b10, Funct = 6'b101010 -> SLT (4'b0111)
        ALUOp = 2'b10; Funct = 6'b101010;
        #10;
        
        // Test case 8: R-type Unknown: ALUOp = 2'b10, Funct = 6'b111111 -> Default (4'b1111)
        ALUOp = 2'b10; Funct = 6'b111111;
        #10;
        
        $finish;
    end

endmodule
