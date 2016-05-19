`include "Parity.v"

module UART_Sender(
  output reg isFinish,
  output bitSent,
  input start,
  input [7:0] data,
  input clk);
  
  reg parityBit;
  reg parityEnable;
  reg parityClr;
  reg bitSent;
  
  Parity par(parityBit, bitSent, clk, parityEnable, parityClr);
  
  reg [2:0] state;
  reg [2:0] i;
  
  always @(posedge clk) begin
    if(state == 0) begin
      if(start) begin
        isFinish <= 0;
        state <= 1;
        parityClr <= 0;
        i <= 0;
      end
    end
    else if(state == 1) begin
      bitSent <= 0;
      parityEnable <= 1;
      state <= 2;
    end
    else if(state == 2) begin
      bitSent = data[i];
      if(i == 7) state = 3;
      else i = i + 1;
    end
    else if(state == 3) begin
      bitSent <= checkBit;
      state <= 4;
    end
    else if(state == 4) begin
      bitSent <= 1;
      state <= 5;
    end
    else if(state == 5) begin
      bitSent <= 1;
      isFinish <= 1;
      state <= 6;
    end
    else begin
      state <= 0;
      bitSent <= 1;
      parityEnable <= 0;
      parityClr <= 1;
    end
  end
   
endmodule