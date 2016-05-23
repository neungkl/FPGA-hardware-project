module SD_Data_RP(
  input DO,
  input isStart,
  output reg isFinish,
  output reg [3:0] status,
  input clk,
  input reset );
  
  reg [2:0] state;
  reg [2:0] i;
  
  initial begin
    state <= 0;
    isFinish <= 0;
  end
  
  always @(posedge clk) begin
    if(reset) begin
      state = 0;
      isFinish = 0;
    end
    else begin
    
    if(state == 0) begin
      if(isStart) begin
        state = 1;
      end
    end
    else if(state == 1) begin
      if(!DO) begin
        i = 3;
        state = 2;
      end
    end
    else if(state == 2) begin
      status[i] = DO;
      if(i == 0) begin
        state = 3;
      end
      else i = i - 1;
    end
    else if(state == 3) begin
      isFinish = 1;
    end
    else state = 0;
    
    end
  end

endmodule