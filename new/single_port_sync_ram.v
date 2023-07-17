module single_port_sync_ram #(parameter ADDR_WIDTH = 4, DATA_WIDTH = 8, DEPTH = 16) (clk, addr, data, cs, we, oe);

	input clk;
	input wire [ADDR_WIDTH-1:0] addr;
	inout wire [DATA_WIDTH-1:0] data;
	input cs;
	input we;
	input oe;
	
	
	reg [DATA_WIDTH-1:0] tmp_data;
	reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];
	

	always @ (posedge clk) begin
		if(cs & we)
//			{mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]} <= data;
		mem[addr] <= data;
	end
	
	always @ (posedge clk) begin
		if(cs & ~we)
			tmp_data <= mem[addr];
	end
	
	assign data  = cs & oe & ~we ? {24'b0,tmp_data} : 'hz;
endmodule
