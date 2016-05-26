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
  
  reg [7:0] data [0:ADDR_SIZE];
  
  integer i;
  integer j;
  
  reg [9:0] blockNumber;
	
  wire sdInitSCLK;
  wire sdInitDI;
  wire sdInitCS;
	
	assign SCLK = sdInitSCLK;
  
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
    blockNumber = 4;
    i = 0;
    j = 0;
  end
  
  /*always @(posedge clk) begin
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
          sentBegin = 1;
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
  end*/
  
  always @(posedge clk) begin
  
    if(reset) begin
      state = 0;
      sdCMDRPStart = 0;
      blockNumber = 4;
      isFinish = 0;
			DI = 1;
    end
    else begin
    
    if(state == 0) begin
      DI = sdInitDI;
      CS = sdInitCS;
      blockNumber = 4;
      if(sdInitFinish) begin
        state = 1;
      end
    end
    else if(state == 1) begin
      state = 1;
    end
		
		// END Program
		end
      
	end
  
endmodule