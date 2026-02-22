// tb/decoder_tb.v
`timescale 1ns/1ps

module decoder_tb;
    reg  [31:0] instr;
    wire reg_writer, mem_read, mem_write, alu_src, mem_to_reg, branch;
    wire [1:0] imm_sel;
    wire [2:0] alu_ctrl;

    decoder dut(
        .instr(instr),
        .reg_writer(reg_writer),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .imm_sel(imm_sel),
        .alu_ctrl(alu_ctrl)
    );

    initial begin
        // add: opcode=0110011 funct3=000 funct7=0000000
        instr = 32'b0;
        instr[6:0] = 7'b0110011;
        instr[14:12] = 3'b000;
        instr[31:25] = 7'b0000000;
        #1;
        if (!(reg_writer && !mem_read && !mem_write && !alu_src && !mem_to_reg && !branch && alu_ctrl==3'b000)) begin
            $display("FAIL add controls");
            $finish;
        end

        // sub: funct7=0111111
        instr[31:25] = 7'b0100000;
        #1;
        if (!(reg_writer && !mem_read && !mem_write && !alu_src && !mem_to_reg && !branch && alu_ctrl == 3'b001)) begin
            $display("FAIL sub controls");
            $finish;
        end

        // lw: opcode=0000011
        instr = 32'b0;
        instr[6:0] = 7'b0000011;
        #1;
        if (!(reg_writer && mem_read && !mem_write && alu_src && mem_to_reg && imm_sel==2'b00 && !branch && alu_ctrl == 3'b000)) begin
            $display("FAIL lw controls");
            $finish;
        end

        // sw: opcode=0100011
        instr[6:0] = 7'b0100011;
        #1;
        if (!(!reg_writer && !mem_read && mem_write && alu_src && !mem_to_reg && imm_sel == 2'b01 && !branch && alu_ctrl == 3'b000)) begin
            $display("FAIL sw controls");
            $finish;
        end

        // beq: opcode=1100011
        instr [31:0] = 32'b0;
        instr[6:0] = 7'b1100011;
        #1;
        if (!(!reg_writer && !mem_read && !mem_write && !alu_src && !mem_to_reg && branch && imm_sel==2'b10 && alu_ctrl == 3'b001)) begin
            $display("FAIL beq controls");
            $finish;
        end

        $display("PASS: decoder test");
        $finish;
    end
endmodule