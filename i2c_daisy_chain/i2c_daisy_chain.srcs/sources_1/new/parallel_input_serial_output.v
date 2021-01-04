`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Dhruv Shah
// 
// Create Date: 12/23/2020 01:19:00 PM
// Module Name: parallel_input_serial_output
// Aim :-  
// Once enabled this module will wait a clock cycle after negedge of tick and then serialize the parallel D_in 
// 
// 
//////////////////////////////////////////////////////////////////////////////////

module parallel_input_serial_output
#(parameter N = 8)
(
input [N -1:0] data_in,
input enable,
input SCL,
input tick,
output data_active,// Data ACtive
output serial_output
);

reg activate;
reg [N-1:0] data_reg;
reg output_reg;
reg output_ready;
reg c_state,n_state;

localparam Wait = 1'b1;
localparam Begin = 1'b0;

always @(posedge SCL) begin
    if (tick & enable) begin
        output_ready <= 0;
        activate <= 0;
    end
    else if (enable & ~activate) begin
        activate <= 1;
        data_reg <= data_in;
        output_ready <= 0;
     end 
            
    if (activate) begin    
        output_ready <= 1;
        output_reg <= data_reg[N-1]; // Send the MSB first
        data_reg <= {data_reg[N-2:0],1'b0}; // Garbage Value      
    end
end
//Assign outputs
assign serial_output = output_reg;
assign data_active = enable & output_ready;

endmodule






