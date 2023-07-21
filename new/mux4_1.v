module mux4_1 (
    input   [31:0] data [3:0],
    input   [1:0] sel,
    output  [31:0] data_sel
);

    assign data_sel =   (sel==2'b00) ? data[0] :
                        (sel==2'b01) ? data[1] :
                        (sel==2'b10) ? data[2] :
                        (sel==2'b11) ? data[3] :
                        32'b0;
endmodule