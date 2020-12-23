`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/22/2020 01:23:28 PM
// Design Name: 
// Module Name: serial_input_parallel_output
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
// Schematic is looking incorrect
//////////////////////////////////////////////////////////////////////////////////


module serial_input_parallel_output
#(parameter N=8)
(
input SDA,       // MSB is transmitted first in i2C
input SCL,
input reset,
input tick,
output wire [N-1:0] PO    
);
reg [N-1:0] r_reg;
// Next State Logic
always @(posedge SCL ,posedge reset) begin
    if (reset == 1) begin
        r_reg <= 0;    // INTITAL VALUE
    end
    if (SCL == 1) begin
        r_reg <= {r_reg[N-2:0],SDA};
    end
end
// Output Assignment
assign PO = (tick == 1)? r_reg:8'bxxxxxxxx ;
endmodule
