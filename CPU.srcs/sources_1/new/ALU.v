module ALU (
    input  [63:0] opA, opB,   // ALU 操作數
    input  [3:0]  alu_ctrl,   // ALU 控制信號
    output reg [63:0] result, // 運算結果
    output zero              // 是否為零
);

    assign zero = (result == 0);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = opA + opB;    // 加法
            4'b0001: result = opA - opB;    // 減法
            4'b0010: result = opA & opB;    // AND
            4'b0011: result = opA | opB;    // OR
            4'b0100: result = opA ^ opB;    // XOR
            4'b0101: result = opA << opB;   // 左移
            4'b0110: result = opA >> opB;   // 右移
            4'b0111: result = ($signed(opA) < $signed(opB)) ? 1 : 0; // 小於比較
            default: result = 64'b0;
        endcase
    end
endmodule
