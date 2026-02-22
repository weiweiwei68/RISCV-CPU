// tb/cpu_tb.v
`timescale 1ns/1ps

module cpu_tb;
    reg clk = 0;
    reg rst = 1;

    cpu_top dut(.clk(clk), .rst(rst));

    always #5 clk = ~clk;

    always @(posedge clk) begin
        #1;
        if (!rst) begin
            $display("WB: pc=%h we=%b rd=%0d wd=%h instr=%h",
                    dut.u_pc.pc_cur,
                    dut.u_rf.we,
                    dut.u_rf.wa,
                    dut.u_rf.wd,
                    dut.u_imem.instr);
        end
    end

    initial begin
        //reset
        #12 rst = 0;

        repeat (12) #10;

        $display("x1=%0d x2=%0d x3=%0d x4=%0d x5=%0d",
                 dut.u_rf.regs[1],
                 dut.u_rf.regs[2],
                 dut.u_rf.regs[3],
                 dut.u_rf.regs[4],
                 dut.u_rf.regs[5]);

        

        // register checks
        if (dut.u_rf.regs[1] !== 32'd5)  begin $display("FAIL x1"); $finish; end
        if (dut.u_rf.regs[2] !== 32'd5)  begin $display("FAIL x2"); $finish; end
        if (dut.u_rf.regs[3] !== 32'd9)  begin $display("FAIL x3"); $finish; end

        

        $display("PASS: single-cycle CPU beq test");
        $finish;
    end
endmodule