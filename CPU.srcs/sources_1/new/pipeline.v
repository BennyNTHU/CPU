module Pipeline_Register (
    input clk,
    input [63:0] in_data,
    output reg [63:0] out_data
);
    always @(posedge clk) begin
        out_data <= in_data;
    end
endmodule
