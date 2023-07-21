module NICE_GEMM_top (
    input   nice_clk,
    input   nice_rst_n,

    //Instruc_IF
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

    //Mem_IF
    output  nice_icb_cmd_valid,
    input   nice_icb_cmd_ready,
    output  [31:0]  nice_icb_cmd_addr,
    output  nice_icb_cmd_read,
    output  [31:0]  nice_icb_cmd_wdata,
    output  [1:0]   nice_icb_cmd_size,
    output  nice_mem_holdup,

    input   nice_icb_rsp_valid,
    output  nice_icb_rsp_ready,
    input   [31:0]  nice_icb_rsp_rdata,
    input   nice_icb_rsp_err

);

    wire start;
    wire [31:0] data;
    wire [31:0] result_out;
    wire read_rdy;
    wire read_acq;
    wire write_rdy;
    wire write_acq;
    wire [1:0]      state;
    wire [8:0]      rd_RAM_addr;
    wire [12:0]     wr_RAM_addr;
    wire [31:0]     rhs_rows;
    wire [31:0]     rhs_cols;
    wire [31:0]     lhs_rows;
    wire [31:0]     dst_addr;
    wire [31:0]     lhs_addr;
    wire [31:0]     rhs_addr;
    wire [31:0]     lhs_offset;
    wire [31:0]     dst_offset;
    wire [31:0]     activation_min;
    wire [31:0]     activation_max;

    PA_top u_PA_top(
        .clk        (nice_clk),
        .rst_n      (nice_rst_n),
        .start      (start),
        .data       (data),
        .result_out (result_out),
        .read_rdy   (read_rdy),
        .read_acq   (read_acq),
        .write_rdy  (write_rdy),
        .write_acq  (write_acq),
        .state      (state),
        .rd_RAM_addr    (rd_RAM_addr),
        .wr_RAM_addr    (wr_RAM_addr),
        .rhs_rows       (rhs_rows),
        .rhs_cols       (rhs_cols),
        .lhs_rows       (lhs_rows),

        .lhs_offset     (lhs_offset),
        .dst_offset     (dst_offset),
        .activation_min (activation_min),
        .activation_max (activation_max),

        .buf_wr                 (buf_wr),
        .buf_wr_sel             (buf_wr_sel)
    );

    InstrucIF u_instrucIF(
        .nice_clk       (nice_clk),
        .nice_rst_n     (nice_rst_n),
        .nice_req_valid     (nice_req_valid),
        .nice_req_ready     (nice_req_ready),
        .nice_req_instr     (nice_req_instr),
        .nice_req_rs1       (nice_req_rs1),
        .nice_req_rs2       (nice_req_rs2),
        .nice_req_rs1_1     (nice_req_rs1_1),
        .nice_req_rs2_1     (nice_req_rs2_1),
        .nice_req_mmode     (nice_req_mmode),
        .nice_rsp_1cyc_type     (nice_rsp_1cyc_type),
        .nice_rsp_1cyc_dat      (nice_rsp_1cyc_dat),
        .nice_rsp_1cyc_dat_1    (nice_rsp_1cyc_dat_1),
        .nice_rsp_1cyc_err      (nice_rsp_1cyc_err),
        .nice_rsp_multicyc_valid    (nice_rsp_multicyc_valid),
        .nice_rsp_multicyc_ready    (nice_rsp_multicyc_ready),
        .nice_rsp_multicyc_dat      (nice_rsp_multicyc_dat),
        .nice_rsp_multicyc_err      (nice_rsp_multicyc_err),

        .state          (state),
        .rhs_rows       (rhs_rows),
        .lhs_rows       (lhs_rows),
        .rhs_cols       (rhs_cols),
        .dst_addr       (dst_addr),
        .lhs_addr       (lhs_addr),
        .rhs_addr       (rhs_addr),

        .lhs_offset     (lhs_offset),
        .dst_offset     (dst_offset),
        .activation_min (activation_min),
        .activation_max (activation_max),

        .dst_multi_addr         (dst_multi_addr),
        .dst_shifts_addr        (dst_shifts_addr),
        .lhs_bias_addr          (lhs_bias_addr),

        .start          (start)
    );


    wire [31:0] mem_data;
    wire [31:0] bias_addr;

    wire [31:0] dst_multi_addr;
    wire [31:0] dst_shifts_addr;
    wire [31:0] lhs_bias_addr;
    wire buf_wr;
    wire [1:0] buf_wr_sel;

    assign mem_data = (!nice_icb_cmd_read) ? result_out : 'hz;
    assign data = (nice_icb_cmd_read) ? mem_data : 'hz;
    assign bias_addr = (nice_icb_cmd_read) ? {23'b0,rd_RAM_addr} : {19'b0,wr_RAM_addr};

    MemIF u_MemIF(
        .nice_clk       (nice_clk),
        .nice_rst_n     (nice_rst_n),
        .nice_icb_cmd_valid     (nice_icb_cmd_valid),
        .nice_icb_cmd_ready     (nice_icb_cmd_ready),
        .nice_icb_cmd_addr      (nice_icb_cmd_addr),
        .nice_icb_cmd_read      (nice_icb_cmd_read),
        .nice_icb_cmd_wdata     (nice_icb_cmd_wdata),
        .nice_icb_cmd_size      (nice_icb_cmd_size),
        .nice_mem_holdup        (nice_mem_holdup),

        .nice_icb_rsp_valid     (nice_icb_rsp_valid),
        .nice_icb_rsp_ready     (nice_icb_rsp_ready),
        .nice_icb_rsp_rdata     (nice_icb_rsp_rdata),
        .nice_icb_rsp_err       (nice_icb_rsp_err),

        .state                  (state),
        .lhs_base_addr          (lhs_addr),
        .rhs_base_addr          (rhs_addr),
        .dst_base_addr          (dst_addr),
        .bias_addr              (bias_addr),
        .data                   (mem_data),
        .data_in_rdy            (read_rdy),
        .data_in_acq            (read_acq),
        .data_out_rdy           (write_rdy),
        .data_out_acq           (write_acq),

        .dst_multi_addr         (dst_multi_addr),
        .dst_shifts_addr        (dst_shifts_addr),
        .lhs_bias_addr          (lhs_bias_addr),
        .buf_wr                 (buf_wr),
        .buf_wr_sel             (buf_wr_sel)
    );

endmodule