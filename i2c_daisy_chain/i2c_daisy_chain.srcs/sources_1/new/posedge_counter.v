`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dhruv Shah
// 
// Create Date: 12/22/2020 11:56:35 AM
// Design Name: 
// Module Name: SIPO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 9 bit counter with tick at 8th bit.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module posedge_counter
#(parameter N=4)
(
input wire SCL, reset,
output wire tick   // q added for simulation purposes
);
//signal declaration
reg [N-1:0] r_reg;
wire [N-1:0] r_next;
always @(posedge SCL) begin
    r_reg <= r_next;
end
// Next State Logic
assign r_next = (reset == 1'b1) ? 0:
                (r_reg == 2**(N-1))? 0:r_reg + 1;
    

// output logic
assign tick = (r_reg==2**(N-1)-1) ? 1'b1 : 1'b0;

endmodule