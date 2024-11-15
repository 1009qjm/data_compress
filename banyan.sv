module banyan
#(
parameter DW = 32 + 3,                         //32bit for data and 3bit for routing
parameter N = 8
)
(
input logic           clk,
input logic           rst_n,
input logic [DW-1:0]  i_data  [N-1:0],
input logic [N-1:0]   i_valid,
output logic [DW-1:0] o_data  [N-1:0],
output logic [N-1:0]  o_valid
);
//stage1 input
logic [DW-1:0] data_stg1  [N-1:0];
logic          valid_stg1 [N-1:0];
//stage2 input
logic [DW-1:0] data_stg2  [N-1:0];
logic          valid_stg2 [N-1:0];
//stage0
generate 
    for(genvar i = 0; i < N/2; i++) begin:gen_stg0
        localparam idx0 = (i < 2) ? i : i+2;
        localparam idx1 = (i < 2) ? i+2 : i+4;
        xbar xbar_stg0_inst (
            .i_valid0 (i_valid[2*i]       ),
            .i_data0  (i_data[2*i]        ),
            .i_valid1 (i_valid[2*i+1]     ),
            .i_data1  (i_data[2*i+1]      ),
            .mode0    (i_data[2*i][DW-3]  ),
            .mode1    (i_data[2*i+1][DW-3]),
            //to next stg                                 //(0,1,2,3,4,5,6,7) ---> (0,2,1,3,4,6,5,7)
            .o_valid0 (valid_stg1[idx0]   ),                      //0,1,4,5
            .o_data0  (data_stg1[idx0]    ),
            .o_valid1 (valid_stg1[idx1]   ),                      //2,3,6,7
            .o_data1  (data_stg1[idx1]    )
        );
    end
endgenerate
//stage1
generate
    for(genvar i = 0; i < N/2; i++) begin:gen_stg1
        localparam idx0 = (i < 2) ? 2*i : 2*i-3;
        localparam idx1 = (i < 2) ? 2*i+4 : 2*i+1;
        xbar xbar_stg1_inst(
            .i_valid0 (valid_stg1[2*i]   ),
            .i_data0  (data_stg1[2*i]    ),
            .i_valid1 (valid_stg1[2*i+1] ),
            .i_data1  (data_stg1[2*i+1]  ),
            .mode0    (data_stg1[2*i][DW-2]  ),
            .mode1    (data_stg1[2*i+1][DW-2]),
            //to next stg                         (0,1,2,3,4,5,6,7) ---> (0,4,2,6,1,5,3,7)
            .o_valid0 (valid_stg2[idx0]   ),       //(0,2,1,3)
            .o_data0  (data_stg2[idx0]    ),   
            .o_valid1 (valid_stg2[idx1]   ),       //(4,6,5,7)
            .o_data1  (data_stg2[idx1]    )
        );
    end
endgenerate
//stage2
generate 
    for(genvar i = 0; i < N/2; i++) begin:gen_stg2
        xbar xbar_stg2_inst(
            .i_valid0 (valid_stg2[2*i]   ),
            .i_data0  (data_stg2[2*i]    ),
            .i_valid1 (valid_stg2[2*i+1] ),
            .i_data1  (data_stg2[2*i+1]  ),
            .mode0    (data_stg2[2*i][DW-1]  ),
            .mode1    (data_stg2[2*i+1][DW-1]),
            //to nxt stg                                       //(0,4,1,5,2,6,3,7)
            .o_valid0 (o_valid[i]      ),                      //(0,1,2,3)
            .o_data0  (o_data[i]       ),
            .o_valid1 (o_valid[i+4]    ),                      //(4,5,6,7)
            .o_data1  (o_data[i+4]     )
        );
    end
endgenerate

endmodule
