module coder16_4 
(
    input wire [15:0] input_data,
    output wire [3:0] code
);

assign code =   input_data [15] ? 4'b1111:
                input_data [14] ? 4'b1110: 
                input_data [13] ? 4'b1101:
                input_data [12] ? 4'b1100:
                input_data [11] ? 4'b1011:
                input_data [10] ? 4'b1010:
                input_data [9] ? 4'b1001:
                input_data [8] ? 4'b1000:
                input_data [7] ? 4'b0111:
                input_data [6] ? 4'b0110: 
                input_data [5] ? 4'b0101:
                input_data [4] ? 4'b0100:
                input_data [3] ? 4'b0011:
                input_data [2] ? 4'b0010:
                input_data [1] ? 4'b0001:
                input_data [0] ? 4'b0000:
                4'b0000
                ;

endmodule