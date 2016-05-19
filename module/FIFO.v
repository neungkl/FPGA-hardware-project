module FIFO(dataIn, dataOut, count, isEmpty, isBusy, isFull, re, we, clk, reset);
  
  parameter MEM_SIZE = 10;
  
  output [7:0] dataOut;
  output reg [MEM_SIZE-1:0] count;
  output isEmpty;
  output isBusy;
  output isFull;
	input [7:0] dataIn;
  input re;
  input we;
  input clk;
  input reset;
	
  reg [7:0] mem [0:(1<<MEM_SIZE)-1];
  reg [MEM_SIZE-1:0] first;
  reg [MEM_SIZE-1:0] last;
  
  assign dataOut = mem[first];  
  assign isEmpty = (count == 0);
  assign isBusy = (re == 1 || we == 1);
  assign isFull = (count == (1<<MEM_SIZE));
  
  always @(posedge clk) begin
    if(reset) begin
      first = 0;
      last = 0;
			count = 0;
    end
    else begin
      if(re) begin
				if(isEmpty == 0) begin
          first = first + 1;
					count = count - 1;
        end
      end
      else if(we) begin
        mem[last] = dataIn;
        last = last + 1;
				count = count + 1;
      end
    end
  end
   
endmodule