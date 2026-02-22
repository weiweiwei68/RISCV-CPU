// rtl/pc.v
module pc (
    input wire clk,
    input wire rst,    //active-high reset
    input wire [31:0] pc_next,
    output reg [31:0] pc_cur
);
    always @(posedge clk) begin
        if (rst)
            pc_cur <= 32'h0000_0000;
        else
            pc_cur <= pc_next;
    end
endmodule