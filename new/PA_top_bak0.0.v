module PA_top(
//
    input   clk,
    input   en,
    input   rst_n,
    input   start,
//IF to memIF
    inout   wire [31:0] data,
    input   read_rdy,
    output  read_acq,
    output  write_rdy,
    input   write_acq,
    output  wire [1:0] state;
//IF to Instruction
    input   wire [31:0] rhs_rows,
    input   wire [31:0] rhs_cols,
    input   wire [31:0] lhs_rows
);

//This module intergrates 2 sets of FIFOs, 4 Pe_array and some interface logic.

//signal declare
    reg en;
    reg [3:0] out_sel;
    wire [31:0] result[3:0];

    reg [15:0] weightfifo_rd;
    reg [15:0] weightfifo_wr;
    reg [31:0] weightfifo_wdata [15:0];
    wire [7:0] weightfifo_rdata [15:0];
    wire [15:0] weightfifo_empty;
    wire [15:0] weightfifo_full;

    reg [3:0] datafifo_rd;
    reg [3:0] datafifo_wr;
    reg [31:0] datafifo_wdata [3:0];
    wire [7:0] datafifo_rdata [3:0];
    wire [3:0] datafifo_empty;
    wire [3:0] datafifo_full;

    reg [63:0] counter1;
    wire PA_readctr;
    wire [1:0] PA_writectr;


    wire counter1_rst_n;
//moitoring counter
	always @(posedge clk or negedge counter1_rst_n) begin
		if(~counter1_rst_n) begin
            
			    counter1 <= 64'b0;
            
		end
		else if(en) begin
            if(counter1[31:0] == rhs_rows)begin
                counter1[63:32] = counter1[63:32] + 1;
                counter1[31:0] = 32'b0;
            end
            else begin
    			counter1 <= counter1 + 1; 
            end
		end
        else begin
            counter1 <= counter1;
        end
	end


    //state machine
    //state 0 : idle
    //state 1 : read weight
    //state 2 : read data & calculate
    //state 3 : read finish & write result
    reg [1:0] current_state;
    reg [1:0] next_state;
    assign state = current_state;
     
    always @ (posedge clk or negedge _rst_n) begin
    {
        if (!rst_n) begin
            current_state <= 2'b00 ;
        end
        else  begin
            current_state <= next_state;
        end
    }end



    always @ (*) begin
        case (current_state)
            2'b00 : begin
                        if (start == 1)begin
                            next_state = 2'b01; 
                            counter1_rst_n = 0;
                        end
                        else begin
                            next_state = 2'b00; 
                            counter1_rst_n = 1;
                        end 
                    end
            2'b01 : begin
                        if (counter1[63:32] == rhs_cols )begin
                            next_state = 2'b10;
                            counter1_rst_n = 0; 
                        end
                        else begin
                            next_state = 2'b01;
                            counter1_rst_n = 1; 
                        end 
                    end
            2'b10 : begin
                         if (counter1[31:0] == rhs_rows )begin
                            next_state = 2'b11;
                            counter1_rst_n = 1; 
                        end
                        else begin
                            next_state = 2'b10;
                            counter1_rst_n = 1; 
                        end 
                    end
            2'b11 : begin
                         if (counter1[4:0] == 5'b10000)begin
                            if (coun)
                            next_state = 2'b10;
                            counter1_rst_n = 0; 
                        end
                        else begin
                            next_state = 2'b11;
                            counter1_rst_n = 1; 
                        end 
                    end
        endcase
    end


    always @ (*) begin
       case (current_state)
            2'b00 : begin 
                weight_wr = 0;
            end
            2'b01 : begin
                weight_wr = 1;
            end
            2'b10 : begin
                weight_wr = 0;
            end
            2'b11 : begin
                weight_wr = 0;
            end
       endcase
    end

//instantiate module
    genvar i;
    generate
        for (i=0; i<16; i=i+1) begin
            FIFO #(8, 9) u_weight_fifo(
                .clk(clk),
                .resetn(rst_n),
                .rd(weightfifo_rd[i]),
                .wr(weightfifo_wr[i]),
                .w_data(weightfifo_wdata[i]),
                .empty(weightfifo_empty[i]),
                .full(weightfifo_full[i]),
                .r_data(weightfifo_rdata[i])
                );
        end
        /*
        for(i=0; i<4; i=i+1) begin
            FIFO #(8, 3) u_data_fifo(
                .clk(clk),
                .resetn(rst_n),
                .rd(datafifo_rd[i]),
                .wr(datafifo_wr[i]),
                .w_data(datafifo_wdata[i]),
                .empty(datafifo_empty[i]),
                .full(datafifo_full[i]),
                .r_data(datafifo_rdata[i])
                );
        end
        */
        pingpang_buffer #(8,2,2) u_data_buffer (
            .clk(clk),
            .rst_n(rst_n),
            .wr_acq(wr_acq),
            .wr_rdy(wr_rdy), 
            .wr_data(wr_data),
            .rd_acq(rd_acq),
            .rd_rdy(rd_rdy),
            .rd_data(rd_data)
        );

        for(i=0; i<4; i=i+1) begin
            PE_array u_PE_array(
                .clk       (clk),
                .rst_n     (rst_n),
                .en        (en),
                .data_in0  (datafifo_rdata[0]),
                .data_in1  (datafifo_rdata[1]),
                .data_in2  (datafifo_rdata[2]),
                .data_in3  (datafifo_rdata[3]),
                .weight_in0(weightfifo_rdata[i]),
                .weight_in1(weightfifo_rdata[i+4]),
                .weight_in2(weightfifo_rdata[i+8]),
                .weight_in3(weightfifo_rdata[i+12]),
                .out_sel   (out_sel),
                .result    (result[i])
                );
        end
    endgenerate




    datafifo_rdata = PA_readctr = 0 ? 4'b0000:
                                      4'b1111;

    weightfifo_rdata = PA_readctr = 0 ? 16'b0000_0000_0000_0000:
                                        16'b1111_1111_1111_1111;


    datafifo_wdata =    (PA_writectr == 2'b01) ? 4'b0000:
                        counter1[1:0]==2'b00 ? 4'b0001:
                        counter1[1:0]==2'b01 ? 4'b0010:
                        counter1[1:0]==2'b10 ? 4'b0100:
                        counter1[1:0]==2'b11 ? 4'b1000;




endmodule