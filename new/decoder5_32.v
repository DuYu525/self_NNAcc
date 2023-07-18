module decoder5_32
(
    input wire [4:0] code,
    output wire [31:0] output_data
);

assign output_data =    (code == 5'b00000) ? 32'b0000_0000_0000_0000_0000_0000_0000_0001 :
                        (code == 5'b00001) ? 32'b0000_0000_0000_0000_0000_0000_0000_0010 :
                        (code == 5'b00010) ? 32'b0000_0000_0000_0000_0000_0000_0000_0100 :
                        (code == 5'b00011) ? 32'b0000_0000_0000_0000_0000_0000_0000_1000 :
                        (code == 5'b00100) ? 32'b0000_0000_0000_0000_0000_0000_0001_0000 :
                        (code == 5'b00101) ? 32'b0000_0000_0000_0000_0000_0000_0010_0000 :
                        (code == 5'b00110) ? 32'b0000_0000_0000_0000_0000_0000_0100_0000 :
                        (code == 5'b00111) ? 32'b0000_0000_0000_0000_0000_0000_1000_0000 :
                        (code == 5'b01000) ? 32'b0000_0000_0000_0000_0000_0001_0000_0000 :
                        (code == 5'b01001) ? 32'b0000_0000_0000_0000_0000_0010_0000_0000 :
                        (code == 5'b01010) ? 32'b0000_0000_0000_0000_0000_0100_0000_0000 :
                        (code == 5'b01011) ? 32'b0000_0000_0000_0000_0000_1000_0000_0000 :
                        (code == 5'b01100) ? 32'b0000_0000_0000_0000_0001_0000_0000_0000 :
                        (code == 5'b01101) ? 32'b0000_0000_0000_0000_0010_0000_0000_0000 :
                        (code == 5'b01110) ? 32'b0000_0000_0000_0000_0100_0000_0000_0000 :
                        (code == 5'b01111) ? 32'b0000_0000_0000_0000_1000_0000_0000_0000 :
                        (code == 5'b10000) ? 32'b0000_0000_0000_0001_0000_0000_0000_0000 :
                        (code == 5'b10001) ? 32'b0000_0000_0000_0010_0000_0000_0000_0000 :
                        (code == 5'b10010) ? 32'b0000_0000_0000_0100_0000_0000_0000_0000 :
                        (code == 5'b10011) ? 32'b0000_0000_0000_1000_0000_0000_0000_0000 :
                        (code == 5'b10100) ? 32'b0000_0000_0001_0000_0000_0000_0000_0000 :
                        (code == 5'b10101) ? 32'b0000_0000_0010_0000_0000_0000_0000_0000 :
                        (code == 5'b10110) ? 32'b0000_0000_0100_0000_0000_0000_0000_0000 :
                        (code == 5'b10111) ? 32'b0000_0000_1000_0000_0000_0000_0000_0000 :
                        (code == 5'b11000) ? 32'b0000_0001_0000_0000_0000_0000_0000_0000 :
                        (code == 5'b11001) ? 32'b0000_0010_0000_0000_0000_0000_0000_0000 :
                        (code == 5'b11010) ? 32'b0000_0100_0000_0000_0000_0000_0000_0000 :
                        (code == 5'b11011) ? 32'b0000_1000_0000_0000_0000_0000_0000_0000 :
                        (code == 5'b11100) ? 32'b0001_0000_0000_0000_0000_0000_0000_0000 :
                        (code == 5'b11101) ? 32'b0010_0000_0000_0000_0000_0000_0000_0000 :
                        (code == 5'b11110) ? 32'b0100_0000_0000_0000_0000_0000_0000_0000 :
                        (code == 5'b11111) ? 32'b1000_0000_0000_0000_0000_0000_0000_0000 :
                                            32'b0000_0000_0000_0000_0000_0000_0000_0000;

endmodule