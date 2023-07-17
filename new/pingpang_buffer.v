module pingpang_buffer #(parameter DWIDTH=8, AWIDTH_r=2, AWIDTH_w=2)
(
    input  wire  clk,
    input  wire  rst_n,
    input  wire  wr_acq,
    output wire wr_rdy, 
    input  wire [31:0] wr_data,
    input  wire rd_acq,
    output wire rd_rdy,
    output wire [(2**AWIDTH_r)*DWIDTH - 1:0] rd_data
);

    reg [DWIDTH-1:0] array_reg0 [(2**(AWIDTH_r))*(2**(AWIDTH_w))-1:0];
    reg [DWIDTH-1:0] array_reg1 [(2**(AWIDTH_r))*(2**(AWIDTH_w))-1:0];
    
    
    /*
        flag =  00  can be written
                01  can be read
                10  being written
                11  being read
    */
    reg [1:0] flag0;
    reg [1:0] flag1;

    reg [AWIDTH_r - 1:0] wr_addr0;
    reg [AWIDTH_w - 1:0] wr_addr1;
    reg [AWIDTH_w-1:0] rd_addr;

    wire wr_cs,rd_cs;

    assign rd_rdy = flag0[0] || flag1[0];
    assign wr_rdy = (!flag0[0]) || (!flag1[0]);
    assign wr_cs  = (flag0 == 2'b10) ? 0: 
                    (flag1 == 2'b10) ? 1:
                    (flag0 == 2'b00) ? 0:
                    1;
    assign rd_cs  = (flag0 == 2'b11) ? 0: 
                    (flag1 == 2'b11) ? 1:
                    (flag0 == 2'b01) ? 0:
                    1;


    //read & write logic
    genvar i;
    generate
        for (i=0; i<(2**AWIDTH_r); i=i+1) begin
            assign rd_data [(i+1)*DWIDTH - 1:i*DWIDTH] = rd_cs  ?   array_reg1[rd_addr + i * (2**AWIDTH_w)]:
                                                                    array_reg0[rd_addr + i * (2**AWIDTH_w)];
        end
    endgenerate
    
    always @ (posedge clk) begin
        if (wr_acq & wr_rdy) 
        begin
            if (!flag0[0])begin
                {array_reg0 [wr_addr0 * (2**AWIDTH_r) + wr_addr1 + 3] , array_reg0 [wr_addr0 * (2**AWIDTH_r) + wr_addr1 + 2] , array_reg0 [wr_addr0 * (2**AWIDTH_r) + wr_addr1 + 1] , array_reg0 [wr_addr0 * (2**AWIDTH_r) + wr_addr1 + 0] } <= wr_data;
            end
            else if (!flag1[0]) begin
                {array_reg1 [wr_addr0 * (2**AWIDTH_r) + wr_addr1 + 3] , array_reg1 [wr_addr0 * (2**AWIDTH_r) + wr_addr1 + 2] , array_reg1 [wr_addr0 * (2**AWIDTH_r) + wr_addr1 + 1] , array_reg1 [wr_addr0 * (2**AWIDTH_r) + wr_addr1 + 0] } <= wr_data;
            end
        end
    end    

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            flag0 <= 0;
            flag1 <= 0;
            wr_addr0 <= 0;
            wr_addr1 <= 0;
            rd_addr <= 0;
        end
        else begin

            if (wr_acq & wr_rdy) begin
                //The writing has been finished
                if (wr_addr0 == 2**AWIDTH_r - 1 ) begin
                    wr_addr0 <= 0;
                    wr_addr1 <= 0;
                    if (flag0 == 2'b10) begin
                        flag0 <= 2'b01;
                    end 
                    if (flag1 == 2'b10) begin
                        flag1 <= 2'b01;
                    end 
                end
                else begin
                    if (wr_addr1 >= 2**AWIDTH_w - 32/DWIDTH) begin
                        wr_addr0 <= wr_addr0 + 1;
                        wr_addr1 <= 0;
                    end
                    else begin
                        wr_addr1 <= wr_addr1 + 32/DWIDTH; 
                    end
                    if (wr_cs) begin
                        flag1 <= 2'b10;
                    end
                    else begin
                        flag0 <= 2'b10;
                    end
                end
            end 

            if (rd_acq & rd_rdy) begin
                //The reading has been finished
                if (rd_addr == 2**AWIDTH_w - 1) begin
                    rd_addr <= 0;
                    if (flag0 == 2'b11) begin
                        flag0 <= 2'b00;
                    end 
                    if (flag1 == 2'b11) begin
                        flag1 <= 2'b00;
                    end 
                end
                else begin
                    rd_addr <= rd_addr + 1;
                    if (rd_cs) begin
                        flag1 <= 2'b11;
                    end
                    else begin
                        flag0 <= 2'b11;
                    end
                end
            end


        end
    end



endmodule