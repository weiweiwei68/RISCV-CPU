// tb/alu_tb.v
`timescale 1ns/1ps

module alu_tb;
    reg [31:0] a, b;
    reg [2:0] alu_ctrl;
    wire [31:0] y;
    wire zero;

    alu dut(
        .a(a), .b(b),
        .alu_ctrl(alu_ctrl),
        .y(y),
        .zero(zero)
    );

    initial begin
        // add
        a = 32'd10; b = 32'd20; alu_ctrl = 3'b000;
        #1;
        if (y !== 32'd30) begin $display("FAIL add"); $finish; end

        //sub
        a = 32'd7; b = 32'd7; alu_ctrl = 3'b001;
        #1;
        if (y !== 32'd0 || zero !== 1'b1) begin $display("FAIL sub/zero y=%0d zero=%b", y, zero); $finish; end

        // and
        a = 32'hF0F0_F0F0; b = 32'h0FF0_00FF; alu_ctrl = 3'b010;
        #1;
        if (y !== (32'hF0F0_F0F0 & 32'h0FF0_00FF)) begin $display("FAIL and"); $finish; end

        // or
        alu_ctrl = 3'b011;
        #1;
        if (y !== (32'hF0F0_F0F0 | 32'h0FF0_00FF)) begin $display("FAIL or"); $finish; end


        $display("PASS: alu test");
        $finish;
    end
endmodule