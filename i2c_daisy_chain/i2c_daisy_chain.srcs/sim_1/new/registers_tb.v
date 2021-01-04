`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/31/2020 06:37:33 PM
// Design Name: 
// Module Name: registers_tb
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


module registers_tb;
reg [7:0] data_in;
reg [1:0] control_in; // {R/W,ACK}
reg clk;
reg [7:0] Addre;
wire [7:0] data_out;
wire [1:0] control_out;
reg resetn;               // Reset Signal - active low
// External Interface Signals
reg [7:0] Addr_external;
wire [7:0] Data_external_out;
reg clk_external;   

registers DUT (data_in,
               control_in,
               clk,
               Addre,
               data_out,
               control_out,
               resetn,
               Addr_external,
               Data_external_out,
               clk_external
               );


initial begin
resetn = 1;clk = 0;clk_external = 0;
#1 resetn = 0;
#1 resetn = 1;
// Read reset data
#1;
clk = 1;
Addre = 8'h1A;
control_in = 2'b00;
#1;
clk = 0;
/*
// Case 1: Write with incorrect Address
#1;
clk = 1;
Addre = 8'b00000000;
data_in = 8'b11111100;
control_in = 2'b10;
#1;
clk = 0;

*/
// Case 2: Write with correct Address
#1;
clk = 1;
Addre = 8'h0A;
data_in = 8'b11101100;
control_in = 2'b10;
#1;
clk = 0;
/*
// Case 3: Read with incorrect Address
#1;
clk = 1;
Addre = 8'b00000000;
control_in = 2'b00;
#1;
clk = 0;
*/
// Case 4: Read with correct Address
#1;
clk_external = 1;
Addr_external = 8'h0A;

#1;
clk_external = 0;

#1;
clk_external = 1;
Addr_external = 8'h1A;
#1;
clk_external = 0;

end

endmodule
