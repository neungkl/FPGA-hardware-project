module SD_RP(
  input DO,
  input isStart,
  output reg isBusy,
  output reg isFinish,
  output reg [7:0] response,
  input clk );
  
  reg [2:0] i;
  reg [2:0] state;
  
  initial begin
    state = 0;
    response = 0;
  end
  
  always @(posedge clk) begin
    if(state == 0) begin
      if(isStart) begin
        response = 0;
        isBusy = 1;
        isFinish = 0;
        state = 1;
      end
    end
    else if(state == 1) begin
      if(!DO) begin
        i = 6;
        state = 2;
      end
    end
    else if(state == 2) begin
      response[i] = DO;
      if(i == 0) state = 3;
      else i = i - 1;
    end
    else if(state == 3) begin
      response[7] = !DO;
      state = 4;
    end
    else if(state == 4) begin
      isFinish = 1;
      isBusy = 0;
      state = 0;
    end
    else state = 0;
  end
  
endmodule