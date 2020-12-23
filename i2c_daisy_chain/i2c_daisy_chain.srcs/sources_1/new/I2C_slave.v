`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dhruv Shah
// 
// Create Date: 12/22/2020 09:25:02 PM
// Design Name: 
// Module Name: I2C_slave
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


module I2C_slave
#(parameter Address = 7'b1100010)      // Change this later
(
inout SDA,
input SCL,
output [7:0] data_out,
output [1:0] control_signals,
input [1:0] control_last_block, // #REVISIT - RB will send 1 if they have acknowledged
input  [7:0] data_in,
output [7:0] address,
output clk
);
wire tick;
reg reset;
wire [7:0] PO; // Parallel Output
reg enable_piso = 0;
reg [2:0] state = IDLE;    // STATES - INIT,WRITE_1,WRITE_2,READ,IDLE
reg opcode;
reg [6:0] address_reg;
reg send,send_ready;
reg [7:0] data_reg;
reg [1:0] control_reg;
reg i2c_slave_ack = 0,i2c_reg_ack = 0;
reg [6:0] address_next;
// parameters
parameter read = 1'b1;  
parameter write = 1'b0;
parameter alternate = 1'b1;
parameter burst = 1'b0;

posedge_counter DUT(.SCL(SCL),.tick(tick),.reset(reset));  
serial_input_parallel_output DUT1(.SCL(SCL),.tick(tick),.reset(reset),.PO(PO),.SDA(SDA));  
parallel_input_serial_output DUT2(.data_in(data_in),.enable(enable_piso),.SCL(SCL),.tick(tick),.send_ready(send_ready),.serial_output(send));

// Define the States 
parameter INIT = 3'b000;
parameter READ = 3'b001;
parameter WRITE_1 = 3'b010;   // Addr
parameter WRITE_2 = 3'b011;   // Data
parameter IDLE= 3'b100;   // Data



// CHECK FOR START AND STOP CONDITIONS
always @(posedge SDA) begin  // STOP condition
    if (SCL == 1'b1) begin    
        state <= IDLE;  
        reset <= 1;
        enable_piso <= 0;
    end
end 
always @(negedge SDA) begin      // START CONDITION
    if (SCL == 1'b1) begin
        state <= INIT;
        reset <= 1;
        enable_piso <= 0;
    end
end

always @(posedge tick) begin
    address_reg = address_next;   // This is the only blocking assignment in the block... is it fine? #REVISIT
    case (state) 
        INIT: begin               // Resetting Tasks have been done by the START/STOP checkers
            if (PO[7:1] == Address) begin   // MSB is sent first through i2c
                // SEND ACK  
                i2c_slave_ack <= 1;
            end    
            // Next State Logic
            if (PO[0] == read) state <= READ;
            else state <= WRITE_1;
        end
        
        WRITE_1: begin
            address_reg <= PO[7:1];
            address_next<= PO[7:1];
            opcode <= PO[0];
            control_reg <= {write,1'b0};
            i2c_reg_ack <= 1;
            // Next State Logic
            state <= WRITE_2;    
        end
        
        WRITE_2: begin
            // Send Address as well as Data this time {Similair to WRITE_1} , ACK - 0, Write Mode
            // Make arrangements to send appropriate NACK  #REVISIT
            control_reg <= {write,1'b0};
            i2c_reg_ack <= 1;
            data_reg <= PO[7:0];
            // Next State Logic
            if (opcode == alternate) state <= WRITE_1;
            else if (opcode == burst) begin
                state <= WRITE_2;
                address_next <= address_reg + 1; // First register will be skipped
            end
        end
        
        READ: begin
            // Send a read command to registers, increment address by one, stay in this state till start/stop  
            // ENTER CODE HERE - read command to registers on the address stored.Send this at posedge,collect at negedge and send on i2c at next posedge #REVISIT
            control_reg <= {read,1'bx};
            enable_piso <= 1;
            address_next <= address_reg + 1;   // #REVISIT - Problem here... we will skip the first register 
        end 
    
    endcase
end
always @(negedge SCL) begin
    //#REVISIT
    reset <= 0;             // Reset can only be turned on when SCL is high 
    if (tick == 1) begin
        if (i2c_slave_ack == 1) begin
            send <= 0;
            send_ready <= 1;
        end    
        if (i2c_reg_ack == 1) begin
            send <= ~control_last_block[0];
            send_ready <= 1;    
        end
    end 
    else begin
        send_ready <= 0;
        i2c_reg_ack <= 0;
        i2c_slave_ack <= 0;
    end 
end


assign SDA = (send_ready == 1) ? send:SDA;       // #RECONFIRM
assign clk = tick;
assign address = (tick == 1) ? address_reg:'bx;
assign control_signals = (tick == 1) ? control_reg:'bx;
assign data_out = (tick == 1) ? data_reg:'bx;

endmodule





