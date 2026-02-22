// tb/regfile_tb.v
`timescale 1ns/1ps

module regfile_tb;
    reg clk = 0;
    reg we;
    reg [4:0] ra1, ra2, wa;
    reg [31:0] wd;
    wire [31:0] rd1, rd2;

    regfile dut(
        .clk(clk),
        .we(we),
        .ra1(ra1),
        .ra2(ra2),
        .wa(wa),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    always #5 clk = ~clk;

    initial begin
        // default
        we = 0; ra1 = 0; ra2 = 0; wa = 0; wd = 0;

        // write x1 = 0x12345678
        #2;
        we = 1; wa = 5'd1; wd = 32'h1234_5678;
        #10; // one clock edge

        // read back x1
        we = 0; ra1 = 5'd1;
        #1;
        if (rd1 !== 32'h1234_5678) begin
            $display("FAIL: x1 expected 0x123456789, got %h", rd1);
            $display("TEST FAILED");
            $finish;
        end

        // try write x0 = 0xDEADBEEF (should be ignored)
        we = 1; wa = 5'd0; wd = 32'hDEADBEEF;
        #10;

        // read x0 should still be 0
        we = 0; ra1 = 5'd0;
        #1;
        if (rd1 !== 32'd0) begin
            $display("FAIL: x0 expected 0, got %h", rd1);
            $display("TEST FAILED");
            $finish;
        end

        $display("PASS: regfile test");
        $finish;
    end
endmodule