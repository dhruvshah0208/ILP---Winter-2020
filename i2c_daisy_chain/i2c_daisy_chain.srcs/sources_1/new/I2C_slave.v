`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Dhruv Shah
// Create Date: 12/22/2020 09:25:02 PM
// Module Name: I2C_slave

// IMPORTANT TAGS - Change Later
//////////////////////////////////////////////////////////////////////////////////


module I2C_slave
#(parameter Address = 7'b1100010)      // Change this later # SLAVE ADDRESS
(
inout SDA,
input SCL,
input resetn, // Active Low reset
//External Interface
input [7:0] Addr_external,
output [7:0] Data_external_out,
input clk_external
);

reg send_ready;
wire send_ready_wire;
wire [7:0] data_out;
wire [1:0] control_first_block;
wire [1:0] control_last_block; // #REVISIT - RB will send 1 if they have acknowledged
wire  [7:0] data_in;
wire [7:0] address;
wire tick;
reg internal_reset;wire reset;          // Active High Reset                                 
wire [7:0] PO;                          // Parallel Output
reg enable_piso;
wire enable_piso_wire;                                                          
reg [2:0] c_state;                      // STATES - INIT,WRITE_1,WRITE_2,READ,IDLE
reg [2:0] n_state;                      // STATES - INIT,WRITE_1,WRITE_2,READ,IDLE
reg opcode;
reg send;
reg [7:0] data_reg;
reg [1:0] control_reg;
reg i2c_slave_ack;
reg i2c_reg_ack;
reg [6:0] address_reg_next;
reg [6:0] address_reg_current;
wire data_active,piso_output;
wire start_condition;
wire stop_condition;

reg ack_done;
// parameters
localparam read = 1'b1;  
localparam write = 1'b0;
localparam alternate = 1'b1;
localparam burst = 1'b0;

posedge_counter DUT(.SCL(SCL),.tick(tick),.reset(reset));  
serial_input_parallel_output DUT1(.SCL(SCL),.tick(tick),.reset(reset),.PO(PO),.SDA(SDA));  
parallel_input_serial_output DUT2(.data_in(data_in),.enable(enable_piso_wire),.SCL(SCL),.tick(tick),.data_active(data_active),.serial_output(piso_output));
start_stop_detectors DUT3(.SCL(SCL),.SDA(SDA),.resetn(resetn),.start(start_condition),.stop(stop_condition),.send_ready(send_ready_wire));
registers DUT4(.clk_external(clk_external),.Data_external_out(Data_external_out),.Addr_external(Addr_external),.resetn(resetn),
               .data_in(data_out),.data_out(data_in),.control_in(control_first_block),.control_out(control_last_block),.Addre(address),.clk(tick));

// Define the States 
localparam INIT = 3'b000;
localparam READ = 3'b001;
localparam WRITE_1 = 3'b010;   // Addr
localparam WRITE_2 = 3'b011;   // Data
localparam IDLE= 3'b100;   // Data

// Initialize Values
always @(negedge SCL or negedge resetn) begin  // State transitions have to occur at posedge of tick
    if (!resetn) begin // Reset and Initialize all values of reg here
        c_state <= IDLE;
        address_reg_current <= 8'h00; // Random Initial Value - Change Later
    end else begin
        c_state <= n_state;
        address_reg_current <= address_reg_next;
        
    end
end 
   
// Tasks of each state
always @(posedge SCL) begin 
    if (!resetn) send_ready <= 0;
    case(c_state) 
        IDLE:
            send_ready <= 0;
        INIT: begin
            enable_piso <= 0;
            send_ready <= 0;
        end
        WRITE_1:begin
            
            if (i2c_slave_ack & !tick) begin 
                send_ready <= 1;
                send <= 1'b1;
                ack_done <= 1;
            end
            else if (!i2c_slave_ack)
                ack_done <= 0;
            else if (i2c_reg_ack & !tick) begin 
                 send <= ~control_last_block[0];  // #REVISIT - Check the sign
                 send_ready <= 1;
                 ack_done <= 1;  
            end
            else if (!i2c_reg_ack)
                 ack_done <= 0;
            else
                send_ready <= 0;
                
            enable_piso <= 0;
                
         end
         WRITE_2:begin
           if (i2c_reg_ack & !tick) begin 
                send <= ~control_last_block[0];  // #REVISIT - Check the sign
                send_ready <= 1;   
                ack_done <= 1; 
           end
            else if (!i2c_reg_ack)
                 ack_done <= 0;
           else 
                send_ready <= 0;
           enable_piso <= 0;
          end
          READ:begin
            send_ready <= data_active;
            send <= piso_output;    
          end                  
    endcase
end

always @(*) begin  // NEXT STATE COMBO LOGIC
    if (!resetn) n_state = IDLE;
    
    case (c_state)
    
        IDLE:begin
            if(start_condition) begin
                n_state <= INIT;
                internal_reset <= 1;
             end
             else  
                internal_reset <= 0;             
        end
        INIT: begin
            if (start_condition) begin
            n_state <= INIT;
            internal_reset <= 1;
            end
            else if (stop_condition) begin
                n_state <= IDLE;
                internal_reset <= 1;
            end
            else if (tick) begin
                if (PO[6:0] == Address) begin   // MSB is sent first through i2c - (R/W) bit
                    // SEND ACK  
                    i2c_slave_ack <= 1;
                end  
                if(PO[7] == read) begin
                    control_reg <= {read,1'b0};
                    enable_piso <= 1;
                    n_state <= READ;
                end
                else if (PO[7] == write)
                    n_state <= WRITE_1;
            end 
            else 
                internal_reset <= 0;                
        end
        WRITE_1:begin // state 3
            if (start_condition) begin
                n_state <= INIT;
                internal_reset <= 1;
            end
            else if (stop_condition) begin
                n_state <= IDLE;    
                internal_reset <= 1;
            end
            else if (tick & SCL) begin 
                opcode <= PO[7];
                i2c_reg_ack <= 1;
                control_reg <= {write,1'b0};
                n_state <= WRITE_2;  
                address_reg_next <= PO[6:0];
            end
            else if (i2c_slave_ack & !tick & ack_done) begin 
                i2c_slave_ack <= 0;
            end
            else if (i2c_reg_ack & !tick & ack_done) begin 
                 i2c_reg_ack <= 0;
            end        
            else 
                internal_reset <= 0;                
        end
        WRITE_2: begin // state 4
            if (start_condition) begin
                 n_state <= INIT;
                 internal_reset <= 1;
            end
            else if (stop_condition) begin
                 n_state <= IDLE; 
                 internal_reset <= 1;
            end
            else if (opcode == alternate & tick == 1) n_state <= WRITE_1;
            else if (opcode == burst & tick == 1) begin
                n_state <= WRITE_2;
                address_reg_next <= address_reg_current + 1; // First register will be skipped
            end 
            else if (tick) begin
                 i2c_reg_ack <= 1;
                 control_reg <= {write,1'b0};
                 data_reg <= PO[7:0];   
             end 
             else if (i2c_reg_ack & !tick & ack_done) begin 
                 i2c_reg_ack <= 0;
             end 
             else 
                 internal_reset <= 0;                
        end
        READ: begin  // #REVISIT
            if (start_condition) begin
                n_state <= INIT;
                internal_reset <= 1;
            end
            else if (stop_condition) begin
                n_state <= IDLE; 
                internal_reset <= 1;
            end
            else if (tick) begin        
                n_state <= READ;
                control_reg <= {read,1'b1}; // Garbage Value in ACk
                enable_piso <= 1;       
                address_reg_next <= address_reg_current + 1;
            end
            else 
                internal_reset <= 0;                
       end
endcase
end

assign SDA = (send_ready & SCL) ? send:8'bzzzzzzzz;       // #RECONFIRM    What to send when i dont want to control the line? - Z
assign address = address_reg_current;      // Garbage Value
assign control_first_block = (tick == 1) ? control_reg:8'h00;  // Garbage Value 
assign data_out = (tick == 1) ? data_reg:8'h00;                // Garbage Value 
assign reset = internal_reset;
assign enable_piso_wire = enable_piso;
assign send_ready_wire = send_ready;
endmodule





