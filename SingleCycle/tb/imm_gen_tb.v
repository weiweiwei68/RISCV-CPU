// tb/imm_gen_tb.v
`timescale 1ns/1ps

module imm_gen_tb;
    reg [31:0] instr;
    reg [1:0]  imm_sel;
    wire [31:0] imm;

    imm_gen dut(
        .instr(instr),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    initial begin
        // I-type: imm[11:0] = 0xFFC (-4)
        instr = 32'b0;
        instr[31:20] = 12'hFFC;
        imm_sel = 2'b00;
        #1;
        if (imm !== 32'hFFFF_FFFC) begin
            $display("FAIL I: got %h", imm);
            $display("TEST FAILED");
            $finish;
        end

        // S-type: imm = 0xFFC (-4) split across [31:25] and [11:7]
        instr = 32'b0;
        instr[31:25] = 7'b1111111;    // imm[11:5]
        instr[11:7]  = 5'b11100;       // imm[4:0] => 0b11100 = 0x1C; combined should be 0xFFC
        imm_sel = 2'b01;
        #1;
        if (imm !== 32'hFFFF_FFFC) begin
            $display("FAIL S: got %h", imm);
            $display("TEST FAILED");
            $finish;
        end

        // B-type: make offset = -4 (0x...FFC), but B-type has LSB 0 so -4 is representable
        // Encoding: imm[12|10:5|4:1|11] spread; we'll set field for -4
        // For -4, offset bits (including bit0=0): 0b1_111111_1110_0 (13 bits) = 0x1FFC (as signed)
        instr = 32'd0;
        instr[31]    = 1'b1;         // imm[12]
        instr[30:25] = 6'b111111;    // imm[10:5]
        instr[11:8]  = 4'b1110;      // imm[4:1]
        instr[7]     = 1'b1;         // imm[11]
        imm_sel      = 2'b10;
        #1;
        if (imm !== 32'hFFFF_FFFC) begin
            $display("FAIL B: got %h", imm);
            $display("TEST FAILED");
            $finish;
        end


        $display("PASS: imm_gen test");
        $finish;
    end
endmodule