`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/01/2021 10:34:04 PM
// Design Name: 
// Module Name: register_block_tb
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

/* This module will be checking all the 4 cases mentioned in the register_block onenote document
   This will also test the functionality of the external initerface*/
module register_block_tb;
reg [7:0] D_in;
reg [1:0] Control_in; // {R/W,ACK}
reg [7:0] Addr;
reg clk;
wire [7:0] D_out;
wire [1:0] Control_out;
reg resetn;               // Reset Signal - active low
// External Interface Signals
reg [7:0] Addr_external;
reg clk_external;   
wire [7:0] Data_external_out;
wire valid;
// Debugging
wire C_out;
wire [7:0] data_stored;
register_block DUT (D_in,
                    Control_in,
                    Addr,
                    clk,
                    D_out,
                    Control_out,
                    resetn,
                    Addr_external,
                    clk_external,
                    Data_external_out,
                    valid,
                    C_out,
                    data_stored);

initial begin
resetn = 1;clk = 0;clk_external = 0;
#1 resetn = 0;
#1 resetn = 1;

// Case 4: Read with correct Address
#1;
clk = 1;

D_in = 8'b11111100;
Addr = 8'b00000000;
Control_in = 2'b00;
#1;
clk = 0;

// Case 1: Write with incorrect Address
#1;
clk = 1;
Addr = 8'b11110000;
D_in = 8'b11111100;
Control_in = 2'b10;
#1;
clk = 0;
// Case 2: Write with correct Address
#1;
clk = 1;
Addr = 8'b00000000;
D_in = 8'b11100100;
Control_in = 2'b00;
#1;
clk = 0;

// Case 3: Read with incorrect Address
#1;
clk = 1;
D_in = 8'b11111111;
Addr = 8'b01100000;
Control_in = 2'b00;
#1;
clk = 0;


// Case 4: Read with correct Address
#1;
clk = 1;
Addr = 8'b00000000;
D_in = 8'b11111111;
Control_in = 2'b00;
#1;
clk = 0;
// Case 5 Read the currently stored data from external interface
#1;
clk_external = 1;
Addr_external = 8'b01100000;
#1;
clk_external = 0;

// Case 5 Read the currently stored data from external interface
#1;
clk_external = 1;
Addr_external = 8'b00000000;
#1;
clk_external = 0;

end
endmodule
