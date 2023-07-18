module right_shifter (
    input [31:0]    data,
    input [5:0]     shifter,
    output [31:0]   res
);

wire [31:0] data_res[4:0];
wire [31:0] data_shift[5:0];

assign data_shift[0] = {data[15:0],16'b0};
assign data_shift[1] = {data_res[0][23:0],8'b0};
assign data_shift[2] = {data_res[1][27:0],4'b0};
assign data_shift[3] = {data_res[2][29:0],2'b0};
assign data_shift[4] = {data_res[3][30:0],1'b0};


assign data_res[0] = shifter[4] ? data_shift[0] : data;
assign data_res[1] = shifter[3] ? data_shift[1] : data_res[0];
assign data_res[2] = shifter[2] ? data_shift[2] : data_res[1];
assign data_res[3] = shifter[1] ? data_shift[3] : data_res[2];
assign data_res[4] = shifter[0] ? data_shift[4] : data_res[3];

assign res = (shifter[5]) ? 0 : data_res[4];
endmodule