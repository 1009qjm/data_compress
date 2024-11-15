module data_compress #(
   parameter DW = 32,
   parameter N  = 8
)
(
   input  logic                 clk,
   input  logic                 rst_n,
   input  logic [DW-1:0]        i_data  [N-1:0],
   output logic [DW-1:0]        o_data  [N-1:0],
   input  logic [N-1:0]         i_valid,
   output logic [N-1:0]         o_valid
);
logic [DW+$clog2(N)-1:0] din     [N-1:0];
logic [DW+$clog2(N)-1:0] dout    [N-1:0];
logic [$clog2(N)-1:0]    dst_idx [N-1:0];
//dst_idx[i] = valid[0]+...+valid[i-1]
always_comb begin
    dst_idx[0] = 'd0;
    for(int i = 1; i < N; i++) begin
        dst_idx[i] = dst_idx[i-1] + i_valid[i-1];
    end
end
//din
generate
    for(genvar i = 0; i < N; i++) begin:gen_din
        assign din[i] = {i[$clog2(N)-1:0]^dst_idx[i], i_data[i]};
    end
endgenerate
//o_data
generate
    for(genvar i = 0; i < N; i++) begin:gen_dout
        assign o_data[i] = dout[i][DW-1:0];
    end
endgenerate

//inst
banyan #
(   .DW(DW+$clog2(N)),
    .N (N )
) banyan_inst
(
    .clk     (clk     ),
    .rst_n   (rst_n   ),
    .i_valid (i_valid ),
    .i_data  (din     ),
    .o_data  (dout    ),
    .o_valid (o_valid )
);

endmodule
