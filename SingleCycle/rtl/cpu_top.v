// rtl/cpu_top.v

module cpu_top (
    input  wire clk,
    input  wire rst
);
    // Debug
    wire [31:0] dbg_rd1  = rd1;
    wire [31:0] dbg_rd2  = rd2;
    wire        dbg_alu_src = alu_src;
    wire [2:0]  dbg_alu_ctrl = alu_ctrl;
    // PC + IMEM
    wire [31:0] pc_cur;
    wire [31:0] instr;
    //wire [31:0] pc_next = pc_cur + 32'd4;
    wire [31:0] pc_plus4 = pc_cur + 32'd4;
    wire [31:0] pc_branch = pc_cur + imm;
    wire        take_branch = branch && alu_zero;

    wire [31:0] pc_next = take_branch ? pc_branch : pc_plus4;
    pc u_pc(.clk(clk), .rst(rst), .pc_next(pc_next), .pc_cur(pc_cur));
    imem u_imem(.addr(pc_cur), .instr(instr));

    // Decode fields
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rd  = instr[11:7];

    // Control signals
    wire reg_writer, mem_read, mem_write, alu_src, mem_to_reg, branch;
    wire [1:0] imm_sel;
    wire [2:0] alu_ctrl;

    wire [31:0] wb_data;

    decoder u_dec(
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

    // Regfile
    wire [31:0] rd1, rd2;
    regfile u_rf(
        .clk(clk),
        .we(reg_writer),
        .ra1(rs1),
        .ra2(rs2),
        .wa(rd),
        .wd(wb_data),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Immediate
    wire [31:0] imm;
    imm_gen u_imm(.instr(instr), .imm_sel(imm_sel), .imm(imm));

    // ALU input mux
    wire [31:0] alu_b = (alu_src) ? imm : rd2;

    // ALU
    wire [31:0] alu_y;
    wire alu_zero;
    alu u_alu(.a(rd1), .b(alu_b), .alu_ctrl(alu_ctrl), .y(alu_y), .zero(alu_zero));

    // DMEM
    wire [31:0] mem_rdata;
    dmem u_dmem(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(alu_y),      // address from ALU
        .wdata(rd2),       // write data from rd2
        .rdata(mem_rdata)
    );

    // WB mux
    assign wb_data = (mem_to_reg) ? mem_rdata : alu_y;

endmodule
