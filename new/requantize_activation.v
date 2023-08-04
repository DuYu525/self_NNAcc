module requantize_activation(
    input  clk,
    input  act_en,
    input  [31:0]   res_in,
    input  [31:0]   dst_multi,
    input  [31:0]   dst_shifts,
    input  [31:0]   activation_min,
    input  [31:0]   activation_max,
    input  [31:0]   dst_offset,

    input  [31:0]   rhs_row_sum,
    input  [31:0]   lhs_offset,
    input  [31:0]   bias,

    output     [7:0]   result
);

wire [31:0] res_shift;
wire [31:0] res_multi;
wire [31:0] res_requantize;
wire [31:0] res_activation;
wire [63:0] multi_trans;

wire [31:0] res;

wire [5:0] right_shift;
wire [5:0] left_shift;

reg  [31:0] res_buf;
reg  [31:0] res_shift_buf;
reg  [31:0] res_multi_buf;


always @ (posedge clk) begin
    if (!act_en) begin
        res_buf <= 0;
        res_shift_buf <= 0;
        res_multi_buf <= 0;
    end
    else begin
        res_buf <= res;
        res_shift_buf <= res_shift;
        res_multi_buf <= res_multi;      
    end
end

assign right_shift = (!dst_shifts[31]) ? 0 : {{0 , (~ dst_shifts[4:0])}+1};
assign left_shift = (dst_shifts[31]) ? 0 : dst_shifts[5:0] ;

//assign res_multi = (({32'b0,res_shift} * {32'b0,dst_multi})[31]) ?  (({32'b0,res_shift} * {32'b0,dst_multi})[63:32] + 1) : ({32'b0,res_shift} * {32'b0,dst_multi})[63:32];
assign multi_trans = {{32'b0,res_shift_buf} * {32'b0,dst_multi}} ;
assign res_multi  =  multi_trans[31] ?  (multi_trans [63:32] + 1) : multi_trans[63:32];

assign res = res_in + (rhs_row_sum*lhs_offset + bias);


right_shifter u_shifter(
    .data       (res_buf),
    .shifter    (left_shift),
    .res        (res_shift)
);

divider_by_powerof2 u_divider(
    .dividend (res_multi_buf),
    .exponent (right_shift),
    .quotient (res_requantize)
);

assign res_activation =     ((dst_offset + res_requantize) > activation_max) ? activation_max :
                            ((dst_offset + res_requantize) < activation_min) ? activation_min:
                            (dst_offset + res_requantize);
assign result = res_activation [7:0];

endmodule