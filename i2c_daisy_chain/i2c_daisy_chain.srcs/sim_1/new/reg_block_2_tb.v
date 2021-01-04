`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2021 03:00:52 PM
// Design Name: 
// Module Name: reg_block_2_tb
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


module reg_block_2_tb;
reg [7:0] data_in;
reg [1:0] control_in; // {R/W,ACK}
reg clk;
reg [7:0] Addre;
wire [7:0] data_out;
wire [1:0] control_out;
reg resetn;               // Reset Signal - active low

//Interconnect Signals
wire cout1;wire cout2;wire cout3;
wire [7:0] q1;wire [7:0] q2;wire [7:0] q3;
wire [7:0] data_connect1;
wire [7:0] data_connect2;
wire [1:0] control_connect1;
wire [1:0] control_connect2;

register_block #(.Address(8'h0A)) DUT1(
                                      .C_out(cout1),
                                      .data_stored(q1),
                                      .resetn(resetn),
                                      .D_in(data_in),
                                      .Control_in(control_in),
                                      .Addr(Addre),
                                      .clk(clk),
                                      .data_out(data_connect1),
                                      .Control_out(control_connect1));
register_block #(.Address(8'h1A)) DUT2(
                                        .C_out(cout2),
                                        .data_stored(q2),
                                        .resetn(resetn),
                                        .D_in(data_connect1),
                                        .Control_in(control_connect1),
                                        .Addr(Addre),
                                        .clk(clk),
                                        .data_out(data_connect2),
                                        .Control_out(control_connect2));
register_block #(.Address(8'h2A)) DUT3(
                                            .C_out(cout3),
                                            .data_stored(q3),
                                            .resetn(resetn),
                                            .D_in(data_connect2),
                                            .Control_in(control_connect2),
                                            .Addr(Addre),
                                            .clk(clk),
                                            .data_out(data_out),
                                            .Control_out(control_out));


initial begin
resetn = 1;clk = 0;
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
clk = 1;
Addre = 8'h0A;
control_in = 2'b00;
#1;
clk = 0;

#1;
clk = 1;
Addre = 8'h1A;
control_in = 2'b00;
#1;
clk = 0;



end


endmodule
