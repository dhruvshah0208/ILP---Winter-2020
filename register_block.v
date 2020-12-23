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
    output reg [1:0] Control_out   
    
    );
    reg [7:0] q; // This is the Storage element of the Register Block
    wire C_out; // This contains the output of Comparator
    
    parameter Read = 1'b1,Write = 1'b0; // CHANGE THE ADDRESS OF REGISTER BLOCK

    assign C_out = (Address == Addr) ? 1'b1:1'b0;
            
    always @(clk) begin
        if (clk == 1'b1) begin        
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
                    D_out = 8'bz;
                end
                else if (C_out == 1'b0) begin        // If Address Does not Match
                    D_out = D_in;
                    Control_out = Control_in;       // Pass Everything as it is
                end
            end
        end
        else begin
            D_out = 8'bz;
            Control_out = 2'bz;
        end
    end
endmodule
























