// rtl/imem.v
module imem #(
    parameter DEPTH = 16
)(
    input  wire [31:0] addr,    // byte address
    output wire [31:0] instr
);
    reg [31:0] mem [0:DEPTH - 1];

    // word index = addr [31:2]
    assign instr = mem[addr[31:2]];

    integer i;
    initial begin
        for (i=0; i<DEPTH; i=i+1) mem[i] = 32'h0000_0013; // NOP = addi x0,x0,0
        $readmemh("tb/imem.hex", mem);
    end
endmodule