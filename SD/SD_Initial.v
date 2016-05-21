`include "../SD/SD_CMD.v"
`include "../SD/SD_RP.v"

module SD_Initial(
  input DO,
  output reg SCLK,
  output reg DI,
  output reg CS,
  input isStart,
  output reg isFinish,
  input clk,
  output [11:0] debug );
  
  reg [3:0] state;
  reg [10:0] count;
  
  reg [8:0] clk250khzCount;
  reg clk250khz;
  
  reg [5:0] sdIndex;
  reg [31:0] sdArgument;
  reg sdCMDStart;
  wire sdCMDBusy;
  wire sdCMDFinish;
  wire sdCMDDI;
  
  reg sdRPStart;
  wire sdRPBusy;
  wire sdRPFinish;
  wire [7:0] sdRPResponse;
  
  wire sdClk;
  assign sdClk = clk250khz;
  
  assign debug = {sdRPResponse, state};
  
  SD_CMD sdcmd(
    .index(sdIndex),
    .argument(sdArgument),
    .isStart(sdCMDStart),
    .isBusy(sdCMDBusy),
    .isFinish(sdCMDFinish),
    .DI(sdCMDDI),
    .clk(sdClk)
  );
  
  SD_RP sdrp(
    .DO(DO),
    .isStart(sdRPStart),
    .isBusy(sdRPBusy),
    .isFinish(sdRPFinish),
    .response(sdRPResponse),
    .clk(sdClk)
  );
  
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
      sdCMDStart = 0;
      
      if(isStart) begin
        state = 1;
      end
    end
    else if(state == 1) begin
      if(count > 1000) begin
        count = 0;
        state = 2;
      end
      else begin
        count = count + 1;
      end
    end
    else if(state == 2) begin
      // Sent clock 74 times
      if(count > 100) begin
        count = 0;
        state = 3;
      end
      else count = count + 1;
    end
    else if(state == 3) begin
      CS = 0;
      // delay 16 clocks
      if(count < 20) begin
        state = 4;
      end
      else count = count + 1;
    end
    else if(state == 4) begin
      // sent CMD0
      if(!sdCMDBusy) begin
        sdIndex = 0;
        sdArgument = 0;
        state = 5;
      end
    end
    else if(state == 5) begin
      sdCMDStart = 1;
      state = 6;
    end
    else if(state == 6) begin
      if(sdCMDFinish) begin
        sdCMDStart = 0;
        state = 7;
      end
    end
    else if(state == 7) begin
      // Wait response CMD0
      if(!sdRPBusy) begin
        sdRPStart = 1;
        state = 8;
      end
    end
    else if(state == 8) begin
      if(sdRPFinish) begin
        state = 9;
      end
    end
    else if(state == 9) begin
      if(sdRPResponse == 0) begin
        state = 10;
      end
    end
    else if(state == 10) begin
      state = 10;
    end
    else begin
      state = 0;
    end
  end

endmodule