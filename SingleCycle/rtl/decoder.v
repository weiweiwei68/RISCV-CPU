// rtl/decoder.v
module decoder (
    input  wire [31:0] instr,
    output reg         reg_writer,
    output reg         mem_read,
    output reg         mem_write,
    output reg         alu_src,
    output reg         mem_to_reg,
    output reg         branch,
    output reg [1:0]   imm_sel,    // 00:I, 01:S, 10:b
    output reg [2:0]   alu_ctrl    // 000:add, 001:sub, 010:and, 011:or
);
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    always @(*) begin
        // defaults (avoid latches)
        reg_writer  = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        alu_src     = 1'b0;
        mem_to_reg  = 1'b0;
        branch      = 1'b0;
        imm_sel     = 1'b0;
        alu_ctrl    = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type
                reg_writer = 1'b1;
                alu_src    = 1'b0;
                mem_to_reg = 1'b0;

                case (funct3)
                    3'b000: alu_ctrl = (funct7 == 7'b0100000) ? 3'b001 : 3'b000;
                    3'b111: alu_ctrl = 3'b010; // andd
                    3'b110: alu_ctrl = 3'b011; // or
                    default: alu_ctrl = 3'b000;
                endcase
            end

            7'b0010011: begin // I-type ALU (addi)
                reg_writer = 1'b1;
                alu_src    = 1'b1;
                imm_sel    = 2'b00; // I
                case (funct3)
                    3'b000: alu_ctrl = 3'b000;  // addi
                    3'b111: alu_ctrl = 3'b010;  // andi
                    3'b110: alu_ctrl = 3'b011;  // ori
                    default: alu_ctrl = 3'b000;
                endcase
            end

            7'b0000011: begin // Load (lw)
                reg_writer = 1'b1;
                mem_read   = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
                imm_sel    = 2'b00; // I
                alu_ctrl   = 3'b000; // address = rs1 + imm
            end

            7'b0100011: begin // Store (sw)
                mem_write = 1'b1;
                alu_src   = 1'b1;
                imm_sel   = 2'b01; // S type
                alu_ctrl  = 3'b000; // address = rs1 + imm
            end

            7'b1100011: begin // Branch (beq)
                branch    = 1'b1;
                alu_src   = 1'b0;
                imm_sel   = 2'b10; // B
                alu_ctrl  = 3'b001; // rs1 _ rs2, use zero
            end

            default: begin
                // keep defaults
            end
        endcase
    end
endmodule