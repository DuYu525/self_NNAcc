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
    output  wire    [31:0]  mem_bias_addr,
    output  wire    [31:0]  buf_bias_addr,
//IF to Instruction
    input   wire [31:0] rhs_rows,
    input   wire [31:0] rhs_cols,
    input   wire [31:0] lhs_rows,
    input   wire [31:0] lhs_offset,
    input   wire [31:0] dst_offset,
    input   wire [31:0] activation_min,
    input   wire [31:0] activation_max,

    output  wire buf_wr,
    output  wire [1:0] buf_wr_sel
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

wire    pingpang_rd;


//u_pingpangbuffer
wire    data_wr_acq;
wire    data_wr_rdy;
wire    [31:0] data_wr_data;
wire    [31:0] data_rd_data;
wire    pingpang_wr;
assign  pingpang_rd = (data_wr_acq & data_wr_rdy) ;


//PE_array
reg    [7:0]   databuffer_rdata [3:0] ;
wire    [7:0]   weightram_rdata [15:0] ;
wire    [3:0]   out_sel ;
wire    [7:0]  result [3:0] ;
wire    PA_rst_n;

//PA_RAM
reg [12:0]  ram_addr;
wire [16*8-1 : 0] weight_out;



//ld bias_buf :10   ld dst_multi_buf : 01  ld dst_shifts_buf: 00   
reg  [31:0]     bias_buf        [15:0];
reg  [31:0]     dst_multi_buf   [15:0];
reg  [31:0]     dst_shifts_buf  [15:0];

