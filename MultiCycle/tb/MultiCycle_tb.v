// tb/MultiCPU_tb.v
`timescale 1ns/1ps

module MultiCPU_tb;
    reg clk = 0;
    reg rst = 1;

    // Instantiate the CPU
    cpu_top dut(.clk(clk), .rst(rst));

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    // --- DEGBUG: State String Decoding ---
    // This helps us see "FETCH" in the logs instead of "0"
    reg [47:0] state_name;
    // 6 chars * 8bits
    always @(*) begin
        case (dut.u_dec.current_state)
            3'd0: state_name = "FETCH ";
            3'd1: state_name = "DECODE";
            3'd2: state_name = "EXEC  ";
            3'd3: state_name = "MEM   ";
            3'd4: state_name = "WB    ";
            default: state_name = "UNK";
        endcase
    end

    // --- Monitor Execution
    initial begin
        //$dumpfile("cpu_wave.vcd");
        // For waveform viewing
        //$dumpvars(0, multiCPU_tb);
    end

    always @(posedge clk) begin
        if (!rst) begin
            // Print every cycle
            $display("Time: %4d | PC: %h | PC_pointer: %h | PC_next: %h | IR: %h | State: %s | A: %h | B: %h | ALU: %h | rs1: %h | rs2: %h",
                     $time, 
                     dut.pc_id,
                     dut.u_pc.pc_cur,
                     dut.u_pc.pc_next,
                     dut.IR,          // Inspecting the Instruction Register
                     state_name, 
                     dut.A, 
                     dut.B, 
                     dut.ALUOut,
                     dut.rs1,
                     dut.rs2);
        end
    end

    // --- Main Test Sequence ---
    initial begin
        // Reset sequence
        rst = 1;
        #12 rst = 0;

        $display("--- Starting Multi-Cycle Simulation ---");

        repeat (100) @(posedge clk);

        $display("--- Simulation Finished ---");

        // --- Verification ---
        $display("x1=%0d (Expected 5)", dut.u_rf.regs[1]);
        $display("x2=%0d (Expected 5)", dut.u_rf.regs[2]);
        $display("x3=%0d (Expected 9)", dut.u_rf.regs[3]);

        if (dut.u_rf.regs[1] !== 32'd5)  begin $display("FAIL: x1 mismatch"); $finish;
        end
        if (dut.u_rf.regs[2] !== 32'd5)  begin $display("FAIL: x2 mismatch"); $finish;
        end
        if (dut.u_rf.regs[3] !== 32'd9)  begin $display("FAIL: x3 mismatch"); $finish;
        end

        $display("PASS: Multi-Cycle CPU Test Passed!");
        $finish;
    end
endmodule