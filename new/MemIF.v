module MemIF(
input   nice_clk,
input   nice_rst_n,
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
input   nice_icb_rsp_err,


input   [1:0]   state,
input   [31:0]  lhs_base_addr,
input   [31:0]  rhs_base_addr,
input   [31:0]  dst_base_addr,
input   [31:0]  bias_addr,
inout   [31:0]  data,
output  data_in_rdy,
input   data_in_acq,
input   data_out_rdy,
output  data_out_acq

);

assign nice_icb_cmd_valid = (state == 2'b01) ? data_in_acq :
                            (state == 2'b10) ? data_in_acq :
                            (state == 2'b11) ? data_out_rdy :
                            0;

assign nice_icb_cmd_addr = (state == 2'b01) ? lhs_base_addr + bias_addr:
                           (state == 2'b10) ? rhs_base_addr + bias_addr:
                           (state == 2'b11) ? dst_base_addr + bias_addr:
                           32'b0;

assign nice_icb_cmd_read = (state == 2'b11) ? 0 : 1; 

assign nice_icb_cmd_wdata = (state == 2'b11) ? data : 'hz;

assign nice_icb_cmd_size = 2'b10;

assign data =   (state == 2'b10) ? nice_icb_rsp_rdata:
                (state == 2'b01) ? nice_icb_rsp_rdata:
                'hz;

assign data_in_rdy = ((state == 2'b01) || (state == 2'b10)) ? (nice_icb_rsp_valid & (!nice_icb_rsp_err)) :0;

assign data_out_acq = (state == 2'b11) ? nice_icb_rsp_valid :0;

always @(posedge nice_clk or negedge nice_rst_n) begin
    if(!nice_rst_n)begin
        nice_mem_holdup       <=  0;
        nice_icb_rsp_ready    <=  0;
    end
    nice_mem_holdup       <=  nice_icb_cmd_valid & nice_icb_cmd_ready;
    nice_icb_rsp_ready    <=  nice_icb_cmd_read;
end



endmodule