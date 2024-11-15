module xbar 
#(
    parameter DW = 32 + 3
)
(
input logic           clk,
input logic           rst_n,
//input
input logic [DW-1:0]  i_data0,
input logic           i_valid0,
input logic [DW-1:0]  i_data1,
input logic           i_valid1,
input logic           mode0,                          //1:cross or 0:bar
input logic           mode1,
//output
output logic [DW-1:0] o_data0,
output logic          o_valid0,
output logic [DW-1:0] o_data1,
output logic          o_valid1
);

logic mode;
logic error;
//error
always_comb begin
    if(i_valid0 && i_valid1) begin
        error = mode0 ^ mode1;
    end
    else begin
        error = 1'b0;
    end
end
//mode
always_comb begin
    if(i_valid0) begin
        mode = mode0;
    end
    else if(i_valid1) begin
        mode = mode1;
    end
    else begin
        mode = 1'b0;
    end
end
//o_*
always_comb begin
    if(mode == 1'b1) begin
        o_valid0 = i_valid1;
        o_valid1 = i_valid0;
        o_data0  = i_data1;
        o_data1  = i_data0;
    end
    else begin
        o_valid0 = i_valid0;
        o_valid1 = i_valid1;
        o_data0  = i_data0;
        o_data1  = i_data1;
    end
end

endmodule
