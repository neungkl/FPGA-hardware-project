`include "../SD/SD_CMD.v"
`include "../SD/SD_RP.v"
`include "../SD/SD_CMD_RP.v"
`include "../SD/SD_Delay.v"
`include "../SD/SD_Data_RP.v"
`include "../SD/SD_Initial.v"

module SD_Read(
  input DO,
  output SCLK,
  output reg DI,
  output reg CS,
  input isStart,
  output reg isFinish,
  output reg [7:0] foDataSent,
  output reg foWe,
  input foBusy,
  input clk,
  input reset,
  output reg [15:0] debug );

  reg [2:0] state;
  
  reg [7:0] foData;
  
  reg [7:0] data [0:ADDR_SIZE];
  reg [MEM_SIZE:0] id;
  
  reg [MEM_SIZE:0] i;
  reg [3:0] j;
  
  reg [7:0] dataToken;
  reg [15:0] CRC;
  
  reg [9:0] blockNumber;
  
  wire sdInitSCLK;
  wire sdInitDI;
  wire sdInitCS;
	
	assign SCLK = (state == 0) ? sdInitSCLK : clk;
  
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
  
  initial begin
    state = 0;
    sdCMDRPStart = 0;
    sdDelayStart = 0;
    blockNumber = 16;
    sdDataRPReset = 1;
    isFinish = 0;
    i = 0;
    j = 0;
    id = 0;
  end
  
  always @(posedge clk) begin
    if(reset) begin
      state = 0;
      foWe = 0;
      sdCMDRPStart = 0;
      blockNumber = 16;
      sdDataRPReset = 1;
      isFinish = 0;
      i = 0;
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
      if(isStart) begin
        state = 2;
      end
    end
    else if(state == 2) begin
      
    end
    else state = 0;
    
    end
    
  end

endmodule