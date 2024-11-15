module test_tb;
parameter DW = 32;
parameter N  = 8;
//
logic          clk;
logic          rst_n;
logic [DW-1:0] i_data  [N-1:0];
logic [DW-1:0] o_data  [N-1:0];
logic [N-1:0]  i_valid;
logic [N-1:0]  o_valid;
logic [N-1:0]  valid_reg;
logic [DW-1:0] data_q [$];
logic [DW-1:0] ref_data_q [$];
logic          start;
//data_q
always_ff@(posedge clk) begin
    for(int i = 0; i < N; i++) begin
        if(o_valid[i] == 1'b1) begin
            data_q.push_back(o_data[i]);
        end
    end
end
//valid_reg
always_ff@(posedge clk) begin
    if(|i_valid) begin
        valid_reg <= o_valid;
    end
end
//ref_data_q
always_ff@(posedge clk) begin
    for(int i = 0; i < N; i++) begin
        if(i_valid[i] == 1'b1) begin
            ref_data_q.push_back(i_data[i]);
        end
    end
end
//clk
initial begin
    clk = 1'b0;
    forever begin
        #5 clk = ~clk;
    end
end
//rst_n
initial begin
    rst_n = 1'b0;
    #100
    rst_n = 1'b1;
end
//drv input
always_ff@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for(int i = 0; i < N; i++) begin
            i_valid[i] <= 1'b0;
            i_data[i]  <= DW'(0);
        end
    end
    else if(start) begin
        for(int i = 0; i < N; i++) begin
            i_valid[i] <= ($urandom() % 100 < 50) ? 1'b1 : 1'b0;
            i_data[i]  <= DW'(i);
        end
    end
    else begin
        for(int i = 0; i < N; i++) begin
            i_valid[i] <= 1'b0;
        end
    end
end
//start
initial begin
    start = 1'b0;
    #200
    start = 1'b1;
    #10
    start = 1'b0;
end
//
initial begin
    $fsdbDumpfile("data_compress.fsdb");
    $fsdbDumpvars(0);
    $fsdbDumpMDA();
end
//
initial begin
    #1000
    valid_check: assert (({1'b0, valid_reg} + 1'b1) == (1 << data_q.size));
    $display("o_valid = %b, queue_size = %d", valid_reg, data_q.size);
    if(data_q.size != ref_data_q.size) begin: check_data_num
        $display("test failed");
        $finish;
    end
    for(int i = 0; i < data_q.size; i++) begin
        $display("i = %d, %h, %h", i, data_q[i], ref_data_q[i]);
        if(data_q[i] != ref_data_q[i]) begin
            $display("test failed");
            $finish;
        end
    end
    $display("test pass");
    $finish;
end
//inst
data_compress #
(
    .DW (DW    ),
    .N  (N     )
) data_compress_inst
(
    .clk     (clk     ),
    .rst_n   (rst_n   ),
    .i_valid (i_valid ),
    .i_data  (i_data  ),
    .o_data  (o_data  ),
    .o_valid (o_valid )
);

endmodule
