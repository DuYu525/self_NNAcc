module PA_SM(
    input   clk,
    input   rst_n,
    input   start,
    input   wire [31:0] rhs_rows,
    input   wire [31:0] rhs_cols,
    input   wire [31:0] lhs_rows,
    input   wire data_rd_rdy,
    output  reg data_rd_acq,
    input   weight_rd_rdy,
    output  wire out_weight_rd_acq,
    output  wire out_dst_wr_rdy,
    input   dst_wr_acq,
    output  wire [3:0] result_addr,
    output  wire [8:0] rd_RAM_addr,
    output  wire [12:0]  wr_RAM_addr,
    output  PA_en,
    output  ram_wr, 

    output  buf_wr,
    output  wire [1:0] buf_wr_sel,
    output  wire [1:0] state,
    output  wire rstn_row_sum
);

reg weight_rd_acq ;
reg dst_wr_rdy ;
reg [3:0] counter_Result;
reg [31:0] counter_Rhs_rows;
reg [31:0] counter_Lhs_rows;
reg [31:0] counter_Rhs_cols;

reg [3:0] counter_rst_n;

wire [31:0] buffer_wr_sel;
assign buf_wr_sel = buffer_wr_sel[1:0];
assign buffer_wr_sel = (state == 2'b01) ? counter_Rhs_cols - rhs_cols : 32'b0;

assign wr_RAM_addr = {counter_Rhs_rows[3:0],counter_Rhs_cols[8:0]};
assign rd_RAM_addr = {counter_Rhs_cols[8:0]};

assign PA_en = data_rd_acq & data_rd_rdy;
assign ram_wr = weight_rd_rdy & weight_rd_acq & (counter_Rhs_cols < rhs_cols);
assign buf_wr = weight_rd_rdy & weight_rd_acq & (counter_Rhs_cols >= rhs_cols);
assign result_addr = counter_Result;
assign out_weight_rd_acq = weight_rd_acq;
assign out_dst_wr_rdy = dst_wr_rdy;
always @ (posedge clk or negedge counter_rst_n[0]) begin
    if (~counter_rst_n[0]) begin
        counter_Rhs_cols <= 32'b0;
    end
    else if (PA_en || ram_wr || buf_wr) begin
        

        if (   (state != 2'b01) && (counter_Rhs_cols==(rhs_cols - 1))  )begin
            counter_Rhs_cols <= 32'b0;
        end

        //In the final of state "01", bias , dst_multi , dst_shift should be loaded in;
        else if (counter_Rhs_cols==(rhs_cols + 2)) begin
            counter_Rhs_cols <= 32'b0;
        end
        else begin
            
            counter_Rhs_cols <= counter_Rhs_cols + 1;
        end  
    end
    else begin
        counter_Rhs_cols <= counter_Rhs_cols;
    end
end

always @ (posedge clk or negedge counter_rst_n[1]) begin
    if (~counter_rst_n[1]) begin
        counter_Lhs_rows <= 32'b0;
    end
    else if ((state[1] == 1) &( counter_Rhs_cols==(rhs_cols-1)) ) begin
        counter_Lhs_rows <= counter_Lhs_rows + 4;
    end
    else begin
        counter_Lhs_rows <= counter_Lhs_rows;
    end
end

always @ (posedge clk or negedge counter_rst_n[2]) begin
    if (~counter_rst_n[2]) begin
        counter_Rhs_rows <= 32'b0;
    end
    
    else if ((state == 2'b10)&(counter_Rhs_rows==(rhs_rows-1))&(counter_Rhs_cols==(rhs_cols-1))) begin
        counter_Rhs_rows <= counter_Rhs_rows + 16;
    end
    
    else if ((state == 2'b01)&(counter_Rhs_cols==(rhs_cols+2))) begin
        counter_Rhs_rows <= counter_Rhs_rows + 1;
    end
    else begin
        counter_Rhs_rows <= counter_Rhs_rows;
    end
end

always @ (posedge clk or negedge counter_rst_n[3]) begin
    if (~counter_rst_n[3]) begin
        counter_Result <= 4'b0;
    end
    else if (dst_wr_rdy & dst_wr_acq) begin
        counter_Result <= counter_Result + 1;
    end
    else begin
        counter_Result <= counter_Result;
    end
end

//state machine
//state 00 : idle
//state 01 : read weight
//state 10 : read data & calculate
//state 11 : read finish & write result
reg [1:0] current_state;
reg [1:0] next_state;
assign state = current_state;
 
always @ (posedge clk or negedge rst_n) begin

    if (!rst_n) begin
        current_state <= 2'b00 ;
    end
    else  begin
        current_state <= next_state;
    end

    if (current_state != next_state) begin
        case (current_state)
            2'b00 : begin
                counter_rst_n[0] = 0;
                counter_rst_n[1] = 0;
                counter_rst_n[2] = 0;
                counter_rst_n[3] = 0; 
            end
            2'b01 : begin
                counter_rst_n[0] = 0;
                counter_rst_n[1] = 0;
                counter_rst_n[2] = 1;
                counter_rst_n[3] = 0; 
            end
            2'b10 : begin
                counter_rst_n[0] = 0;
                counter_rst_n[1] = 1;
                counter_rst_n[2] = 1;
                counter_rst_n[3] = 0; 
            end
            2'b11 : begin
                if (next_state == 2'b10)begin
                    counter_rst_n[0] = 0;
                    counter_rst_n[1] = 1;
                    counter_rst_n[2] = 1;
                    counter_rst_n[3] = 0; 
                end
                else if (next_state == 2'b01)begin
                    counter_rst_n[0] = 0;
                    counter_rst_n[1] = 0;
                    counter_rst_n[2] = 1;
                    counter_rst_n[3] = 0; 
                end
                else begin
                    counter_rst_n[0] = 0;
                    counter_rst_n[1] = 0;
                    counter_rst_n[2] = 0;
                    counter_rst_n[3] = 0; 
                end
            end
        endcase
    end
    else begin
        counter_rst_n[0] = 1;
        counter_rst_n[1] = 1;
        counter_rst_n[2] = 1;
        counter_rst_n[3] = 1; 
    end
end


always @ (*) begin
    case (current_state)
        2'b00 : begin
                    if (start == 1)begin
                        next_state = 2'b01; 
                    end
                    else begin
                        next_state = 2'b00; 
                    end 
                end
        2'b01 : begin
                    if ((counter_Rhs_cols==(rhs_cols+2) & (counter_Rhs_rows[3:0] == 15) )||(next_state != 2'b01))begin
                        next_state = 2'b10;
                    end
                    else begin
                        next_state = 2'b01;
                    end 
                end
        2'b10 : begin
                     if (counter_Rhs_cols == (rhs_cols - 1) )begin
                        next_state = 2'b11;
                    end
                    else begin
                        next_state = 2'b10;
                    end 
                end
        2'b11 : begin
                     if (counter_Result == 4'b1111)begin
                        if ((counter_Rhs_rows == rhs_rows)&&(counter_Lhs_rows == lhs_rows)) begin
                            next_state = 2'b00;
                        end
                        else if ((counter_Lhs_rows >= lhs_rows - 1)) begin
                            next_state = 2'b01;
                        end
                        else begin
                            next_state = 2'b10;
                        end
                    end
                    else begin
                        next_state = 2'b11;
                    end 
                end
    endcase
end

always @(*) begin
  case (current_state)
    2'b00: begin
        weight_rd_acq   = 0; 
        dst_wr_rdy      = 0;
        data_rd_acq     = 0;
    end
    2'b01: begin
        weight_rd_acq   = 1; 
        dst_wr_rdy      = 0;
        data_rd_acq     = 0;
    end
    2'b10: begin
        weight_rd_acq   = 0; 
        dst_wr_rdy      = 0;
        data_rd_acq     = 1;
    end
    2'b11: begin
        weight_rd_acq   = 0; 
        dst_wr_rdy      = 1;
        data_rd_acq     = 0;
    end
  endcase
end


endmodule