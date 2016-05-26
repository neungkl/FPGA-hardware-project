`include "../SD/SD_CMD.v"
`include "../SD/SD_RP.v"
`include "../SD/SD_CMD_RP.v"
`include "../SD/SD_Delay.v"
`include "../SD/SD_Data_RP.v"
`include "../SD/SD_Initial.v"
`include "../SD/SD_CLK_COUNT.v"

module SD_Read(
  input DO,
  output SCLK,
  output reg DI,
  output reg CS,
  input isStart,
  output isInitSDFinish,
  output reg isFinish,
  output reg [7:0] foDataSent,
  output reg foWe,
  input foBusy,
  input foFull,
  input clk,
  input reset,
  output [15:0] debug );
  
  parameter MEM_SIZE = 9;
  parameter END_TOKEN = 8'h2D;
  parameter ADDR_SIZE = (1 << MEM_SIZE) - 1;
  
  reg [5:0] state;
  reg [2:0] state2;
  reg [7:0] foData;
  
  reg [7:0] data [0:ADDR_SIZE];
  reg [MEM_SIZE:0] id;
  
  integer i;
	integer i2;
  integer j;
  
  reg [15:0] CRC;
  
  reg [MEM_SIZE:0] blockNumber;
	
  wire sdInitSCLK;
  wire sdInitDI;
  wire sdInitCS;
	wire sdInitFinish;
  
  assign isInitSDFinish = sdInitFinish;
  
  SD_Initial sdInit(
    .DO(DO),
    .SCLK(sdInitSCLK),
    .DI(sdInitDI),
    .CS(sdInitCS),
    .isStart(1),
    .isFinish(sdInitFinish),
    .clk(clk),
    .reset(reset),
		.debug(debug)
  );
  
  assign SCLK = sdInitSCLK;
  
  reg sdDelayStart;
  reg [3:0] sdDelayTimes;
  wire sdDelayFinish;
  
  SD_Delay #(.COUNT_SIZE(4)) sdDelay(
    .start(sdDelayStart),
    .finish(sdDelayFinish),
    .times(sdDelayTimes),
    .clk(SCLK) 
  );
  
  reg [5:0] sdCMDRPIndex;
  reg [31:0] sdCMDRPArgument;
  reg sdCMDRPStart;
	wire sdCMDRPDI;
  wire sdCMDRPBusy;
  wire sdCMDRPFinish;
  wire sdCMDRP_RPFinish;
  wire [39:0] sdCMDRPResponse;
  
  SD_CMD_RP sdCMDRP(
    .index(sdCMDRPIndex),
    .argument(sdCMDRPArgument),
    .isStart(sdCMDRPStart),
    .isBusy(sdCMDRPBusy),
    .isFinish(sdCMDRPFinish),
    .isRPFinish(sdCMDRP_RPFinish),
    .DI(sdCMDRPDI),
    .DO(DO),
    .response(sdCMDRPResponse),
    .clk(SCLK)
  );
	
	reg pushToFiFoFinish;
  
	//assign debug = {blockNumber[3:0], id[3:0], 8'h00, state[3:0]};
  //debug = {}	
  
  initial begin
    state = 0;
    sdCMDRPStart = 0;
    sdDelayStart = 0;
    blockNumber = 4;
    isFinish = 0;
    i = 0;
    j = 0;
    i2 = 0;
    id = 0;
    DI = 1;
    pushToFiFoFinish = 0;
  end
  
  // Fetching Data Packet
  always @(posedge clk) begin
    if(reset) begin
      i = 0;
      j = 0;
      state2 = 0;
    end
    else begin
    
    if(state2 == 0) begin
      i = 0;
      j = 0;
      if(sdCMDRP_RPFinish) begin
        state2 = 1;
      end
    end
    else if(state2 == 1) begin
      if(!DO) begin
        j = 7;
        i = 0;
        state2 = 2;
      end
    end
    else if(state2 == 2) begin
      data[i][j] = DO;
      if(j == 0) begin
        if(i == ADDR_SIZE) begin
          state2 = 3;
        end
        else begin
          j = 7;
          i = i + 1;
        end
      end
      else j = j - 1;
    end
    else if(state2 == 3) begin
      if(pushToFiFoFinish) begin
        state2 = 0;
      end
    end
    else state2 = 0;
    
    end
  end
  
  always @(posedge clk) begin
    if(reset) begin
      state = 0;
      foWe = 0;
      sdCMDRPStart = 0;
      blockNumber = 4;
      isFinish = 0;
			DI = 1;
      i2 = 0;
    end
    else begin
    
    if(state == 0) begin
      DI = sdInitDI;
      CS = sdInitCS;
      blockNumber = 4;
      isFinish = 0;
      if(sdInitFinish) begin
        state = 1;
      end
    end
    else if(state == 1) begin
      DI = 1;
      CS = 0;
      sdDelayTimes = 8'h0F;
      sdDelayStart = 1;
      if(sdDelayFinish) begin
        sdDelayStart = 0;
        state = 2;
      end
    end
    else if(state == 2) begin
      if(DO) begin
        sdCMDRPStart = 0;
        if(isStart) begin
          state = 3;
        end
      end
    end
    else if(state == 3) begin
      sdDelayTimes = 8'h0F;
      sdDelayStart = 1;
      if(sdDelayFinish) begin
        sdDelayStart = 0;
        state = 4;
      end
    end
    else if(state == 4) begin
      // CMD17
      DI = 1;
      pushToFiFoFinish = 0;
      if(!sdCMDRPBusy) begin
        sdCMDRPIndex = 17;
        sdCMDRPArgument = blockNumber;
        sdCMDRPStart = 1;
        state = 5;
      end
    end
    else if(state == 5) begin
      DI = sdCMDRPDI;
      if(sdCMDRPFinish) begin
        sdCMDRPStart = 0;
        state = 6;
      end
    end
    else if(state == 6) begin
      DI = 1;
      if(sdCMDRPResponse == 0) begin
        state = 7;
      end
    end
    else if(state == 7) begin
      // Wait for Data Complete
      if(state2 == 3) begin
        i2 = 0;
        state = 8;
      end
    end
    else if(state == 8) begin
      if(!foBusy && !foFull) begin
        foDataSent = data[i2];
        foWe = 1;
        state = 9;
      end
    end
    else if(state == 9) begin
      foWe = 0;
      if(foDataSent == END_TOKEN) begin
        state = 10;
      end
      else if(i2 == ADDR_SIZE) begin
        state = 11;
      end
      else begin
        i2 = i2 + 1;
        state = 8;
      end
    end
    else if(state == 10) begin
      blockNumber = blockNumber + 1;
      state = 2;
    end
    else if(state == 11) begin
      pushToFiFoFinish = 1;
      isFinish = 1;
    end
    else state = 0;
      
    end
    
  end
  
endmodule