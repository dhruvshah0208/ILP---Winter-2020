`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Dhruv Shah
// Create Date: 12/22/2020 11:56:35 AM
// Module Name: SIPO
// Description: 
// 9 bit counter with tick at 8th bit.
//  
// 
//////////////////////////////////////////////////////////////////////////////////

module posedge_counter
(
input SCL,reset,
output tick  
);
//signal declaration
reg [3:0] r_reg;
reg [3:0] r_next;
always @(posedge SCL or posedge reset) begin
    if (reset) 
        r_reg <= 0;
    else 
        r_reg <= r_next;
end
// Next State Logic
always @(*) begin
    if (r_reg == 8)
        r_next = 0;
    else
        r_next = r_reg + 1;
end
    

// output logic
assign tick = (r_reg==8) ? SCL : 1'b0;  // Clock Masking

endmodule