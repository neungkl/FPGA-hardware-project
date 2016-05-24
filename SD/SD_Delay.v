module SD_Delay(
  start,
  finish,
  times,
  clk );
  
  parameter COUNT_SIZE = 4;
	
	input start;
	output reg finish;
	input [COUNT_SIZE-1:0] times;
	input clk;
  
  reg [COUNT_SIZE-1:0] count;
  
  reg [1:0] state;
  
  initial begin
    count <= 0;
    state <= 0;
    finish <= 0;
  end
  
  always @(posedge clk) begin
    if(state == 0) begin
      count <= 0;
      if(start) begin
        finish <= 0;
        state <= 1;
      end
    end
    else if(state == 1) begin
      if(count == times) begin
        state <= 2;
      end
      else count <= count + 1;
    end
    else if(state == 2) begin
      finish <= 1;
      if(!start) begin
        state <= 0;
      end
    end
    else state <= 0;
  end
  
endmodule