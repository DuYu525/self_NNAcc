module self_fifo #(parameter DATA_WIDTH = 32, FIFO_DEPTH = 1)
(
    input   wire    sys_clk,
    input   wire    sys_rst_n,
    input   wire    [DATA_WIDTH - 1:0]  data_in,
    input   wire    wr_en,
    input   wire    rd_en,

    output  wire    [DATA_WIDTH - 1:0]  data_out,
    output  wire    full,
    output  wire    empty
);

reg [DATA_WIDTH-1 : 0]  Mem [(2**FIFO_DEPTH)-1 : 0];
reg [FIFO_DEPTH-1 : 0]  wr_addr;
reg [FIFO_DEPTH-1 : 0]  rd_addr;
reg [FIFO_DEPTH-1 : 0]  num_data;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
//        genvar i;
//        generate;
            for (integer i=0; i<(2**FIFO_DEPTH); i=i+1) begin
                Mem[i] <= 0;
            end
//        endgenerate
    end
    else if ((wr_en) && (full == 1'b0)) begin
        Mem [wr_addr] <= data_in;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        wr_addr <= 0;
    end
    else if((wr_en) && (full == 1'b0)) begin
        wr_addr <= wr_addr + 1;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)begin
        rd_addr <= 0;
    end
    else begin
        rd_addr <= rd_addr + 1;
    end
end
assign data_out = Mem[rd_addr];
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        num_data <= 0;
    end
    else if ( (wr_en && !full) && (rd_en && !empty) )
        num_data <= num_data;
    else if (wr_en && !full)
        num_data <= num_data + 1;
    else if (rd_en && !empty)
        num_data <= num_data - 1;
end

assign full = (num_data == (2**FIFO_DEPTH)) ? 1'b1 : 1'b0;
assign empty = (num_data == 0) ? 1'b1 : 1'b0;


endmodule