module GEMM_tb  (

);

    reg clk;
    reg rst_n;

    //input wire
    reg nice_req_valid;
    reg [31:0] nice_req_instr, nice_req_rs1, nice_req_rs2;
    reg nice_rsp_multicyc_ready;
    
    reg nice_icb_cmd_ready;
    reg nice_icb_rsp_valid;
    reg [31:0] nice_icb_rsp_rdata;
    reg nice_icb_rsp_err;

    //output wire
    wire nice_req_ready;
    wire nice_rsp_1cyc_type;
    wire [31:0] nice_rsp_1cyc_dat;
    wire nice_rsp_1cyc_err;
    wire nice_rsp_multicyc_valid;
    wire [31:0] nice_rsp_multicyc_dat;
    wire nice_rsp_multicyc_err;

    wire nice_icb_cmd_valid;
    wire [31:0] nice_icb_cmd_addr;
    wire nice_icb_cmd_read;
    wire [31:0] nice_icb_cmd_wdata;
    wire [1:0] nice_icb_cmd_size;
    wire nice_mem_holdup;
    
    wire nice_icb_rsp_ready;


    NICE_GEMM_top u_NICE_GEMM(
        .nice_clk   (clk),
        .nice_rst_n (rst_n),
        .nice_req_valid (nice_req_valid),
        .nice_req_ready (nice_req_ready),
        .nice_req_instr (nice_req_instr),
        .nice_req_rs1       (nice_req_rs1),
        .nice_req_rs2       (nice_req_rs2),
        .nice_req_rs1_1     (0),
        .nice_req_rs2_1     (0),
        .nice_req_mmode     (0),

        .nice_rsp_1cyc_type     (nice_rsp_1cyc_type),
        .nice_rsp_1cyc_dat      (nice_rsp_1cyc_dat),
        .nice_rsp_1cyc_dat_1    (),
        .nice_rsp_1cyc_err      (nice_rsp_1cyc_err),

        .nice_rsp_multicyc_valid    (nice_rsp_multicyc_valid),
        .nice_rsp_multicyc_ready    (nice_rsp_multicyc_ready),
        .nice_rsp_multicyc_dat      (nice_rsp_multicyc_dat),
        .nice_rsp_multicyc_err      (nice_rsp_multicyc_err),

        .nice_icb_cmd_valid         (nice_icb_cmd_valid),
        .nice_icb_cmd_ready         (nice_icb_cmd_ready),
        .nice_icb_cmd_addr          (nice_icb_cmd_addr),
        .nice_icb_cmd_read          (nice_icb_cmd_read),
        .nice_icb_cmd_wdata         (nice_icb_cmd_wdata),
        .nice_icb_cmd_size          (nice_icb_cmd_size),
        .nice_mem_holdup            (nice_mem_holdup),

        .nice_icb_rsp_valid         (nice_icb_rsp_valid),
        .nice_icb_rsp_ready         (nice_icb_rsp_ready),
        .nice_icb_rsp_rdata         (nice_icb_rsp_rdata),
        .nice_icb_rsp_err           (nice_icb_rsp_err)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        nice_req_valid = 0;
        nice_rsp_multicyc_ready = 0;
        nice_icb_cmd_ready = 0;
        nice_icb_rsp_valid = 0;
        nice_icb_rsp_rdata = 0;
        nice_icb_rsp_err = 0;
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
        nice_icb_cmd_ready = 1;
        nice_icb_rsp_valid = 1;

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
        
        #100;
        wait (clk == 1);
        
        #10;
        wait (clk == 1);
        
        #1000;
        
        end


endmodule