`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/16 10:02:13
// Design Name: 
// Module Name: PE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PE(
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire [7:0] data_in,
    output reg [7:0] data_out,
    input wire [7:0] weight_in,
    output reg [7:0] weight_out,
    output reg [31:0] sum
    );
    
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            data_out <= 0;
            weight_out <= 0;
            sum <= 0;
        end
        else if(en) begin
                data_out <= data_in;
                weight_out <= weight_in;
                
                sum <= data_in[7]^weight_in[7] ? sum - weight_in[6:0]*data_in[6:0] :sum + weight_in[6:0]*data_in[6:0];
        end
    end
endmodule
