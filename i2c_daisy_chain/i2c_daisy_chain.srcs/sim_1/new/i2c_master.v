`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2021 03:51:33 PM
// Design Name: 
// Module Name: i2c_master
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


module i2c_master();
reg SCL;
wire SDA;
reg SDA_reg;
reg resetn;
reg [7:0] Addr_external;
wire [7:0] Data_external_out;
reg clk_external;
// Change these values accordingly later
localparam t_high = 10;
localparam t_low = 10;
localparam t_wait_start_stop = t_high/10;   
localparam t_wait_send = t_high/10;
integer i;   
// CLK generation
    initial begin
        SCL = 0;
        forever begin
            #t_low SCL = 1;
            #t_high SCL = 0;
        end
    end
// Tasks    
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
 
    task I2C_send;
        input [7:0] data_send;
        begin
        for(i = 7;i >=0;i=i-1) begin
            wait(SCL == 0) #t_wait_send SDA_reg = data_send[i];
            @(negedge SCL);
        end
        end
    endtask

    task I2C_receive;
    output [7:0] data_receive;
        begin
        SDA_reg = 8'bzzzzzzzz;
        for(i = 7;i >=0;i=i-1) begin
            @(negedge SCL) data_receive[i] = SDA;
        end
        end
    endtask
    
    task send_ACK;
        begin
            wait(SCL == 0) #t_wait_send SDA_reg = 0;
            @(negedge SCL);
        end
    endtask

    task receive_ACK;
    output received_ACK;
        @(negedge SCL) received_ACK = !SDA;
    endtask

// Slave instantiation
reg ack;
I2C_slave slave (SDA,SCL,resetn,Addr_external,Data_external_out,clk_external);
// Sequential Instructions
    initial begin
    ack = 0;resetn = 1;
    #t_low resetn = 0;
    #t_high resetn = 1;
    I2C_start();
    I2C_send(8'b11100010); // W + Slave Address
    receive_ACK(ack);
    I2C_send(8'b10000010);// Alternate + Reg Address
    receive_ACK(ack);
    I2C_send(8'b00000000);// Data
    receive_ACK(ack);
    I2C_send(8'b10000100);// Alternate + Reg Address
    receive_ACK(ack);
    I2C_stop();                    
    end

//assign statements
assign SDA = SDA_reg;

endmodule
