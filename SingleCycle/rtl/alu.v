// rtl/alu.v
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  alu_ctrl,    // 000:add, 001:sub, 010:and, 011:or
    output reg  [31:0] y,
    output wire        zero
);
    always @(*) begin
        case (alu_ctrl)
            3'b000: y = a + b;
            3'b001: y = a - b;
            3'b010: y = a & b;
            3'b011: y = a | b;
            default: y = 32'd0;
        endcase
    end

    assign zero = (y == 32'd0);
endmodule