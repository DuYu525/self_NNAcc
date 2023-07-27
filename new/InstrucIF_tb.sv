module InstrucIF_tb();

    reg clk;
    reg rst_n;

    //input wire
    reg nice_req_valid;
    reg [31:0] nice_req_instr, nice_req_rs1, nice_req_rs2;
    reg nice_rsp_multicyc_ready;
    reg [1:0] state;
    reg fin;

    //output wire
    wire nice_req_ready;
    wire nice_rsp_1cyc_type;
    wire [31:0] nice_rsp_1cyc_dat;
    wire nice_rsp_1cyc_err;
    wire nice_rsp_multicyc_valid;
    wire [31:0] nice_rsp_multicyc_dat;
    wire nice_rsp_multicyc_err;

    wire  [31:0]    rhs_rows;
    wire  [31:0]    lhs_rows;
    wire  [31:0]    rhs_cols;
    wire  [31:0]    dst_addr;
    wire  [31:0]    lhs_addr;
    wire  [31:0]    rhs_addr;

    wire  [31:0]    lhs_offset;
    wire  [31:0]    dst_offset;
    wire  [31:0]    activation_min;
    wire  [31:0]    activation_max;

    wire [31:0] dst_multi_addr;
    wire [31:0] dst_shifts_addr;
    wire [31:0] lhs_bias_addr;

    wire  start;

    InstrucIF u_InstrucIF(
        .nice_clk           (clk    ),
        .nice_rst_n         (rst_n  ),
        .nice_req_valid     (nice_req_valid),
        .nice_req_ready     (nice_req_ready),
        .nice_req_instr     (nice_req_instr),
        .nice_req_rs1       (nice_req_rs1),
        .nice_req_rs2       (nice_req_rs2),
        .nice_req_rs1_1     (0),
        .nice_req_rs2_1     (0),
        .nice_req_mmode     (0),

        .nice_rsp_1cyc_type (nice_rsp_1cyc_type),
        .nice_rsp_1cyc_dat  (nice_rsp_1cyc_dat),
        .nice_rsp_1cyc_dat_1    (),
        .nice_rsp_1cyc_err  (nice_rsp_1cyc_err),
        .nice_rsp_multicyc_valid    (nice_rsp_multicyc_valid),
        .nice_rsp_multicyc_ready    (nice_rsp_multicyc_ready),
        .nice_rsp_multicyc_dat      (nice_rsp_multicyc_dat),
        .nice_rsp_multicyc_err      (nice_rsp_multicyc_err),

        .state  (state),
        .fin    (fin),
        .rhs_rows   (rhs_rows),
        .lhs_rows   (lhs_rows),
        .rhs_cols   (rhs_cols),
        .dst_addr   (dst_addr),
        .lhs_addr   (lhs_addr),
        .rhs_addr   (rhs_addr),

        .lhs_offset (lhs_offset),
        .dst_offset (dst_offset),
        .activation_min (activation_min),
        .activation_max (activation_max),

        .dst_multi_addr (dst_multi_addr),
        .dst_shifts_addr    (dst_shifts_addr),
        .lhs_bias_addr  (lhs_bias_addr),

        .start      (start)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        nice_req_valid = 0;
        nice_rsp_multicyc_ready = 0;
        state = 2'b00;
        fin = 0;
        #15;
        rst_n = 1;
        #20;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b0000001,5'b0,5'b0,3'b011,5'b0,7'b0101011};
        nice_req_rs1= 1;
        nice_req_rs2= 2;

        #10;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b0000010,5'b0,5'b0,3'b011,5'b0,7'b0101011};
        nice_req_rs1= 3;
        nice_req_rs2= 4;

        #10;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b0000100,5'b0,5'b0,3'b011,5'b0,7'b0101011};
        nice_req_rs1= 5;
        nice_req_rs2= 6;

        #10;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b0001000,5'b0,5'b0,3'b011,5'b0,7'b0101011};
        nice_req_rs1= 7;
        nice_req_rs2= 8;

        #10;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b0010000,5'b0,5'b0,3'b011,5'b0,7'b0101011};
        nice_req_rs1= 9;
        nice_req_rs2= 10;
    

        #10;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b0100000,5'b0,5'b0,3'b011,5'b0,7'b0101011};
        nice_req_rs1= 11;
        nice_req_rs2= 12;

        #10;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b1000000,5'b0,5'b0,3'b010,5'b0,7'b0101011};
        nice_req_rs1= 13;
        nice_req_rs2= 14;
        wait (start == 1);
        state = 1;
        #100;
        wait (clk == 1);
        fin = 1;
        state = 0;
        #10;
        wait (clk == 1);
        fin = 0;
        #1000;
        
        end
endmodule