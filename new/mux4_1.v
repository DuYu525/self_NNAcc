module mux4_1 (
    input   [31:0] data3 ,
    input   [31:0] data2 ,
    input   [31:0] data1 ,
    input   [31:0] data0 ,
    input   [1:0] sel,
    output  [31:0] data_sel
);

    assign data_sel =   (sel==2'b00) ? data0 :
                        (sel==2'b01) ? data1 :
                        (sel==2'b10) ? data2 :
                        (sel==2'b11) ? data3 :
                        32'b0;
endmodule