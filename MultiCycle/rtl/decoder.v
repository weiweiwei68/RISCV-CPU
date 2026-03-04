// rtl/decoder.v
module decoder (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] instr,
    input  wire        alu_zero,  // Needed for Branch logic

    // FSM Control Signals
    output reg         pc_write,
    output reg         ir_write,
    output reg         reg_write,
    output reg         mem_read,
    output reg         mem_write,
    output reg         mem_to_reg,
    output reg [1:0]   pc_source,

    // MUX Controls
    output reg [1:0]   alu_src_a,  // 00: PC, 01: Reg A, 10: PC_id
    output reg [1:0]   alu_src_b,  // 00: B, 01: Imm, 10: 4 (for PC+4)
    output reg [1:0]   imm_sel,    // 00:I, 01:S, 10:b
    output reg [2:0]   alu_ctrl    // 000:add, 001:sub, 010:and, 011:or
);
    // Opcodes (RISC-V Base)
    localparam [6:0] OP_R_TYPE = 7'b0110011,
                     OP_I_TYPE = 7'b0010011,
                     OP_LOAD   = 7'b0000011,
                     OP_STORE  = 7'b0100011,
                     OP_BRANCH = 7'b1100011;

    // ALU Operations
    localparam [2:0] ALU_ADD = 3'b000,
                     ALU_SUB = 3'b001,
                     ALU_AND = 3'b010,
                     ALU_OR  = 3'b011;

    // State Encoding
    localparam [2:0] S_FETCH      = 3'b000,
                     S_DECODE     = 3'd001,
                     S_EXEC       = 3'd2,
                     S_MEM        = 3'd3,
                     S_WB         = 3'd4;

    reg [2:0] current_state, next_state;

    // Opcode Decoding
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    // State Register
    always @(posedge clk) begin
        if (rst) 
            current_state <= S_FETCH;
        else 
            current_state <= next_state;
    end

    // Next State Logic
    always @(*) begin
        // defaults (avoid latches)
        pc_write    = 1'b0;
        ir_write    = 1'b0;
        reg_write   = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        mem_to_reg  = 1'b0;
        alu_src_a   = 2'b00; // 0: PC
        alu_src_b   = 2'b00; // 00: B
        imm_sel     = 2'b00;
        alu_ctrl    = ALU_ADD;
        pc_source   = 2'b00;

        case (current_state)
            S_FETCH: begin
                next_state = S_DECODE;
                mem_read  = 1'b1;  // Read Instr Mem
                ir_write  = 1'b1;  // Update IR
                alu_src_a = 2'b00; // PC
                alu_src_b = 2'b10; // Constant 4
                alu_ctrl  = ALU_ADD;// Add
                pc_write  = 1'b1;  // Update PC with PC + 4
                pc_source = 2'b00;
            end

            S_DECODE: begin
                case (opcode)
                    OP_BRANCH: next_state = S_EXEC; // Branch taken/ not taken handled in EXEC/DECODE
                    default:   next_state = S_EXEC;
                endcase

                // Calculate Branch Target (PC + Imm) just in case it is a branch
                imm_sel    = 2'b10; // Branch Immediate
                alu_src_a  = 2'b10; // PC
                alu_src_b  = 2'b01; // Imm
                alu_ctrl   = 3'b000;// ADD
                // Note: No ALU op here strictly needed unless optimizing branch
            end

            S_EXEC: begin
                case (opcode)
                    OP_LOAD, OP_STORE: next_state = S_MEM;
                    OP_R_TYPE, OP_I_TYPE: next_state = S_WB;
                    default: next_state = S_FETCH;
                endcase

                case (opcode)
                    OP_R_TYPE: begin  // R-type
                        alu_src_a = 2'b01; // Reg A
                        alu_src_b = 2'b00;// Reg B
                        // ALU Control Logic
                        case (funct3)
                            3'b000: begin
                                if (funct7 == 7'b0100000) alu_ctrl = ALU_SUB;
                                else                      alu_ctrl = ALU_ADD;
                            end

                            3'b111: alu_ctrl = ALU_AND;
                            3'b110: alu_ctrl = ALU_OR;
                            default: alu_ctrl = ALU_ADD;
                        endcase
                    end

                    OP_I_TYPE: begin  // I-Type (addi)
                        alu_src_a = 2'b01; // Reg A
                        alu_src_b = 2'b01; // Imm
                        imm_sel   = 2'b00; // I-Type Imm
                        // ALU Control Logic
                        case (funct3)
                            3'b000: alu_ctrl = ALU_ADD; // Add other I-Type here if needed (andi, ori)
                            default: alu_ctrl  = ALU_ADD;
                        endcase
                    end

                    OP_LOAD, OP_STORE: begin
                        alu_src_a = 2'b01; // Reg A
                        alu_src_b = 2'b01; // Imm
                        imm_sel   = (opcode == OP_STORE) ? 2'b01 : 2'b00;  // S-Type or I-Type
                        alu_ctrl  = ALU_ADD; // calculate addr
                    end

                    OP_BRANCH: begin  // BEQ
                        alu_src_a = 2'b01; // Reg A
                        alu_src_b = 2'b00; // Reg B
                        alu_ctrl  = ALU_SUB; // Subtract (to check zero)
                        if (alu_zero) begin
                            // Re-calculate Branch Target
                            // PC Write logic would be complex here without OldPC.
                            // For this tutorial's simplicity, we will ignore the branch update for one second 
                            // and fix it in cpu_top connection.
                            pc_write = 1'b1;
                            pc_source = 2'b01;
                        end
                    end
                endcase
            end

            S_MEM: begin
                case (opcode)
                    OP_LOAD:  next_state = S_WB;
                    OP_STORE: next_state = S_FETCH;
                    default:  next_state = S_FETCH;
                endcase

                if (opcode == OP_LOAD) begin  // LW
                    mem_read = 1'b1; // Addr comes from ALUOut (connected in cpu_top)
                end
                else if (opcode == OP_STORE) begin  // SW
                    mem_write = 1'b1;
                end
            end

            S_WB: begin
                next_state = S_FETCH;
                reg_write = 1'b1;
                mem_to_reg = (opcode == OP_LOAD) ? 1'b1 : 1'b0; // 1 if LW, else 0
            end

            default: next_state = S_FETCH;
        endcase
    end
endmodule