module Parity(parbit, bitval, clk, enable, clr);
  output reg parbit;
  input bitval;
  input clk;
  input enable;
  input clr;
  
  always @(posedge clk) begin
    if(clr) parbit <= 0;
    else if(enable) parbit <= parbit ^ bitval;
  end
  
endmodule