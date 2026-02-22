// rtl/regfile.v
module regfile (
    input  wire          clk,
    input  wire          we,    // write enable
    input  wire [4:0]    ra1,   // read addr 1
    input  wire [4:0]    ra2,   // read addr 2
    input  wire [4:0]    wa,    // write address
    input  wire [31:0]   wd,    // write data
    output wire [31:0]   rd1,   // read data 1
    output wire [31:0]   rd2    // read data 2
);

    reg [31:0] regs [0:31];

    // combinational read (x0 always reads as 0)
    assign rd1 = (ra1 == 5'd0) ? 32'd0 : regs[ra1];
    assign rd2 = (ra2 == 5'd0) ? 32'd0 : regs[ra2];

    // synchronous write (ignore writes to x0)
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'd0;
    end

    always @(posedge clk) begin
        if (we && (wa != 5'd0)) begin
            regs[wa] <= wd;
        end
        // Enforce x0 to maintain 0
        regs[0] <= 32'd0;
    end
endmodule