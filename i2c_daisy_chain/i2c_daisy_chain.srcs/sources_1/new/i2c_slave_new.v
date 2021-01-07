`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2021 12:52:11 AM
// Design Name: 
// Module Name: i2c_slave_new
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


module i2c_slave_new
#(slave_address = 7'b1010100)
(
inout SDA,
input SCL,
input resetn, // Active Low reset
input [7:0] Addr_external,
output [7:0] Data_external_out,
input clk_external

);

// States
localparam IDLE = 3'b000;
localparam INIT = 3'b001;
localparam WRITE_1 = 3'b010;
localparam WRITE_2 = 3'b011;
localparam ACK = 3'b100;
localparam READ = 3'b101;

reg ack_received;
reg [3:0] counter_reg;
wire [3:0] counter_next;
reg [2:0] c_state;
reg [2:0] n_state;
reg [6:0] address_reg_next;
reg [6:0] address_reg_current;
reg send_ready;
reg send_value;
reg [7:0] data_out;    // Data being sent to the RB
reg [1:0] control_first_block;

wire [1:0] control_last_block; 
wire  [7:0] data_in;
wire [7:0] address;
wire tick;
reg [7:0] data; // Contains the last 8 bits of data sent over i2c
reg opcode_ff;
reg [7:0] data_reg_in;  // Data reg that stores the data coming from the RB


registers DUT4(.clk_external(clk_external),.Data_external_out(Data_external_out),.Addr_external(Addr_external),.resetn(resetn),
               .data_in(data_out),.data_out(data_in),.control_in(control_first_block),.control_out(control_last_block),.Addre(address),.clk(tick));


// Initialization block + Counter
wire interrupt;
always @(posedge SCL or posedge interrupt) begin
     if (!resetn | stop) begin
        counter_reg <= 0;
        c_state <= IDLE;
     end
     else if (start) begin
        c_state <= INIT;
        counter_reg <= 0;
     end else if (SCL) begin
        counter_reg <= counter_next;
        
        if(n_state == ACK & counter_next == 8)
            c_state <= n_state; 
        else if (counter_next == 9)
            c_state <= n_state;
     end
end

assign counter_next = (counter_reg == 9) ?1:1+counter_reg;
assign tick = (counter_reg == 8) ? 1:0;
assign interrupt = !resetn | start | stop;


always @(counter_reg) begin
    if (counter_reg != 9)
        data[8 - counter_reg] = SDA;
    else
        data = 0;
end
// Start Stop Detectors
reg start_reg,stop_reg;
wire start,stop;
always @(negedge SDA or negedge SCL ) begin // START CONDITION
    if (SCL == 1)
        start_reg <= 1;
    else
        start_reg <= 0; 
end
always @(posedge SDA or negedge SCL ) begin // STOP CONDITION
    if (SCL == 1)
        stop_reg <= 1;
    else
        stop_reg <= 0; 
end

assign start = (start_reg & resetn & !send_ready ) ? 1 : 0;
assign stop  = (stop_reg & resetn & !send_ready )  ? 1 : 0;    


always @(negedge SCL) begin
if (counter_reg != 8) 
    send_ready <= 0;
case(c_state)

IDLE: begin

end

INIT: begin

end

WRITE_1: begin

end
WRITE_2: begin

end

READ: begin
    if (counter_reg == 9) begin
        data_reg_in <= data_in;   
        send_ready <= 1;
        send_value <= data_in[7];
     end
     else if (counter_reg != 8) begin
        send_ready <= 1;
        send_value <= data_reg_in[7 - counter_reg];
     end
end
ACK: begin
    if (prev_state == INIT & counter_reg == 8) begin
        if (slave_address == data[6:0]) begin       
            send_ready <= 1;
            send_value <= 0;
        end
        else begin
            send_ready <= 1;
            send_value <= 1;
        end
        if (data[7] == read) begin
            data_reg_in = data_in; 
        end 
    end
    else if(prev_state == WRITE_1 & counter_reg == 8) begin
        if (control_last_block[0] == 1) begin
            send_ready <= 1;
            send_value <= 0;
        end
        else begin
            send_ready <= 1;
            send_value <= 1;
        end 

    end
    else if(prev_state == WRITE_2 & counter_reg == 8) begin
        if (control_last_block[0] == 1) begin
            send_ready <= 1;
            send_value <= 0;
        end
        else begin
            send_ready <= 1;
            send_value <= 1;
        end 
    end
/*
    else if (prev_state == READ & counter_reg == 8) begin
        data_reg_in <= data_in;
        send_ready <= 0;
    end
*/
end
endcase
end
always @(posedge SCL) begin // Receive Acknowledge # REVISIT
    if(c_state == ACK) begin  
        if(prev_state == READ & counter_reg == 7) begin // counter_reg is taken 7 as it will be updated at the same moment hence previous clock edged value
            ack_received <= !SDA;
        end
    end
    else
        ack_received <= 0;
end
// Control Registers for ACK state
reg [2:0] prev_state;

//parameters
localparam read = 1'b1;  
localparam write = 1'b0;
localparam alternate = 1'b1;
localparam burst = 1'b0;

always @* begin
    // Default Values
    n_state = c_state;
    data_out = 8'b00000000;
    control_first_block = 2'b00;
    if (!resetn | stop) begin
        address_reg_current = 8'h0A; // Change this default value
        address_reg_next = 8'h0A;
    end
    case(c_state)    
    IDLE: begin

    end    
    INIT: begin    
        if(counter_reg == 7) begin    
            prev_state = INIT;
            n_state = ACK;
        end    
    end    
    WRITE_1: begin
        if(counter_reg == 7) begin
            prev_state = WRITE_1;
            n_state = ACK;
            opcode_ff = data[7]; // burst or alternate   # REVISIT ... how do i assign default value to this?
         end
    end
    WRITE_2: begin
       if(counter_reg == 7) begin
            prev_state = WRITE_2;
            n_state = ACK;
        end
    end    
    READ: begin
       if(counter_reg == 7) begin
            prev_state = READ;
            n_state = ACK;
       end    
    end
    ACK: begin
        if(prev_state == INIT) begin        
            if(tick) begin
                if(data[7] == write) begin
                    n_state = WRITE_1;
                end
                else if (data[7] == read) begin
                    control_first_block = {read,1'b0};
                    // No need to assign any address - becoz the stored address will be sent
                    n_state = READ;
                end
            end
        end
        else if(prev_state == WRITE_1) begin
            if(tick) begin
                control_first_block = {write,1'b0};
                address_reg_current = data[6:0];
                address_reg_next = data[6:0];
                n_state = WRITE_2;
            end
        end
        else if(prev_state == WRITE_2) begin
            if (tick) begin
                control_first_block = {write,1'b0};
                address_reg_current = address_reg_next;
                data_out = data[7:0];
                if(opcode_ff == burst) begin
                    n_state = WRITE_2;
                    address_reg_next = address_reg_current + 1;
                end                
                else if(opcode_ff == alternate) begin
                    n_state = WRITE_1;
                    address_reg_next = address_reg_current; // Assign a garbage value
                end                
            end
        end
        else if(prev_state == READ) begin
            if(tick) begin
                control_first_block = {read,1'b0};
                address_reg_current = address_reg_next + 1;
                address_reg_next = address_reg_current;
                n_state = READ;
            end
        end
    end
    endcase    
end

assign SDA = (send_ready) ? send_value:1'bz;       // #RECONFIRM    What to send when i dont want to control the line? - Z
assign address = address_reg_current;      // Garbage Value

endmodule
