`timescale 1ns / 1ps

module registers(
  input [7:0] data_in,
  input [1:0] control_in,
  input clk,
  input [7:0] Addre,
  output [7:0] data_out,
  output [1:0] control_out
     );
     // N = 3 - Total Register Banks
     // The rest can be changed
     parameter n1 = 8,n2 = 10,n3 = 16;
     parameter addr1 = 8'b10101010;
     parameter addr2 = 8'b11101010;
     parameter addr3 = 8'b11111010;
     
     wire [0:10*(n1+n2+n3) - 1] connect;
     genvar i;     
     generate 
     for (i = 0; i < n1  ; i = i + 1) begin : register_bank_1
              if(i==0) begin
               register_block #(.Address(addr1 + i)) DUT2(.D_in(data_in),.Control_in(control_in),.Addr(Addre),.clk(clk),.D_out(connect[10*i:10*i+7]),.Control_out(connect[10*i+8:10*i+9]));
                 end
               else begin
               register_block #(.Address(addr1 + i)) DUT2(.D_in(connect[10*i-10:10*i-3]),.Control_in(connect[10*i-2:10*i-1]),.Addr(Addre),.clk(clk),.D_out(connect[10*i:10*i+7]),.Control_out(connect[10*i+8:10*i+9]));
               end    
             end
     endgenerate 
     
     genvar j;
          generate 
          for (j = n1; j < n1 + n2 ; j = j + 1) begin : register_bank_2
               register_block #(.Address(addr2 + j - n1)) DUT2(.D_in(connect[10*j-10:10*j-3]),.Control_in(connect[10*j-2:10*j-1]),.Addr(Addre),.clk(clk),.D_out(connect[10*j:10*j+7]),.Control_out(connect[10*j+8:10*j+9])); 
              end
          endgenerate 
          
     genvar k;
               generate 
               for (k = n1+n2; k < n1+n2+n3 ; k = k + 1) begin : register_bank_3
                     if(i == (n1+n2+n3-1)) begin
                              register_block #(.Address(addr3 + k - n1 - n2)) DUT2(.D_in(connect[10*k-10:10*k-3]),.Control_in(connect[10*k-2:10*k-1]),.Addr(Addre),.clk(clk),.D_out(data_out),.Control_out(control_out));
                                end
                     else begin
                      register_block #(.Address(addr3 + k - n1 - n2)) DUT2(.D_in(connect[10*k-10:10*k-3]),.Control_in(connect[10*k-2:10*k-1]),.Addr(Addre),.clk(clk),.D_out(connect[10*k:10*k+7]),.Control_out(connect[10*k+8:10*k+9]));
                              end    
                   end
               endgenerate      
endmodule
