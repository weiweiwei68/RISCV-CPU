// rtl/dmem.v
module dmem #(
    parameter DEPTH = 256
)(
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] addr,    // byte address
    input  wire [31:0] wdata,   // write data
    output wire [31:0] rdata    // read data
);
    reg [31:0] mem [0:DEPTH - 1];

    wire [31:0] word_index = addr[31:2];

    // combinational read (simple model)
    assign rdata = (mem_read) ? mem[word_index] : 32'd0;

    integer i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) 
            mem[i] = 32'd0;
    end
    
    always @(posedge clk) begin
        if (mem_write) begin
            mem[word_index] <= wdata;
        end
    end
endmodule