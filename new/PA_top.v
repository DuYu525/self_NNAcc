module PA_top(
//
    input   clk,
  
    input   rst_n,
    input   start,
//IF to memIF
    input   wire [31:0] data,
    output  wire [8*4-1 : 0] result_out,
    input   read_rdy,
    output  read_acq,
    output  write_rdy,
    input   write_acq,
    output  wire [1:0] state,
    output  wire    [8:0]   rd_RAM_addr,
    output  wire    [12:0]  wr_RAM_addr ,
//IF to Instruction
    input   wire [31:0] rhs_rows,
    input   wire [31:0] rhs_cols,
    input   wire [31:0] lhs_rows
);
//u_statemachine
wire    data_rd_rdy;
wire    data_rd_acq;
wire    weight_rd_rdy;
assign  weight_rd_rdy = (state == 2'b01) ? read_rdy : 0;
wire    weight_rd_acq;
wire    dst_wr_rdy;
wire    dst_wr_acq;

wire    PA_en;
wire    ram_wr;

//u_pingpangbuffer
wire    data_wr_acq;
wire    data_wr_rdy;
wire    [31:0] data_wr_data;
wire    [31:0] data_rd_data;

//PE_array
wire    [7:0]   databuffer_rdata [3:0] ;
wire    [7:0]   weightram_rdata [15:0] ;
wire    [3:0]   out_sel ;
wire    [7:0]  result [3:0] ;

//PA_RAM
wire [12:0]  ram_addr;
wire [16*8-1 : 0] weight_out;


reg  [31:0]     rhs_row_sum [15:0];


assign data_wr_acq = (state == 2'b10) ? read_rdy : 0;
assign read_acq = (state == 2'b10) ? data_wr_rdy : weight_rd_acq;
assign result_out = {result[3],result[2],result[1],result[0]};
assign write_rdy = dst_wr_rdy;
assign dst_wr_acq = write_acq;
assign data_wr_data = data;
assign {databuffer_rdata[3] ,  databuffer_rdata[2] ,databuffer_rdata[1] ,databuffer_rdata[0] } = data_rd_data;
assign {weightram_rdata[15] , weightram_rdata[14] ,weightram_rdata[13] ,weightram_rdata[12],
        weightram_rdata[11] , weightram_rdata[10] ,weightram_rdata[9] ,weightram_rdata[8] ,
        weightram_rdata[7] , weightram_rdata[6] ,weightram_rdata[5] ,weightram_rdata[4] ,
        weightram_rdata[3] , weightram_rdata[2] ,weightram_rdata[1] ,weightram_rdata[0] } = weight_out;
assign ram_addr = ram_wr ? wr_RAM_addr : {4'b0,rd_RAM_addr};
//16 RAMS instantiated separately (replaced by a combined-RAM)
/*
genvar i;
generate;
    for (i=0; i<16; i++) begin
      assign ram_data[i] = ram_cs[i] & ram_we[i] ? data : 'hz; 
      assign weightram_rdata[i] = ram_data[i][]
    end
endgenerate
*/
PA_SM u_statemachine(
    .clk            (clk),
    .rst_n          (rst_n),
    .start          (start),
    .rhs_rows       (rhs_rows),
    .rhs_cols       (rhs_cols),
    .lhs_rows       (lhs_rows),
    .data_rd_rdy    (data_rd_rdy),
    .data_rd_acq    (data_rd_acq),
    .weight_rd_rdy  (weight_rd_rdy),
    .out_weight_rd_acq  (weight_rd_acq),
    .out_dst_wr_rdy     (dst_wr_rdy),
    .dst_wr_acq     (dst_wr_acq),
    .result_addr    (out_sel),
    .rd_RAM_addr    (rd_RAM_addr),
    .wr_RAM_addr    (wr_RAM_addr),
    .PA_en          (PA_en),
    .ram_wr         (ram_wr), 
    .state          (state)
);

pingpang_buffer #(8,2,2) u_pingpangbuffer(
    .clk            (clk),
    .rst_n          (rst_n),
    .wr_acq         (data_wr_acq),
    .wr_rdy         (data_wr_rdy),
    .wr_data        (data_wr_data),
    .rd_acq         (data_rd_acq),
    .rd_rdy         (data_rd_rdy),
    .rd_data        (data_rd_data)
);



PA_RAM #(13,8,16) u_PA_RAM (
    .clk            (clk),
    .addr           (ram_addr),
    .data_in        (data),
    .data_out       (weight_out),
    .rhs_cols       (rhs_cols),
    .we             (ram_wr)  
);

wire [31:0] PE_result [3:0];
genvar i;
generate
    /*
    for (i=0; i <16; i++) begin
        PA_RAM #(7,32,128) u_wieght_RAM(
            .clk    (clk), 
            .addr   (ram_addr[i]), 
            .data   (ram_data[i]), 
            .cs     (ram_cs[i]), 
            .we     (ram_we[i]), 
            .oe     (1'b1)
        );
    end
    */
    for(i=0; i<4; i=i+1) begin
        PE_array u_PE_array(
            .clk       (clk),
            .rst_n     (rst_n),
            .en        (PA_en),
            .data_in0  (databuffer_rdata[0]),
            .data_in1  (databuffer_rdata[1]),
            .data_in2  (databuffer_rdata[2]),
            .data_in3  (databuffer_rdata[3]),
            .weight_in0(weightram_rdata[i]),
            .weight_in1(weightram_rdata[i+4]),
            .weight_in2(weightram_rdata[i+8]),
            .weight_in3(weightram_rdata[i+12]),
            .out_sel   (out_sel),
            .result    (PE_result[i])
            );
        quantization u_quantization(
            .input_data (PE_result[i]),
            .output_data (result[i])
        );
    end
endgenerate


requantize_activation u_requantize_activation(
    
);

endmodule