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
    reg [31:0] nice_icb_cmd_wdata;
    wire [1:0] nice_icb_cmd_size;
    wire nice_mem_holdup;
    
    wire nice_icb_rsp_ready;

    reg  [7:0] mem_tb [4095 : 0];

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

    always @(posedge clk) begin
      nice_icb_rsp_rdata <= {mem_tb [nice_icb_cmd_addr] , mem_tb [nice_icb_cmd_addr+1] , mem_tb [nice_icb_cmd_addr+2] , mem_tb [nice_icb_cmd_addr+3]} ;
      nice_icb_rsp_valid = nice_icb_rsp_ready;
    end 
    
    reg [31:0] lhs_addr;
    reg [31:0] rhs_addr;
    reg [31:0] lhs_bias_addr;
    reg [31:0] dst_multi_addr;
    reg [31:0] dst_shifts_addr;
    reg [31:0] dst_addr;



    initial begin
         int i , j;
            //lhs matrix  addr = 0
            lhs_addr = 0;
            for (i = 1; i < 33 ; i=i+1 ) begin
                for (j = 1; j<33 ; j=j+1) begin
                  mem_tb [(i-1)*32+j-1] = i+j-1;
                end
            end
            //rhs_matrix  addr = 32*32  1280
            rhs_addr = 32*32;
            for (i = 1; i < 33 ; i=i+1 ) begin
                for (j = 1; j<33 ; j=j+1) begin
                  mem_tb [(i-1)*32+j-1+rhs_addr] = i+j-1;
                end
            end
            //bias
            lhs_bias_addr = 32*32*2;
            for (i = 32*32*2 ; i<32*32*2+31; i=i+4) begin
                mem_tb [i] = 0;
                mem_tb [i+1] = 0;
                mem_tb [i+2] = 0;
                mem_tb [i+3] = 1;
            end
            //dst_multi
            dst_multi_addr = 32*32*2 + 32;
            for (i = 32*32*2 + 32; i<32*32*2+63; i=i+4) begin
                mem_tb [i] = 0;
                mem_tb [i+1] = 8'hff;
                mem_tb [i+2] = 8'h86;
                mem_tb [i+3] = 8'ha0;
            end
            //dst_shifts
            dst_shifts_addr = 32*32*2 + 64;
            for (i = 32*32*2 + 64; i<32*32*2+95; i=i+4) begin
                mem_tb [i] = 0;
                mem_tb [i+1] = 0;
                mem_tb [i+2] = 0;
                mem_tb [i+3] = 2;
            end
            //dst _addr: 32*32*3
            dst_addr = 32*32*3;
       
        clk = 0;
        rst_n = 0;
        nice_req_valid = 0;
        nice_rsp_multicyc_ready = 0;
        nice_icb_cmd_ready = 0;
        
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
        nice_req_rs1= 32;
        nice_req_rs2= 32;
        nice_icb_cmd_ready = 1;
        

        #10;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b0000010,5'b0,5'b0,3'b011,5'b0,7'b0101011};
        nice_req_rs1= 32;
        nice_req_rs2= lhs_bias_addr;

        #10;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b0000100,5'b0,5'b0,3'b011,5'b0,7'b0101011};
        nice_req_rs1= lhs_addr;
        nice_req_rs2= rhs_addr;

        #10;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b0001000,5'b0,5'b0,3'b011,5'b0,7'b0101011};
        nice_req_rs1= 1;
        nice_req_rs2= 1;

        #10;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b0010000,5'b0,5'b0,3'b011,5'b0,7'b0101011};
        nice_req_rs1= 1;
        nice_req_rs2= 32'b1111_1111_1111_1111_1111_1111_1111_1111;
    

        #10;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b0100000,5'b0,5'b0,3'b011,5'b0,7'b0101011};
        nice_req_rs1= dst_multi_addr;
        nice_req_rs2= dst_shifts_addr;

        #10;
        wait (clk == 1);
        wait (nice_req_ready == 1);
        nice_req_valid = 1;
        nice_rsp_multicyc_ready = 1;
        nice_req_instr= {7'b1000000,5'b0,5'b0,3'b010,5'b0,7'b0101011};
        nice_req_rs1= dst_addr;
        nice_req_rs2= 14;
        
        #100;
        wait (clk == 1);
        
        #10;
        wait (clk == 1);
        
        #1000;
        
        end


endmodule