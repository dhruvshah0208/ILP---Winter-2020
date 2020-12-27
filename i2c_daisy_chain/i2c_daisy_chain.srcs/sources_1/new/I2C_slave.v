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
#(parameter Address = 7'b1100010)      // Change this later # SLAVE ADDRESS
(
inout SDA,
input SCL,
output [7:0] data_out,
output [1:0] control_first_block,
input [1:0] control_last_block, // #REVISIT - RB will send 1 if they have acknowledged
input  [7:0] data_in,
output [7:0] address,
output clk,
input resetn // Active Low reset
);
wire tick;
reg internal_reset; // Active High Reset
wire [7:0] PO; // Parallel Output
reg enable_piso = 0;
reg [2:0] c_state;    // STATES - INIT,WRITE_1,WRITE_2,READ,IDLE
reg [2:0] n_state;    // STATES - INIT,WRITE_1,WRITE_2,READ,IDLE
reg opcode;
reg send,send_ready;
reg [7:0] data_reg;
reg [1:0] control_reg;
reg i2c_slave_ack ,i2c_reg_ack;
reg [6:0] address_reg_next;
reg [6:0] address_reg_current;
reg c_start,n_start,c_stop,n_stop;
wire data_active,piso_output;
// parameters
parameter read = 1'b1;  
parameter write = 1'b0;
parameter alternate = 1'b1;
parameter burst = 1'b0;

posedge_counter DUT(.SCL(SCL),.tick(tick),.reset(internal_reset));  
serial_input_parallel_output DUT1(.SCL(SCL),.tick(tick),.reset(internal_reset),.PO(PO),.SDA(SDA));  
parallel_input_serial_output DUT2(.data_in(data_in),.enable(enable_piso),.SCL(SCL),.tick(tick),.data_active(data_active),.serial_output(piso_output));

// Define the States 
parameter INIT = 3'b000;
parameter READ = 3'b001;
parameter WRITE_1 = 3'b011;   // Addr
parameter WRITE_2 = 3'b100;   // Data
parameter IDLE= 3'b101;   // Data

always @(posedge SDA) // STOP condition
    if (SCL == 1'b1) 
        c_stop <= 1;
    else 
        c_stop <= n_stop;
always @(negedge SDA)       // START CONDITION
    if (SCL == 1'b1) 
        c_start <= 1;
    else begin
        c_start <= n_start;
    end

// Initialize Values
always @(posedge SCL or negedge resetn) begin  // State transitions have to occur at posedge of tick
    if (!resetn) begin // Reset and Initialize all values of reg here
        c_state <= IDLE;
        address_reg_current <= 8'h00; // Random Initial Value - CHange Later
    end else begin
        c_state <= n_state;
        address_reg_current <= address_reg_next;
        
    end
end 
   
// Tasks of each state
always @(posedge SCL) begin
    
    case(c_state) 
        INIT: begin
            enable_piso <= 0;
            if (tick) begin
                if (PO[7:1] == Address) begin   // MSB is sent first through i2c
                    // SEND ACK  
                    i2c_slave_ack <= 1;
                end  
                if(PO[0] == read) begin
                    control_reg <= {read,1'b0};
                    enable_piso <= 1;
                end
            end else begin
                if (i2c_slave_ack) begin 
                    send_ready <= 1;
                    send <= 1'b1;
                    i2c_slave_ack <= 0;
                end
            end
        end
        WRITE_1:begin
    
            enable_piso <= 0;
            if (tick) begin 
                address_reg_next <= PO[6:0];
                opcode <= PO[7];
                i2c_reg_ack <= 1;
                control_reg <= {write,1'b0};
            end else begin
                if (i2c_reg_ack) begin 
                    send <= ~control_last_block[0];  // #REVISIT - Check the sign
                    send_ready <= 1;    
                    i2c_reg_ack <= 0;
                end
            end         
         end
         WRITE_2:begin
           enable_piso <= 0;
           if (tick) begin
                i2c_reg_ack <= 1;
                control_reg <= {write,1'b0};
                data_reg <= PO[7:0];   
            end else begin
                    if (i2c_reg_ack) begin 
                        send <= ~control_last_block[0];  // #REVISIT - Check the sign
                        send_ready <= 1;    
                        i2c_reg_ack <= 0;
                    end
                end 
          end
          READ:begin
            if(tick) begin
                control_reg <= {read,1'b1}; // Garbage Value in ACk
                enable_piso <= 1;       
            end
            send_ready <= data_active;
            send <= piso_output;    
          end                  
    endcase
end

always @(*) begin  // NEXT STATE COMBO LOGIC
    case (c_state)
        IDLE:begin
            if(c_start) begin
                n_state = INIT;
                n_start = 0;
                internal_reset = 1;
             end
             else
                internal_reset = 0;
        end
        INIT: begin
            if (PO[0] == read & tick == 1) begin
                n_state = READ;
            end
            else if (PO[0] == write & tick == 1) begin
                n_state = WRITE_1;
            end
            if (c_start) begin
                n_state = INIT;
                n_start = 0;
                internal_reset = 1;
            end
            else 
                internal_reset = 0;
            if (c_stop) begin
                n_state = IDLE;
                n_stop = 0;    
                internal_reset = 1;
            end
            else 
                internal_reset = 0;                
        end
        WRITE_1:begin
            if (tick == 1) 
                n_state = WRITE_2;
            if (c_start) begin
                n_state = INIT;
                n_start = 0;
                internal_reset = 1;
            end
            else 
                internal_reset = 0;
            if (c_stop) begin
                n_state = IDLE;
                n_stop = 0;    
                internal_reset = 1;
            end
            else 
                internal_reset = 0;                
        end
        WRITE_2: begin
            if (opcode == alternate & tick == 1) n_state = WRITE_1;
            else if (opcode == burst & tick == 1) begin
                n_state = WRITE_2;
                address_reg_next = address_reg_current + 1; // First register will be skipped
            end 
            
            if (c_start) begin
                n_state = INIT;
                n_start = 0;
                internal_reset = 1;
            end
            else 
                internal_reset = 0;
            if (c_stop) begin
                n_state = IDLE;
                n_stop = 0;    
                internal_reset = 1;
            end
            else 
                internal_reset = 0;                
        end
        READ: begin  // #REVISIT
            if (tick) begin        
                n_state = READ;
                address_reg_next = address_reg_current + 1;
            end
            if (c_start) begin
                n_state = INIT;
                n_start = 0;
                internal_reset = 1;
            end
            else 
                internal_reset = 0;
            if (c_stop) begin
                n_state = IDLE;
                n_stop = 0;    
                internal_reset = 1;
            end
            else 
                internal_reset = 0;                
       end
endcase
end

assign SDA = (send_ready == 1) ? send:SDA;       // #RECONFIRM    What to send when i dont want to control the line?
assign clk = tick;
assign address = address_reg_current;      // Garbage Value
assign control_first_block = (tick == 1) ? control_reg:8'h00;  // Garbage Value 
assign data_out = (tick == 1) ? data_reg:8'h00;                // Garbage Value 

endmodule





