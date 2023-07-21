//module name: GEMM ACCELERATOR
//GEMM parameter transfer

module InstrucIF(
    input   nice_clk,
    input   nice_rst_n,
    input   nice_req_valid,
    output  nice_req_ready,
    input   [31:0]  nice_req_instr,
    input   [31:0]  nice_req_rs1,
    input   [31:0]  nice_req_rs2,
    input   [31:0]  nice_req_rs1_1,
    input   [31:0]  nice_req_rs2_1,
    input   nice_req_mmode,

    output  nice_rsp_1cyc_type,
    output  [31:0]  nice_rsp_1cyc_dat,
    output  [31:0]  nice_rsp_1cyc_dat_1,
    output  nice_rsp_1cyc_err,

    output  nice_rsp_multicyc_valid,
    input   nice_rsp_multicyc_ready,
    output  [31:0]  nice_rsp_multicyc_dat,
    output  nice_rsp_multicyc_err,

    input   [1:0]   state,
    input    fin,
    output   wire  [31:0]    rhs_rows,
    output   wire  [31:0]    lhs_rows,
    output   wire  [31:0]    rhs_cols,
    output   wire  [31:0]    dst_addr,
    output   wire  [31:0]    lhs_addr,
    output   wire  [31:0]    rhs_addr,

    output   wire  [31:0]    lhs_offset,
    output   wire  [31:0]    dst_offset,
    output   wire  [31:0]    activation_min,
    output   wire  [31:0]    activation_max,

    output   wire [31:0] dst_multi_addr,
    output   wire [31:0] dst_shifts_addr,
    output   wire [31:0] lhs_bias_addr,

    output   wire  start
);

    //status_nice 
    //0:rhs_cols    1:lhs_rows      2:rhs_cols
    //3:bias_addr   4:lhs_addr      5:rhs_addr
    //6:lhs_offset  7:dst_offset    8:activation_min
    //9:activation_max  10:dst_multi_addr   11:dst_shifts_addr
    //12: dst_addr
    reg     [12:0]   status_nice;
    reg     [31:0]  rhs_rows_buf;
    reg     [31:0]  lhs_rows_buf;
    reg     [31:0]  rhs_cols_buf;
    reg     [31:0]  dst_addr_buf;
    reg     [31:0]  lhs_addr_buf;
    reg     [31:0]  rhs_addr_buf;

    //Added on 7/17 for quantization and activation 
    reg     [31:0]  bias_addr_buf;
    reg     [31:0]  lhs_offset_buf;
    reg     [31:0]  dst_offset_buf;
    reg     [31:0]  activation_min_buf;
    reg     [31:0]  activation_max_buf;
    reg     [31:0]  dst_multi_addr_buf;
    reg     [31:0]  dst_shifts_addr_buf;


    //when a single-cycle instruction error occurs
    assign  nice_rsp_1cyc_err = nice_req_valid & nice_req_ready & nice_rsp_1cyc_type & (nice_req_instr[6:0] != 0101011);
    assign  nice_rsp_multicyc_err = (nice_rsp_multicyc_valid & nice_rsp_multicyc_ready) ? multi_err : 0;
    
    assign  nice_req_ready = (state == 2'b00);
    //assign outputs to calculate circuit
    assign  rhs_rows  = rhs_rows_buf;
    assign  lhs_rows  = lhs_rows_buf;
    assign  rhs_cols  = rhs_cols_buf;
    assign  dst_addr  = dst_addr_buf;
    assign  lhs_addr  = lhs_addr_buf;
    assign  rhs_addr  = rhs_addr_buf;
    assign  lhs_offset = lhs_offset_buf;
    assign  dst_offset = dst_offset_buf;
    assign  activation_min = activation_min_buf;
    assign  activation_max = activation_max_buf;
    assign  dst_multi_addr = dst_multi_addr_buf;
    assign  dst_shifts_addr = dst_shifts_addr_buf;
    assign  lhs_bias_addr = bias_addr_buf;

    //store input parameter into the buffers by single-cycle instruction
    always @(negedge nice_rst_n or posedge nice_clk) begin
        if (!nice_rst_n) begin
          status_nice <= 13'b0;
          rhs_rows_buf <= 32'b0;
          lhs_rows_buf <= 32'b0;
          rhs_cols_buf <= 32'b0;
          bias_addr_buf <= 32'b0;
          lhs_addr_buf <= 32'b0;
          rhs_addr_buf <= 32'b0;
          lhs_offset_buf <=32'b0;
          dst_offset_buf <=32'b0;
          activation_min_buf <=32'b0;
          activation_max_buf <=32'b0;
          dst_multi_addr_buf <=32'b0;
          dst_shifts_addr_buf <=32'b0; 
          dst_addr_buf <=32'b0;
        end
        else if (nice_req_valid & nice_req_ready &  (nice_req_instr[6:0] == 7'b0101011)) begin
                case (nice_req_instr[31:25])
                  7'b0000001: begin
                    status_nice[1:0] <= 2'b11;
                    rhs_rows_buf <= nice_req_rs1;
                    lhs_rows_buf <= nice_req_rs2;
                    rhs_cols_buf <= rhs_cols_buf;
                    bias_addr_buf <= bias_addr_buf;
                    lhs_addr_buf <= lhs_addr_buf;
                    rhs_addr_buf <= rhs_addr_buf;
                    lhs_offset_buf <= lhs_offset_buf;
                    dst_offset_buf <= dst_offset_buf;
                    activation_min_buf <= activation_min_buf;
                    activation_max_buf <= activation_max_buf;
                    dst_multi_addr_buf <= dst_multi_addr_buf;
                    dst_shifts_addr_buf <= dst_shifts_addr_buf; 
                    dst_addr_buf <= dst_addr_buf;
                  end
                  7'b0000010: begin
                    status_nice[3:2] <= 2'b11;
                    rhs_rows_buf <= rhs_rows_buf;
                    lhs_rows_buf <= lhs_rows_buf;
                    rhs_cols_buf <= nice_req_rs1;
                    bias_addr_buf <= nice_req_rs2;
                    lhs_addr_buf <= lhs_addr_buf;
                    rhs_addr_buf <= rhs_addr_buf;
                    lhs_offset_buf <= lhs_offset_buf;
                    dst_offset_buf <= dst_offset_buf;
                    activation_min_buf <= activation_min_buf;
                    activation_max_buf <= activation_max_buf;
                    dst_multi_addr_buf <= dst_multi_addr_buf;
                    dst_shifts_addr_buf <= dst_shifts_addr_buf; 
                    dst_addr_buf <= dst_addr_buf;
                  end
                  7'b0000100: begin
                    status_nice[5:4] <= 2'b11;
                    rhs_rows_buf <= rhs_rows_buf;
                    lhs_rows_buf <= lhs_rows_buf;
                    rhs_cols_buf <= rhs_cols_buf;
                    bias_addr_buf <= bias_addr_buf;
                    lhs_addr_buf <= nice_req_rs1;
                    rhs_addr_buf <= nice_req_rs2;
                    lhs_offset_buf <= lhs_offset_buf;
                    dst_offset_buf <= dst_offset_buf;
                    activation_min_buf <= activation_min_buf;
                    activation_max_buf <= activation_max_buf;
                    dst_multi_addr_buf <= dst_multi_addr_buf;
                    dst_shifts_addr_buf <= dst_shifts_addr_buf; 
                    dst_addr_buf <= dst_addr_buf;
                  end      
                  7'b0001000: begin
                    status_nice[7:6] <= 2'b11;
                    rhs_rows_buf <= rhs_rows_buf;
                    lhs_rows_buf <= lhs_rows_buf;
                    rhs_cols_buf <= rhs_cols_buf;
                    bias_addr_buf <= bias_addr_buf;
                    lhs_addr_buf <= lhs_addr_buf;
                    rhs_addr_buf <= rhs_addr_buf;
                    lhs_offset_buf <= nice_req_rs1;
                    dst_offset_buf <= nice_req_rs2;
                    activation_min_buf <= activation_min_buf;
                    activation_max_buf <= activation_max_buf;
                    dst_multi_addr_buf <= dst_multi_addr_buf;
                    dst_shifts_addr_buf <= dst_shifts_addr_buf; 
                    dst_addr_buf <= dst_addr_buf;
                  end
                  7'b0010000: begin
                    status_nice[9:8] <= 2'b11;
                    rhs_rows_buf <= rhs_rows_buf;
                    lhs_rows_buf <= lhs_rows_buf;
                    rhs_cols_buf <= rhs_cols_buf;
                    bias_addr_buf <= bias_addr_buf;
                    lhs_addr_buf <= lhs_addr_buf;
                    rhs_addr_buf <= rhs_addr_buf;
                    lhs_offset_buf <= lhs_offset_buf;
                    dst_offset_buf <= dst_offset_buf;
                    activation_min_buf <= nice_req_rs1;
                    activation_max_buf <= nice_req_rs2;
                    dst_multi_addr_buf <= dst_multi_addr_buf;
                    dst_shifts_addr_buf <= dst_shifts_addr_buf; 
                    dst_addr_buf <= dst_addr_buf;
                  end
                  7'b0100000: begin
                    status_nice[11:10] <= 2'b11;
                    rhs_rows_buf <= rhs_rows_buf;
                    lhs_rows_buf <= lhs_rows_buf;
                    rhs_cols_buf <= rhs_cols_buf;
                    bias_addr_buf <= bias_addr_buf;
                    lhs_addr_buf <= lhs_addr_buf;
                    rhs_addr_buf <= rhs_addr_buf;
                    lhs_offset_buf <= lhs_offset_buf;
                    dst_offset_buf <= dst_offset_buf;
                    activation_min_buf <= activation_min_buf;
                    activation_max_buf <= activation_max_buf;
                    dst_multi_addr_buf <= nice_req_rs1;
                    dst_shifts_addr_buf <= nice_req_rs2; 
                    dst_addr_buf <= dst_addr_buf;
                  end 
                  7'b1000000: begin
                    status_nice[12] <= 1;
                    rhs_rows_buf <= rhs_rows_buf;
                    lhs_rows_buf <= lhs_rows_buf;
                    rhs_cols_buf <= rhs_cols_buf;
                    bias_addr_buf <= bias_addr_buf;
                    lhs_addr_buf <= lhs_addr_buf;
                    rhs_addr_buf <= rhs_addr_buf;
                    lhs_offset_buf <= lhs_offset_buf;
                    dst_offset_buf <= dst_offset_buf;
                    activation_min_buf <= activation_min_buf;
                    activation_max_buf <= activation_max_buf;
                    dst_multi_addr_buf <= dst_multi_addr_buf;
                    dst_shifts_addr_buf <= dst_shifts_addr_buf; 
                    dst_addr_buf <= nice_req_rs1;
                  end             
                endcase
            end
            else begin
              status_nice[12] <= 1;
              rhs_rows_buf <= rhs_rows_buf;
              lhs_rows_buf <= lhs_rows_buf;
              rhs_cols_buf <= rhs_cols_buf;
              bias_addr_buf <= bias_addr_buf;
              lhs_addr_buf <= lhs_addr_buf;
              rhs_addr_buf <= rhs_addr_buf;
              lhs_offset_buf <= lhs_offset_buf;
              dst_offset_buf <= dst_offset_buf;
              activation_min_buf <= activation_min_buf;
              activation_max_buf <= activation_max_buf;
              dst_multi_addr_buf <= dst_multi_addr_buf;
              dst_shifts_addr_buf <= dst_shifts_addr_buf; 
              dst_addr_buf <= dst_addr_buf;
            end  
        end
    

//multi-cycle instruction (start calculate) logic
assign start = nice_req_ready & nice_req_valid & (nice_req_instr[31:25]==7'b1000000) & (nice_req_instr[6:0] == 0101011) & (status_nice[11:0] == 12'b1111_1111_1111);
assign nice_rsp_1cyc_type  = ((nice_req_instr[31:25]==7'b0000001)||(nice_req_instr[31:25]==7'b0000010)||(nice_req_instr[31:25]==7'b0000100)||(nice_req_instr[31:25]==7'b0001000)||(nice_req_instr[31:25]==7'b0010000)||(nice_req_instr[31:25]==7'b0100000))? 1 : 0;
assign nice_rsp_1cyc_dat_1 =(((nice_req_instr[31:25]==7'b0000001)||(nice_req_instr[31:25]==7'b0000010)||(nice_req_instr[31:25]==7'b0000100)||(nice_req_instr[31:25]==7'b0001000)||(nice_req_instr[31:25]==7'b0010000)||(nice_req_instr[31:25]==7'b0100000))& (nice_req_instr[6:0] == 0101011)) ? 1 :0;

/*
self_fifo_1bit u_err_fifo(
    .sys_clk      (nice_clk)  ,
    .sys_rst_n    (nice_rst_n)  ,
    .data_in      (err_in)  ,
    .wr_en        (wr_en)  ,
    .rd_en        (rd_en)  ,
    .data_out     (nice_rsp_multicyc_err)  ,
    .full         ()  ,
    .empty        ()
);
*/

//multi-cycle instruction err (1 kind only):The input parameters are deficient 
//which means that the results cannot be trusted, and there may be random data contaminating the memory
reg multi_err;

always @ (posedge nice_clk or negedge nice_rst_n) begin
  if (!nice_rst_n)begin
    multi_err <= 0;
  end
  else begin
    if (nice_req_valid && nice_req_ready && (nice_req_instr[31:25] == 7'b1000000) ) begin
      if (status_nice [11:0] == 12'b1111_1111_1111 ) begin
        multi_err <= 0;
      end
      else begin
        multi_err <= 1;
      end      
    end
    else begin
      multi_err <= multi_err;
    end
  end
end

//multi-response channel logic
reg nice_rsp_multicyc_valid_reg;
assign nice_rsp_multicyc_valid = nice_rsp_multicyc_valid_reg;
always @(posedge nice_clk) begin
  if (fin) begin
    nice_rsp_multicyc_valid_reg <= 1;
  end
  else if (nice_rsp_multicyc_ready && nice_rsp_multicyc_valid) begin
    nice_rsp_multicyc_valid_reg <= 0;
  end
end


endmodule