//////////////////////////////////////////////////////////////////////////////////
// Company: Personal
// Engineer: Matbi / Austin
//
// Create Date:
// Design Name: 4 bit counter
// Module Name: counter_4_bit
// Project Name:
// Target Devices:
// Tool Versions:
// Description: when posedge clk , add value of '1'
//              reset value is '0'
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
 
module counter_4_bit(
    input clk,
    input reset_n,
    output [3:0] cnt
    );
     
    reg [3:0] cnt;
    wire cnt_value = 1;
    always @ (posedge clk or negedge reset_n) begin
        if(!reset_n) begin   // (~reset_n) , (reset_n == 0)
            cnt <= 4'b0;
        end
        else begin
            cnt <= cnt + cnt_value;
        end
    end
endmodule