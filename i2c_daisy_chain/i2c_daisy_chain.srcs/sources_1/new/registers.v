`timescale 1ns / 1ps

module registers
 // N = 3 - Total Register Banks
#(parameter n1 = 8,n2 = 10,n3 = 116)
(
  input [7:0] data_in,
  input [1:0] control_in,
  input clk,
  input [7:0] Addre,
  output [7:0] data_out,
  output [1:0] control_out,
  input resetn,
  // Part of External Interface
  input [7:0] Addr_external,
  output reg [7:0] Data_external_out,
  input clk_external
);
     // N = 3 - Total Register Banks
     // The rest can be changed
     localparam addr1 = 8'h0A;
     localparam addr2 = 8'h1A;
     localparam addr3 = 8'h2A;
     wire [0:8*(n1+n2+n3) - 1] external_data_connect;
     wire [0:n1+n2+n3 - 1] valid_connect;  
     wire [0:10*(n1+n2+n3-1) - 1] connect;

     
     genvar i;     
     generate 
     for (i = 0; i < n1  ; i = i + 1) begin : register_bank_1
              if(i==0) begin
               register_block #(.Address(addr1 + i)) DUT2(.Data_external_out(external_data_connect[8*i:8*i+7]),
                                                          .valid(valid_connect[i]),
                                                          .Addr_external(Addr_external),
                                                          .clk_external(clk_external),
                                                          .resetn(resetn),
                                                          .D_in(data_in),
                                                          .Control_in(control_in),
                                                          .Addr(Addre),
                                                          .clk(clk),
                                                          .data_out(connect[10*i:10*i+7]),
                                                          .Control_out(connect[10*i+8:10*i+9]));
                 end
               else begin
               register_block #(.Address(addr1 + i)) DUT2(.Data_external_out(external_data_connect[8*i:8*i+7]),
                                                          .valid(valid_connect[i]),
                                                          .Addr_external(Addr_external),
                                                          .clk_external(clk_external),
                                                          .resetn(resetn),
                                                          .D_in(connect[10*i-10:10*i-3]),
                                                          .Control_in(connect[10*i-2:10*i-1]),
                                                          .Addr(Addre),
                                                          .clk(clk),
                                                          .data_out(connect[10*i:10*i+7]),
                                                          .Control_out(connect[10*i+8:10*i+9]));
               end    
             end
     endgenerate 
     
     genvar j;
      generate 
      for (j = n1; j < n1 + n2 ; j = j + 1) begin : register_bank_2
           register_block #(.Address(addr2 + j - n1)) DUT2(.Data_external_out(external_data_connect[8*j:8*j+7]),
                                                           .valid(valid_connect[j]),
                                                           .Addr_external(Addr_external),
                                                           .clk_external(clk_external),
                                                           .resetn(resetn),
                                                           .D_in(connect[10*j-10:10*j-3]),
                                                           .Control_in(connect[10*j-2:10*j-1]),
                                                           .Addr(Addre),.clk(clk),
                                                           .data_out(connect[10*j:10*j+7]),
                                                           .Control_out(connect[10*j+8:10*j+9])); 
          end
      endgenerate 
      
     genvar k;
      generate 
      for (k = n1+n2; k < n1+n2+n3 ; k = k + 1) begin : register_bank_3
            if(k == (n1+n2+n3-1)) 
                register_block #(.Address(addr3 + k - n1 - n2)) DUT2(.Data_external_out(external_data_connect[8*k:8*k+7]),
                                                                     .valid(valid_connect[k]),
                                                                     .Addr_external(Addr_external),
                                                                     .clk_external(clk_external),
                                                                     .resetn(resetn),
                                                                     .D_in(connect[10*k-10:10*k-3]),
                                                                     .Control_in(connect[10*k-2:10*k-1]),
                                                                     .Addr(Addre),
                                                                     .clk(clk),
                                                                     .data_out(data_out),
                                                                     .Control_out(control_out));
                       
            else 
                register_block #(.Address(addr3 + k - n1 - n2)) DUT2(.Data_external_out(external_data_connect[8*k:8*k+7]),
                                                                     .valid(valid_connect[k]),
                                                                     .Addr_external(Addr_external),
                                                                     .clk_external(clk_external),
                                                                     .resetn(resetn),
                                                                     .D_in(connect[10*k-10:10*k-3]),
                                                                     .Control_in(connect[10*k-2:10*k-1]),
                                                                     .Addr(Addre),
                                                                     .clk(clk),
                                                                     .data_out(connect[10*k:10*k+7]),
                                                                     .Control_out(connect[10*k+8:10*k+9]));
                   
          end
      endgenerate      
      
      integer t;
      // External Interface
      always @* begin
        for(t = 0 ; t < n1 + n2 + n3 ; t = t+1) begin
            if (clk_external) begin
               if(valid_connect[t]) begin
                     Data_external_out[7] = external_data_connect[8*t];
                     Data_external_out[6] = external_data_connect[8*t + 1];
                     Data_external_out[5] = external_data_connect[8*t + 2];
                     Data_external_out[4] = external_data_connect[8*t + 3];
                     Data_external_out[3] = external_data_connect[8*t + 4];
                     Data_external_out[2] = external_data_connect[8*t + 5];
                     Data_external_out[1] = external_data_connect[8*t + 6];
                     Data_external_out[0] = external_data_connect[8*t + 7];
               end      
            end
        end
      end
      
endmodule
