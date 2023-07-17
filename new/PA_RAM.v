//32 bit input, 8*16 bit output, cross-coded address, RAM-combination.
module PA_RAM #(parameter ADDR_WIDTH = 13, DATA_WIDTH = 8, CHANNEL_WIDTH = 16)
(
    input clk,
    input [ADDR_WIDTH-1:0] addr,
    input [4*DATA_WIDTH - 1 : 0] data_in,
    output [CHANNEL_WIDTH * DATA_WIDTH -1 : 0] data_out,
    input  [31:0] rhs_cols,
    input we  
);


wire    [8:0]   ram_addr [15:0];
wire    [31:0]  ram_data [15:0];
wire    [15:0]  ram_cs;
wire    [15:0]  ram_we;
wire    [15:0]  wr_cs;

assign ram_we = we ? wr_cs : 16'b0;
assign ram_cs = we ? wr_cs : 16'b1111_1111_1111_1111;

/*
assign ram_cs = (addr < rhs_cols[ADDR_WIDTH-1:0]) ? 16'b0000_0000_0000_0001:
                ((addr > rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 2 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0000_0000_0000_0010:
                ((addr > 2*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 3 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0000_0000_0000_0100:
                ((addr > 3*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 4 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0000_0000_0000_1000:
                ((addr > 4*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 5 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0000_0000_0001_0000:
                ((addr > 5*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 6 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0000_0000_0010_0000:
                ((addr > 6*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 7 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0000_0000_0100_0000:
                ((addr > 7*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 8 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0000_0000_1000_0000:
                ((addr > 8*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 9 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0000_0001_0000_0000:
                ((addr > 9*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 10 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0000_0010_0000_0000:
                ((addr > 10*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 11 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0000_0100_0000_0000:
                ((addr > 11*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 12 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0000_1000_0000_0000:
                ((addr > 12*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 13 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0001_0000_0000_0000:
                ((addr > 13*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 14 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0010_0000_0000_0000:
                ((addr > 14*rhs_cols[ADDR_WIDTH-1:0]) &  (addr < 15 * rhs_cols[ADDR_WIDTH-1:0])) ? 16'b0100_0000_0000_0000:
                16'b1000_0000_0000_0000;

*/

genvar i;
generate
    for (i=0; i <16; i = i+1) begin
        
   

        assign data_out[(i*8+7):i*8] = ( ~we && (addr[1:0] == 2'b00)) ? ram_data[i][7:0] : 
                                        (~we && (addr[1:0] == 2'b01)) ? ram_data[i][15:8] : 
                                       ( ~we && (addr[1:0] == 2'b10)) ? ram_data[i][23:16] : 
                                        (~we && (addr[1:0] == 2'b11)) ? ram_data[i][31:24] : 
                                        'hz;


        assign ram_data[i] = ram_we[i] ? data_in : 'hz;
        assign ram_addr[i] = we ? addr [8:0] :
                                addr [10 : 2];
                                
         single_port_sync_ram #(9,32,16) u_wieght_RAM(
            .clk    (clk), 
            .addr   (ram_addr[i]), 
            .data   (ram_data[i]), 
            .cs     (ram_cs[i]), 
            .we     (ram_we[i]), 
            .oe     (1'b1)
        );
   end
endgenerate


decoder4_16 u_decoder(
    .code           (addr [12 : 9] ),
    .output_data    (wr_cs)
);

endmodule