`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dhruv Shah
// 
// Create Date: 12/21/2020 11:13:04 AM
// Design Name: 
// Module Name: register_block
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// This is the building block for the register bank
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// The outputs are reg type and are inducing undesirable storage elements. HOW DO WE GET RID OF THATH
//////////////////////////////////////////////////////////////////////////////////


module register_block
    #(parameter Address = 8'b00000000)
    (
    input [7:0] D_in,
    input [1:0] Control_in, // {R/W,ACK}
    input [7:0] Addr,
    input clk,
    output reg [7:0] D_out,
    output reg [1:0] Control_out,
    input resetn,               // Reset Signal - active low
    // External Interface Signals
    input [7:0] Addr_external,
    input clk_external,   
    output reg [7:0] Data_external_out,
    output reg valid
    );
    reg [7:0] q; // This is the Storage element of the Register Block
    wire C_out; // This contains the output of Comparator
    
    parameter Read = 1'b1,Write = 1'b0; // CHANGE THE ADDRESS OF REGISTER BLOCK
    
    always @(negedge resetn) begin
        if (!resetn)
            q <= 8'b00000000;
    end
    
            
    always @(*) begin
        if (clk) begin        
            if (Control_in[1] == Read) begin
                if (C_out == 1'b1) begin             // If Address Match
                    D_out = q;
                    Control_out = {Write,1'b1};     // Write,ACK
                end
                else if (C_out == 1'b0) begin        // If Address Does not Match
                    D_out = D_in;
                    Control_out = Control_in;       // Pass Everything as it is
                end
            end 
            else if (Control_in[1] == Write) begin
                if (C_out == 1'b1) begin             // Address Match
                    q = D_in;
                    Control_out = {Control_in[1],1'b1};     // Write,ACK    
                    //D_out = 8'bz;
                end
                else if (C_out == 1'b0) begin        // If Address Does not Match
                    D_out = D_in;
                    Control_out = Control_in;       // Pass Everything as it is
                end
            end
            
        end
        
        if (clk_external) begin
            if(Addr_external == Address) begin
                 Data_external_out = q;
                 valid = 1;   
            end else
                valid = 0; // This indicates Address is not matched
        end
        else 
            valid = 0;
    end
    
assign C_out = (Address == Addr) ? 1'b1:1'b0;
        
endmodule
























