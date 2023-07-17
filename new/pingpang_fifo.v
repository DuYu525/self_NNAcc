module PINGPANG_FIFO #(parameter DWIDTH=8, AWIDTH=1)
(
  input wire clk,
  input wire rst_n,
  input wire rd,
  input wire wr,
  input wire [4*DWIDTH-1:0] w_data,

  output wire [3:0] fifo_state,
  output wire [4*DWIDTH-1:0] r_data
);


wire [7:0] datafifo_rd;  
wire [7:0] datafifo_wr;
wire [7:0] datafifo_empty;
wire [7:0] datafifo_full;
wire [DWIDTH-1:0] datafifo_rdata [7:0];

wire [1:0] wr_flag;
wire [1:0] rd_flag;

assign wr_flag[0] = datafifo_empty[0] & datafifo_empty[1] & datafifo_empty[2] & datafifo_empty[3];
assign wr_flag[1] = datafifo_empty[4] & datafifo_empty[5] & datafifo_empty[6] & datafifo_empty[7];

assign rd_flag[0] = datafifo_full[0] & datafifo_full[1] & datafifo_full[2] & datafifo_full[3];
assign rd_flag[1] = datafifo_full[4] & datafifo_full[5] & datafifo_full[6] & datafifo_full[7];

genvar i;
    generate
        for(i=0; i<8; i=i+1) begin
            FIFO #(8, 2) u_data_fifo(
                .clk(clk),
                .resetn(rst_n),
                .rd(datafifo_rd[i]),
                .wr(datafifo_wr[i]),
                .w_data(w_data),
                .empty(datafifo_empty[i]),
                .full(datafifo_full[i]),
                .r_data(datafifo_rdata[i])
                );
            
        end
    endgenerate


always @ (posedge clk)begin
    if(wr)begin
      
    end
    else if(rd)begin
      
    end
    else begin
      
    end
end

endmodule





