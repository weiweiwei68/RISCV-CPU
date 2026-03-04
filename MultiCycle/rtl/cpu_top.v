// rtl/cpu_top.v
// support R-type and I-type

module cpu_top (
    input  wire clk,
    input  wire rst
);
    // Debug
    //wire [31:0] dbg_rd1  = rd1;
    //wire [31:0] dbg_rd2  = rd2;
    //wire        dbg_alu_src = alu_src;
    //wire [2:0]  dbg_alu_ctrl = alu_ctrl;

    // Multi-cycle registers
    reg [31:0] IR;      // Instruction Register
    reg [31:0] A, B;    // Read Data 1 and 2 Register
    reg [31:0] MDR;     // Memory Data Register
    reg [31:0] ALUOut;  // ALU Output Register
    reg [31:0] pc_id;   // Hold the PC of current instruction

    // Control Signals (at decoder module)
    // wire IRWrite;
    
    // PC + IMEM
    wire [31:0] pc_cur;
    wire [31:0] instr;
    // wire [31:0] pc_next = pc_cur + 32'd4;
    // wire [31:0] pc_plus4 = pc_cur + 32'd4;
    // wire [31:0] pc_branch = pc_cur + imm;
    // wire        take_branch = branch && alu_zero;
    // wire [31:0] pc_next = take_branch ? pc_branch : pc_plus4;
    reg [31:0] pc_next_input;
    wire [1:0]  pc_source;

    always @(*) begin
        if (pc_write) begin
            case (pc_source)
                2'b00: pc_next_input = alu_y;
                2'b01: pc_next_input = ALUOut;
                default: pc_next_input = alu_y;
            endcase
        end else begin
            // Hold PC
            pc_next_input = pc_cur;
        end
    end

    pc u_pc(
        .clk(clk), 
        .rst(rst), 
        .pc_next(pc_next_input), 
        .pc_cur(pc_cur));

    wire [31:0] instr_mem_out;
    imem u_imem(.addr(pc_cur), .instr(instr_mem_out));
    
    // IR Logic: Only load IR during Fetch State (controlled by IRWrite signal)
    always @(posedge clk) begin
        if (ir_write) begin
            IR <= instr_mem_out;
            pc_id <= pc_cur;
        end
        A <= rf_rd1;
        B <= rf_rd2;
        ALUOut <= alu_y;
        MDR <= mem_rdata;
    end
    
    // The rest of the CPU uses 'IR' instead of 'instr'
    assign instr = IR;

    // Decode fields
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rd  = instr[11:7];

    // Control signals
    // wire reg_writer, mem_read, mem_write, alu_src, mem_to_reg, branch;
    // wire [1:0] imm_sel;
    // wire [2:0] alu_ctrl;

    // Multi-cycle control signals
    wire pc_write;
    wire ir_write;
    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;

    wire [1:0] alu_src_a;
    wire [1:0] alu_src_b;
    wire [1:0] imm_sel;
    wire [2:0] alu_ctrl;

    decoder u_dec(
        .clk(clk),
        .rst(rst),
        .instr(IR),
        .alu_zero(alu_zero),

        .pc_source(pc_source),
        .pc_write(pc_write),
        .ir_write(ir_write),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .imm_sel(imm_sel),
        .alu_ctrl(alu_ctrl)
    );

    // Regfile
    wire [31:0] wb_data;

    wire [31:0] rf_rd1, rf_rd2;
    regfile u_rf(
        .clk(clk),
        .we(reg_write),
        .ra1(rs1),
        .ra2(rs2),
        .wa(rd),
        .wd(wb_data),
        .rd1(rf_rd1),
        .rd2(rf_rd2)
    );

    // Immediate
    wire [31:0] imm;
    imm_gen u_imm(.instr(instr), .imm_sel(imm_sel), .imm(imm));

    // ALU input mux
    // wire [31:0] alu_b = (alu_src) ? imm : rd2;

    // --- ALU Source A Mux ---
    reg [31:0] alu_in_a;
    always @(*) begin
        case (alu_src_a)
            2'b00: alu_in_a = pc_cur;
            2'b01: alu_in_a = A;
            2'b10: alu_in_a = pc_id;
            default: alu_in_a = 32'd0;
        endcase
    end

    // --- ALU Source B Mux ---
    reg [31:0] alu_in_b;
    always @(*) begin
        case (alu_src_b)
            2'b00: alu_in_b = B;
            2'b01: alu_in_b = imm;
            2'b10: alu_in_b = 32'd4;
            default: alu_in_b = 32'd0;
        endcase
    end

    // ALU
    wire [31:0] alu_y;
    // wire [31:0] alu_result_raw;
    wire alu_zero;
    alu u_alu(
        .a(alu_in_a), 
        .b(alu_in_b), 
        .alu_ctrl(alu_ctrl), 
        .y(alu_y), 
        .zero(alu_zero));

    // DMEM
    wire [31:0] mem_rdata;
    dmem u_dmem(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(alu_y),      // address from ALU
        .wdata(rf_rd2),       // write data from rd2
        .rdata(mem_rdata)
    );

    // WB mux
    assign wb_data = (mem_to_reg) ? MDR : ALUOut;

endmodule