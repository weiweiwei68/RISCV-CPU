// tb/fetch_tb.v
`timescale 1ns/1ps

module fetch_tb;
    reg clk = 0;
    reg rst = 1;
    wire [31:0] pc_cur;
    wire [31:0] instr;

    fetch_top dut(
        .clk(clk),
        .rst(rst),
        .pc_cur(pc_cur),
        .instr(instr)
    );

    always #5 clk = ~clk;

    initial begin
        #12 rst = 0;

        #1;
        $display("pc=%h instr=%h", pc_cur, instr);
        repeat (10) begin
            #10;
            $display("pc=%h instr=%h", pc_cur, instr);
        end

        $finish;
    end
endmodule