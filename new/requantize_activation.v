module requantize_activation(
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

wire [31:0] res;

wire [5:0] right_shift;
wire [5:0] left_shift;
assign right_shift = (!dst_shifts[31]) ? 0 : {{0 , (~ dst_shifts[4:0])}+1};
assign left_shift = (dst_shifts[31]) ? 0 : dst_shifts[5:0] ;

assign res_multi = res_shift * dst_multi;

assign res = res_in + (rhs_row_sum*lhs_offset + bias);


right_shifter u_shifter(
    .data       (res),
    .shifter    (right_shift),
    .res        (res_shift)
);

divider_by_powerof2 u_divider(
    .dividend (res_multi),
    .exponent (right_shift),
    .quotient (res_requantize)
);

assign res_activation =     ((dst_offset + res_requantize) > activation_max) ? activation_max :
                            ((dst_offset + res_requantize) < activation_min) ? activation_min:
                            (dst_offset + res_requantize);
assign result = res_activation [31:24];

endmodule