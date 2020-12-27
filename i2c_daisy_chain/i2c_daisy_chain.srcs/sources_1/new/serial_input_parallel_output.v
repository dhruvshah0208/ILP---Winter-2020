`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Dhruv Shah
// 
// Create Date: 12/22/2020 01:23:28 PM
// Aim:- Parallelize Serial data
//       Outputs Parallel Data that is stored in its shift register whenever tick == 1
//       This Module has to be reset in the beginning in order to get the shift register initialized
//////////////////////////////////////////////////////////////////////////////////


module serial_input_parallel_output
#(parameter N=8)
(
input SDA,       // MSB is transmitted first in i2C
input SCL,
input reset,     // Active High Reset
input tick,
output wire [N-1:0] PO    
);
reg [N-1:0] r_reg;
always @(posedge SCL or posedge reset) begin
    if (reset == 1) begin
        r_reg <= 0;    // INTITAL VALUE
    end
    if (SCL == 1) begin
        r_reg <= {r_reg[N-2:0],SDA};
    end
end
// Output Assignment
assign PO = (tick == 1)? r_reg:8'h00 ; // Garbage Value
endmodule
