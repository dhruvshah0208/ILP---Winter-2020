`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/22/2020 04:33:58 PM
// Design Name: 
// Module Name: posedge_counter_tb
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


module posedge_counter_tb;

reg SCL, reset;
wire tick;
wire [3:0] r_reg_wire,n_reg_wire;
localparam t_high = 10;
localparam t_low = 10;
localparam t_wait_start_stop = t_high/10;   
localparam t_wait_send = t_high/10;

posedge_counter DUT(SCL,reset,tick,r_reg_wire,n_reg_wire);  // INSTANTIATE THE DESIGN UNDER TEST
    initial begin
    SCL = 0;
    forever begin
        #t_low SCL = 1;
        #t_high SCL = 0;
    end
end
initial begin 
 reset= 0;
 #1;   reset = 1;
 #1;   reset = 0;    
end 
endmodule
