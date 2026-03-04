// rtl/fetch_top.v
module fetch_top (
    input  wire clk,
    input  wire rst,
    output wire [31:0] pc_cur,
    output wire [31:0] instr
);
    wire [31:0] pc_next;

    assign pc_next = pc_cur + 32'd4;

    pc u_pc(
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc_cur(pc_cur)
    );

    imem u_imem(
        .addr(pc_cur),
        .instr(instr)
    );
endmodule