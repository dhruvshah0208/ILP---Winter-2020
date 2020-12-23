`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/23/2020 01:19:00 PM
// Design Name: 
// Module Name: parallel_input_serial_output
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


module parallel_input_serial_output
#(parameter N = 8)
(
input [N -1:0] data_in,
input enable,
input SCL,
input tick,
output send_ready,// Data ACtive
output serial_output
);
// We have to wait for one clock cycle after the negedge of tick and then start sending the serial outputs. (Better to send between 2 negedges of SCL)
reg waiting_time = 0;
reg output_ready = 0;
reg [N-1:0] data_reg;
reg output_reg;
always @(negedge tick) begin
    waiting_time <= 1;
    data_reg <= data_in;         // Store everything in a local register. Is the timing ok? #REVISIT
end
always @(posedge tick) begin
    waiting_time <= 0;
    output_ready <= 0;
end

always @(negedge SCL) begin
    if (waiting_time == 1) begin
        output_ready <= 1;
        output_reg <= data_reg[N-1];
        data_reg <= {data_reg[N-2:0],1'bx};    
    end
end
// Assign outputs
assign send_ready = enable & output_ready;
assign serial_output = (output_ready == 1) ? output_reg:'bx;
endmodule






