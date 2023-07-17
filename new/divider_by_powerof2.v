/**
 * @brief           Rounding divide by power of two.
 * @param[in]       dividend - Dividend
 * @param[in]       exponent (complement code without signal sym )- Divisor = power(2, exponent)
 *                             Range: [0, 31]
 * @return          Rounded result of division. Midpoint is rounded away from zero.
 *
 */

module divider_by_powerof2(
    input   [31:0]  dividend,
    input   [5:0]  exponent,
    output  [31:0]  quotient
);
    wire    [31:0] divider_array [31:0];
    
    
    assign divider_array[0] = dividend;
    generate
        assign divider_array[0] = dividend;
        for (i=1 ; i<32 ; i=i+1) begin
            genvar j;
            generate
                if (dividend[i-1] == 0) begin
                    for(j=0; j<i; j++)begin
                        assign divider_array[i][31-j] = 0;
                    end
                    assign divider_array[i][31-i : 0] = dividend[31:i];
                end
                else begin
                    for(j=1; j<i; j++)begin
                        assign divider_array[i][32-j] = 0;
                    end
                    assign divider_array[i][32-i : 0] = {0,dividend[31:i]} + 1;
                end
            endgenerate
        end  
    endgenerate
        
    assign quotient = divider_array [exponent];
    
endmodule