reg  [31:0]     rhs_row_sum     [15:0];

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
//    genvar i;
//    generate
//        for (i = 0 ; i<16 ; i= i+1) begin
//            bias_buf[i] <= 32'b0;
//            dst_multi_buf[i] <= 32'b0;
//            dst_shifts_buf[i] <= 32'b0;
//        end
//    endgenerate
            bias_buf[0] <= 32'b0;
            dst_multi_buf[0] <= 32'b0;
            dst_shifts_buf[0] <= 32'b0;
            bias_buf[1] <= 32'b0;
            dst_multi_buf[1] <= 32'b0;
            dst_shifts_buf[1] <= 32'b0;
            bias_buf[2] <= 32'b0;
            dst_multi_buf[2] <= 32'b0;
            dst_shifts_buf[2] <= 32'b0;
            bias_buf[3] <= 32'b0;
            dst_multi_buf[3] <= 32'b0;
            dst_shifts_buf[3] <= 32'b0;
            
            bias_buf[4] <= 32'b0;
            dst_multi_buf[4] <= 32'b0;
            dst_shifts_buf[4] <= 32'b0;
            bias_buf[5] <= 32'b0;
            dst_multi_buf[5] <= 32'b0;
            dst_shifts_buf[5] <= 32'b0;
            bias_buf[6] <= 32'b0;
            dst_multi_buf[6] <= 32'b0;
            dst_shifts_buf[6] <= 32'b0;
            bias_buf[7] <= 32'b0;
            dst_multi_buf[7] <= 32'b0;
            dst_shifts_buf[7] <= 32'b0;
            
            bias_buf[8] <= 32'b0; dst_multi_buf[8] <= 32'b0; dst_shifts_buf[8] <= 32'b0;
            bias_buf[9] <= 32'b0; dst_multi_buf[9] <= 32'b0; dst_shifts_buf[9] <= 32'b0;
            bias_buf[10] <= 32'b0; dst_multi_buf[10] <= 32'b0; dst_shifts_buf[10] <= 32'b0;
            bias_buf[11] <= 32'b0; dst_multi_buf[11] <= 32'b0; dst_shifts_buf[11] <= 32'b0;
            bias_buf[12] <= 32'b0; dst_multi_buf[12] <= 32'b0; dst_shifts_buf[12] <= 32'b0;
            bias_buf[13] <= 32'b0; dst_multi_buf[13] <= 32'b0; dst_shifts_buf[13] <= 32'b0;
            bias_buf[14] <= 32'b0; dst_multi_buf[14] <= 32'b0; dst_shifts_buf[14] <= 32'b0;
            bias_buf[15] <= 32'b0; dst_multi_buf[15] <= 32'b0; dst_shifts_buf[15] <= 32'b0;
            
  end
  else if (buf_wr) begin
        if (buf_wr_sel == 2'b00) begin
            dst_shifts_buf [wr_RAM_addr[12:9]] <= data;
        end
        else if (buf_wr_sel == 2'b01) begin
            dst_multi_buf [wr_RAM_addr[12:9]] <= data;
        end
        else if (buf_wr_sel == 2'b10) begin
            bias_buf [wr_RAM_addr[12:9]] <= data;
        end
  end
end

reg   pingpang_wr_buf;
always @ (posedge clk) begin
    pingpang_wr_buf <= pingpang_wr;
end
assign data_wr_acq = (pingpang_wr_buf) ? read_rdy : 0;
assign read_acq = (state == 2'b10) ? data_wr_rdy : weight_rd_acq;
assign data_wr_data = data;
assign result_out = {result[3],result[2],result[1],result[0]};
assign write_rdy = dst_wr_rdy;
assign dst_wr_acq = write_acq;

always @(posedge clk) begin
    {databuffer_rdata[3] ,  databuffer_rdata[2] ,databuffer_rdata[1] ,databuffer_rdata[0] } <= data_rd_data;
end
assign {weightram_rdata[15] , weightram_rdata[14] ,weightram_rdata[13] ,weightram_rdata[12],
        weightram_rdata[11] , weightram_rdata[10] ,weightram_rdata[9] ,weightram_rdata[8] ,
        weightram_rdata[7] , weightram_rdata[6] ,weightram_rdata[5] ,weightram_rdata[4] ,
        weightram_rdata[3] , weightram_rdata[2] ,weightram_rdata[1] ,weightram_rdata[0] } = weight_out;


always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ram_addr <= 0;
    end
    else begin
        ram_addr <= ram_wr ? wr_RAM_addr : {4'b0,rd_RAM_addr};
    end
end
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
    .pingpang_rd    (pingpang_rd),
    .pingpang_wr  (pingpang_wr),
    .data_rd_rdy    (data_rd_rdy),
    .data_rd_acq    (data_rd_acq),
    .weight_rd_rdy  (weight_rd_rdy),
    .out_weight_rd_acq  (weight_rd_acq),
    .out_dst_wr_rdy     (dst_wr_rdy),
    .dst_wr_acq     (dst_wr_acq),
    .result_addr    (out_sel),
    .rd_RAM_addr    (rd_RAM_addr),
    .wr_RAM_addr    (wr_RAM_addr),
    .mem_bias_addr  (mem_bias_addr),
    .buf_bias_addr  (buf_bias_addr),    
    .PA_en          (PA_en),
    .ram_wr         (ram_wr), 
    .state          (state),
    .buf_wr         (buf_wr),
    .buf_wr_sel     (buf_wr_sel),

    .PA_rst_n       (PA_rst_n)
);
reg buf_wr_acq;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        buf_wr_acq <= 0;
    end
        buf_wr_acq <= data_wr_acq;
end
pingpang_buffer #(8,2,2) u_pingpangbuffer(
    .clk            (clk),
    .rst_n          (rst_n),
    .wr_acq         (buf_wr_acq),
    .wr_rdy         (data_wr_rdy),
    .wr_data        (data_wr_data),
    .rd_acq         (data_rd_acq),
    .rd_rdy         (data_rd_rdy),
    .rd_data        (data_rd_data)
);

reg ram_wr_in;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ram_wr_in <= 0;
    end
    else begin
        ram_wr_in <= ram_wr;
    end
end

PA_RAM #(13,8,16) u_PA_RAM (
    .clk            (clk),
    .addr           (ram_addr),
    .data_in        (data),
    .data_out       (weight_out),
    .rhs_cols       (rhs_cols),
    .we             (ram_wr_in)  
);
genvar i;
generate
for (i = 0 ; i<16 ; i= i+1) begin
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
//        genvar i;
//        generate
//            for (i = 0 ; i<16 ; i= i+1) begin
                rhs_row_sum[i] <= 32'b0; 
//            end
//        endgenerate
    end
    else if (PA_en) begin
//        genvar i;
//        generate
            
                rhs_row_sum[i] <= rhs_row_sum[i] + weightram_rdata[i]; 
            
//        endgenerate
    end
end
end
endgenerate

   wire [31:0] dst_multi_sel       [3:0];
        wire [31:0] dst_shifts_sel      [3:0];
        wire [31:0] rhs_row_sum_sel     [3:0];
        wire [31:0] bias_sel            [3:0];
wire [31:0] PE_result [3:0];
//genvar i;
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
    reg PA_en_in;
    always @(posedge clk) begin
        PA_en_in <= PA_en;
    end

    for(i=0; i<4; i=i+1) begin
        PE_array u_PE_array(
            .clk       (clk),
            .rst_n     (PA_rst_n),
            .en        (PA_en_in),
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
        /*
        quantization u_quantization(
            .input_data (PE_result[i]),
            .output_data (result[i])
        );
        */
     

        mux4_1 dst_multi_mux(
            .data3       (dst_multi_buf[i*4+3]),
            .data2       (dst_multi_buf[i*4+2]),
            .data1      (dst_multi_buf[i*4+1]),
            .data0      (dst_multi_buf[i*4]),
            .sel        (out_sel[1:0]),
            .data_sel   (dst_multi_sel[i])
        );
        mux4_1 dst_shifts_mux(
            .data3       (dst_shifts_buf[i*4+3]),
            .data2      (dst_shifts_buf[i*4+2]),
            .data1      (dst_shifts_buf[i*4+1]),
            .data0      (dst_shifts_buf[i*4]),
            .sel        (out_sel[1:0]),
            .data_sel   (dst_shifts_sel[i])
        );
        mux4_1 rhs_row_sum_mux(
            .data3       (rhs_row_sum[i*4+3]),
            .data2      (rhs_row_sum[i*4+2]),
            .data1      (rhs_row_sum[i*4+1]),
            .data0      (rhs_row_sum[i*4]),
            .sel        (out_sel[1:0]),
            .data_sel   (rhs_row_sum_sel[i])
        );
        mux4_1 bias_mux(
            .data3       (bias_buf[i*4+3]),
            .data2       (bias_buf[i*4+2]),
            .data1       (bias_buf[i*4+1]),
            .data0       (bias_buf[i*4]),
            .sel        (out_sel[1:0]),
            .data_sel   (bias_sel[i])
        );

        requantize_activation u_requantize_activation(
            .res_in         (PE_result[i]),
            .dst_multi      (dst_multi_sel[i]),
            .dst_shifts     (dst_shifts_sel[i]),
            .activation_min (activation_min),
            .activation_max (activation_max),
            .dst_offset     (dst_offset),

            .rhs_row_sum    (rhs_row_sum_sel[i]),
            .lhs_offset     (lhs_offset),
            .bias           (bias_sel[i]),
            .result         (result[i])
        );
    end


endgenerate




endmodule