module quantization(
    input wire [31:0] input_data,
    output wire [7:0] output_data
);

assign output_data = input_data [31:24];

endmodule