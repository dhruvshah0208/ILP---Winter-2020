`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/04/2021 12:18:34 AM
// Design Name: 
// Module Name: start_stop_tb
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


module start_stop_tb();
reg SCL;
wire SDA;
reg SDA_reg;
reg resetn;
wire start,stop;
localparam t_high = 10;
localparam t_low = 10;
localparam t_wait_start_stop = t_high/10;   
localparam t_wait_send = t_high/10;

    task I2C_start; begin
    wait(SCL == 0) SDA_reg = 1;
    wait(SCL == 1) #t_wait_start_stop SDA_reg = 0;
    wait(SCL == 0);
end    
endtask

task I2C_stop; begin
    wait(SCL == 0) SDA_reg = 0;
    wait(SCL == 1) #t_wait_start_stop SDA_reg = 1;
end    
endtask
    initial begin
    SCL = 0;
    forever begin
        #t_low SCL = 1;
        #t_high SCL = 0;
    end
end
start_stop_detectors DUT(SDA,SCL,resetn,start,stop);
    initial begin
        resetn = 1;
        #t_low resetn = 0;
        #t_high resetn = 1;
        I2C_start();
    end

    assign SDA = SDA_reg;
endmodule
