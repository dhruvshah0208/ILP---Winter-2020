`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2020 01:30:32 AM
// Design Name: 
// Module Name: start_stop_detectors
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


module start_stop_detectors
(
input SDA,
input SCL,
input resetn,
output start,
output stop
);

reg start_reg,stop_reg;

always @(negedge SDA or negedge SCL ) begin // START CONDITION
    if (SCL == 1)
        start_reg <= 1;
    else
        start_reg <= 0; 
end
always @(posedge SDA or negedge SCL ) begin // STOP CONDITION
    if (SCL == 1)
        stop_reg <= 1;
    else
        stop_reg <= 0; 
end

assign start = (start_reg & resetn) ? SCL : 0;
assign stop  = (stop_reg & resetn)  ? SCL : 0;    

endmodule
