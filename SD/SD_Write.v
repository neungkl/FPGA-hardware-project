`include "../SD/SD_CMD.v"
`include "../SD/SD_RP.v"
`include "../SD/SD_CMD_RP.v"
`include "../SD/SD_Delay.v"
`include "../SD/SD_Data_RP.v"
`include "../SD/SD_Initial.v"

module SD_Write(
  input DO,
  output SCLK,
  output reg DI,
  output reg CS,
  output reg isFinish,
  input [7:0] foData_raw,
  input foStart,
  output reg foFinish,
  output sdInitFinish,
  input clk,
  input reset,
  output reg [15:0] debug );
  
  parameter MEM_SIZE = 9;
  parameter END_TOKEN = 8'h2D;
  parameter ADDR_SIZE = (1 << MEM_SIZE) - 1;
  
  reg [5:0] state;
  reg [2:0] state2;
  reg [7:0] foData;
  
  reg [7:0] data [0:ADDR_SIZE];
  reg [MEM_SIZE:0] id;
  
  reg [MEM_SIZE:0] i;
  reg [3:0] j;
  
  reg [7:0] dataToken;
  reg [15:0] CRC;
  
  reg sentBegin;
  reg sentFinish;
  
  reg [9:0] blockNumber;
  
  reg [5:0] sdIndex;
  reg [31:0] sdArgument;
	
  wire sdInitSCLK;
  wire sdInitDI;
  wire sdInitCS;
	
	assign SCLK = (state == 0) ? sdInitSCLK : clk;
  
  SD_Initial sdInit(
    .DO(DO),
    .SCLK(sdInitSCLK),
    .DI(sdInitDI),
    .CS(sdInitCS),
    .isStart(1),
    .isFinish(sdInitFinish),
    .clk(clk),
    .reset(reset)
  );
  
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
  
  reg sdDataRPReset;
  wire [3:0] sdDataRPStatus;
  wire sdDataRPFinish;
  
  SD_Data_RP sdDataRP(
    .DO(DO),
    .isStart(sdCMDRP_RPFinish),
    .isFinish(sdDataRPFinish),
    .status(sdDataRPStatus),
    .clk(SCLK),
    .reset(sdDataRPReset) 
  );
  
  initial begin
    foFinish = 1;
    id = 0;
    state = 0;
    state2 = 0;
    sentBegin = 0;
    sentFinish = 0;
    sdCMDRPStart = 0;
    sdDelayStart = 0;
    blockNumber = 16;
    sdDataRPReset = 1;
    i = 0;
    j = 0;
  end
  
  always @(posedge clk) begin
    if(reset) begin
      state2 = 0;
      id = 0;
      foFinish = 1;
    end 
    else begin
      if(state2 == 0) begin
        foFinish = 1;
        sentBegin = 0;
        if(foStart) begin
          foData = foData_raw;
          foFinish = 0;
          state2 = 1;
        end
      end
      else if(state2 == 1) begin
        data[id] = foData;
        if(id == ADDR_SIZE || foData == END_TOKEN) begin
          state2 = 2;
        end
        else begin
          id = id + 1;
          state2 = 3;
        end
      end
      else if(state2 == 2) begin
        sentBegin = 1;
        if(sentFinish) begin
          sentBegin = 0; 
          id = 0;
          state2 = 3;
        end
      end
      else if(state2 == 3) begin
        foFinish = 1;
        if(!foStart) begin
          state2 = 0;
        end
      end
      else state2 = 0;
    end
  end
  
  always @(posedge clk) begin
  
    if(reset) begin
      state = 0;
      sentFinish = 0;
      sdCMDRPStart = 0;
      blockNumber = 16;
      sdDelayStart = 0;
      sdDataRPReset = 1;
      isFinish = 0;
      i = 0;
      j = 0;
    end
    else begin
    
    if(state == 0) begin
      DI = sdInitDI;
      CS = sdInitCS;
      if(sdInitFinish) begin
        state = 1;
      end
    end
    else if(state == 1) begin
      DI = 1;
      CS = 0;
      sdDelayTimes = 4'hFF;
      sdDelayStart = 1;
      if(sdDelayFinish) begin
        sdDelayStart = 0;
        state = 2;
      end
    end
    else if(state == 2) begin
      sdCMDRPStart = 0;
      sdDataRPReset = 1;
      if(sentBegin) begin
        state = 3;
      end
    end
    else if(state == 3) begin
      if(DO) begin
        sdDelayTimes = 4'h0F;
        sdDelayStart = 1;
        if(sdDelayFinish) begin
          sdDelayStart = 0;
          state = 4;
        end
      end
    end
    else if(state == 4) begin
      // Sent CMD24
      DI = 1;
      if(!sdCMDRPBusy) begin
        sdIndex = 24;
        sdArgument = blockNumber;
        sdCMDRPStart = 1;
        sdDataRPReset = 0;
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
      // Delay 1 byte
      sdDelayTimes = 4'h0F;
      sdDelayStart = 1;
      if(sdDelayFinish) begin
        sdDelayStart = 0;
        
        i = 7;
        dataToken = 8'b1111110;
        
        state = 8;
      end
    end
    
    // Begin Sent Data Packet Flow
    
    else if(state == 8) begin
      DI = dataToken[i];
      if(i == 0) begin
        i = 0;
        j = 8;
        state = 9;
      end
      else i = i - 1;
    end
    else if(state == 9) begin
      DI = data[i][j];
      if((i == ADDR_SIZE || data[i] == END_TOKEN) && j == 0) begin
        CRC = 16'hFFFF;
        i = 15;
        state = 10;
      end
      else if(j == 0) begin
        j = 8;
        i = i + 1;
      end
      else j = j - 1;
    end
    else if(state == 10) begin
      DI = CRC[i];
      if(i == 0) begin
        state = 11;
      end
      else i = i - 1;
    end
    else if(state == 11) begin
      DI = 1;
      state = 12;
    end
    
    // End Sent Data Packet Flow
    
    else if(state == 12) begin
      if(sdDataRPFinish) begin
        sdDataRPReset = 1;
        state = 13;
      end
    end
    else if(state == 13) begin
      if(sdDataRPStatus == 4'b0101) begin
        state = 14;
      end
    end
    else if(state == 14) begin
      sentFinish = 1;
      isFinish = 1;
      if(!sentBegin) begin
        state = 15;
      end
    end
    else if(state == 15) begin
      
    end
      
    else state = 0;
    
    // END Program
    end
    
    debug = {sdCMDRPResponse[7:0], 2'b00, state[5:0]};
    
  end
  
endmodule