module PISO_tb;

localparam N = 8;
reg [N -1:0] data_in;
reg enable;
reg SCL;
reg tick;
wire data_active;// Data ACtive
wire serial_output;

parallel_input_serial_output DUT (data_in,enable,SCL,tick,data_active,serial_output);
initial begin
  SCL=0;
     forever #1 SCL = ~SCL;  
end 
initial begin
  tick=0;
  #1;
  tick = 1;
  forever #18 tick = 1;
    
end 
initial begin

    forever #2 tick = 0;  
end

initial begin 

enable = 1;
#1;   
#1;   data_in = 8'b10100011;
#8;   data_in = 'bz;
#10;  data_in = 8'b10100011; 
#10;  data_in = 8'b10101111;
#10;  data_in = 8'b10110011;
#10;  data_in = 8'b10110011;
end 


endmodule
