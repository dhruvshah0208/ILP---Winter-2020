`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/22/2020 05:08:20 PM
// Design Name: 
// Module Name: sipo_tb
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
// input SDA,       // MSB is transmitted first in i2C

//////////////////////////////////////////////////////////////////////////////////


module sipo_tb;
parameter N = 8;
reg SDA;       // MSB is transmitted first in i2C
reg SCL;
reg reset;
reg tick;
wire [N-1:0] PO;   

serial_input_parallel_output DUT1(.SCL(SCL),.tick(tick),.reset(reset),.PO(PO),.SDA(SDA));  // INSTANTIATE THE DESIGN UNDER TEST
initial begin
  SCL=0;
     forever #1 SCL = ~SCL;  
end 
initial begin
  tick=0;
  #2;
  tick = 1;
  forever #18 tick = 1;
    
end 
initial begin
    #1;
    forever #2 tick = 0;  
end

initial begin 
reset= 0;
#1;
#2;   reset = 1;
#2;   SDA  = 1;  
#2;   SDA  = 0;  
#2;   SDA  = 1;  
#2;   SDA  = 1;  
#2;   SDA  = 0;  
#2;   SDA  = 0;
#2;   SDA  = 1;  
#2;   SDA  = 0;tick = 1;  
#2;   SDA  = 1;tick = 0;  
#2;   SDA  = 1;  
#2;   SDA  = 0;  
#2;   SDA  = 0;    
end 
endmodule
