module SD_Initial(
  input DO,
  output reg SCLK,
  output reg DI,
  output reg CS,
  input clk );
  
  reg [3:0] state;
  reg [10:0] count;
  
  reg [8:0] clk250khzCount;
  reg clk250khz;
  
  initial begin
    state <= 0;
    count <= 10;
    clk250khz <= 0;
    clk250khzCount <= 0;
  end  
  
  always @(posedge clk) begin
    if(clk250khzCount >= 100) begin
      clk250khzCount <= 0;
      clk250khz = !clk250khz;
    end
    else begin
      clk250khzCount <= clk250khzCount + 1;
    end
  end
  
  always @(posedge clk) begin
  
    SCLK = clk250khz;
  
    if(state == 0) begin
      DI = 1;
      CS = 1;
      count = 0;
    end
    else if(state == 1) begin
      if(count > 1000) begin
        state = 2;
      end
      else begin
        count = count + 1;
      end
    end
    else if(state == 2) begin
      count = 0;
      state = 3;
    end
    else if(state == 3) begin
      // Sent clock 74 times
      if(count > 100) begin
        state = 4;
      end
      else count = count + 1;
    end
    else if(state == 4) begin
      // sent CMD0
      
    end
    else begin
      state = 0;
    end
  end

endmodule