// tb/pc_tb.v
`timescale 1ns/1ps

module pc_tb;
    reg clk = 0;
    reg rst = 1;
    reg [31:0] pc_next;
    wire [31:0] pc_cur;

    pc dut (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc_cur(pc_cur)
    );

    always #5 clk = ~clk;

    initial begin
        pc_next = 32'h0;

        // reset for 2 cycles
        #12 rst = 0;

        repeat (5) begin
            pc_next = pc_cur + 32'd4;
            #10;
        end

        $display("PC test done, pc_cur=%h", pc_cur);
        $finish;
    end
endmodule