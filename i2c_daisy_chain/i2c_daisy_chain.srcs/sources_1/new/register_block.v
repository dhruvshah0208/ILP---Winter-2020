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
    output [7:0] data_out,
    output [1:0] Control_out,
    input resetn,               // Reset Signal - active low
    // External Interface Signals
    input [7:0] Addr_external,
    input clk_external,   
    output reg [7:0] Data_external_out,
    output reg valid,
    output C_out
    );
    reg [7:0] q; // This is the Storage element of the Register Block
    reg [7:0] D_out; // This contains the output of Comparator
    reg [1:0] control_out;
    localparam Read = 1'b0,Write = 1'b1; // CHANGE THE ADDRESS OF REGISTER BLOCK
    
    always @(negedge resetn) begin
        if (!resetn)
            q <= 8'b00011000;
    end
    
    always @(*) begin
        if (clk) begin
           if (Control_in[1] == Read) begin
                if (C_out) begin             // If Address Match
                    D_out <= q;
                    control_out <= {Write,1'b1};     // Write,ACK
                    
                end
                else begin        // If Address Does not Match
                    D_out <= D_in;
                    control_out <= Control_in;       // Pass Everything as it is
                end
            end 
            else if (Control_in[1] == Write) begin
                if (C_out) begin             // Address Match
                    q <= D_in;
                    control_out <= {Control_in[1],1'b1};     // Write,ACK    
                    //D_out = 8'bz;
                end
                else begin        // If Address Does not Match
                    D_out <= D_in;
                    control_out <= Control_in;       // Pass Everything as it is
                end
            end
        end
        else begin // when clk is 0
            control_out <= {Read,1'b0};  // This will not allow the register blocks to be affected by previous transactions
        end
    end
    always @(*) begin
    if (clk_external) begin    
        if(Addr_external == Address) begin
          Data_external_out <= q;
          valid <= 1;   
        end else
          valid <= 0; // This indicates Address is not matched
    end
    end
    
assign C_out = (Address == Addr) ? 1:0;

assign data_out = D_out;     
assign Control_out = control_out;   

endmodule
























