module SD_Initial(
  input DO,
  output reg SCLK,
  output reg DI,
  output reg CS,
  input isStart,
  output reg isFinish,
  input clk,
  input reset,
  output [15:0] debug );
  
  reg [5:0] state;
  reg [15:0] count;
  
  reg clk250khzTrigger;
  reg [8:0] clk250khzCount;
  reg clk250khz;
  
  wire sdClk;
  assign sdClk = clk250khz;
  
  reg [5:0] sdIndex;
  reg [31:0] sdArgument;
  
  reg sdCMDRPStart;
  wire sdCMDRPFinish;
	wire sdCMDRPBusy;
  wire sdCMDRPDI;
  wire [39:0] sdCMDRPResponse;
  
  assign debug = {sdCMDRPResponse[7:0], 2'b0, state[5:0]};
  //assign debug = {sdCMDRPResponse[31:16]};
  
  SD_CMD_RP SDCMDRP(
    .index(sdIndex),
    .argument(sdArgument),
    .isStart(sdCMDRPStart),
    .isBusy(sdCMDRPBusy),
    .isFinish(sdCMDRPFinish),
    .DI(sdCMDRPDI),
    .DO(DO),
    .response(sdCMDRPResponse),
    .clk(sdClk)
  );
  
  initial begin
    state <= 0;
    count <= 10;
    clk250khz <= 0;
    clk250khzCount <= 0;
		sdCMDRPStart <= 0;
  end  
  
  always @(posedge clk) begin
    if(clk250khzCount >= 100) begin
      clk250khzCount <= 0;
      clk250khz <= !clk250khz;
      clk250khzTrigger <= 1;
			SCLK <= clk250khz;
    end
    else begin
      clk250khzTrigger <= 0;
      clk250khzCount <= clk250khzCount + 1;
    end
  end
  
  always @(posedge clk) begin
  
    if(reset) begin
      isFinish = 0;
      sdCMDRPStart = 0;
      state = 0;
    end
    else begin
  
    if(state == 0) begin
      DI = 1;
      CS = 1;
      count = 0;
      isFinish = 0;
      sdCMDRPStart = 0;
      
      if(isStart) begin
        state = 1;
      end
    end
    else if(state == 1) begin
      // Sent clock 74 times
      if(clk250khzTrigger) begin
        if(count > 30000) begin
          count = 0;
          state = 2;
        end
        else count = count + 1;
      end
    end
    else if(state == 2) begin
      // CS Low with delay 16 clocks
			CS = 0;
      if(clk250khzTrigger) begin
        if(count > 30) begin
          count = 0;
          state = 3;
        end
        else count = count + 1;
      end
    end
    else if(state == 3) begin
      // sent CMD0
      DI = 1;
      if(!sdCMDRPBusy) begin
        sdIndex = 0;
        sdArgument = 0;
        sdCMDRPStart = 1;
        state = 4;
      end
    end
    else if(state == 4) begin
			DI = sdCMDRPDI;
      if(sdCMDRPFinish) begin
        sdCMDRPStart = 0;
        state = 5;
      end
    end
    else if(state == 5) begin
      // Check response CMD0
			DI = 1;
      if(sdCMDRPResponse == 40'h0000000001) begin
        state = 6;
      end
    end
    else if(state == 6) begin
      // Sent CMD8
      if(!sdCMDRPBusy) begin
        sdIndex = 8;
        sdArgument = 32'h000001AA;
        sdCMDRPStart = 1;
        state = 7;
      end
    end
    else if(state == 7) begin
      DI = sdCMDRPDI;
      if(sdCMDRPFinish) begin
        sdCMDRPStart = 0;
        state = 8;
      end
    end
    else if(state == 8) begin
      // Check response CMD8
      DI = 1;
      if(sdCMDRPResponse[11:0] == 12'h01AA) begin
        state = 9;
      end
      else if(sdCMDRPResponse[39:32] == 8'h09) begin
        state = 6;
      end
    end
    else if(state == 9) begin
      // Sent CMD55
      DI = 1;
      if(!sdCMDRPBusy) begin
        sdIndex = 55;
        sdArgument = 0;
        sdCMDRPStart = 1;
        state = 10;
      end
    end
    else if(state == 10) begin
      DI = sdCMDRPDI;
      if(sdCMDRPFinish) begin
        sdCMDRPStart = 0;
        state = 11;
      end
    end
    else if(state == 11) begin
      // Check response CMD55
      DI = 1;
      if(sdCMDRPResponse == 40'h0000000001) begin
        state = 13;
      end
			else if(sdCMDRPResponse == 40'hFFFFFFFFFF) begin
				state = 12;
			end
    end
    else if(state == 12) begin
      if(clk250khzTrigger) begin
        if(count > 60000) begin
          count = 0;
          state = 9;
        end
        else count = count + 1;
      end
    end
    else if(state == 13) begin
      // Sent CMD41
      if(!sdCMDRPBusy) begin
        sdIndex = 41;
        sdArgument = 32'h40000000;
        sdCMDRPStart = 1;
        state = 14;
      end
    end
    else if(state == 14) begin
      DI = sdCMDRPDI;
      if(sdCMDRPFinish) begin
        sdCMDRPStart = 0;
        state = 15;
      end
    end
    else if(state == 15) begin
      // Check response CMD41
      DI = 1;
      if(sdCMDRPResponse == 40'h0000000000) begin
        state = 17;
      end
      else state = 16;
    end
    else if(state == 16) begin
      if(clk250khzTrigger) begin
        if(count > 60000) begin
          count = 0;
          state = 9;
        end
        else count = count + 1;
      end
    end
    else if(state == 17) begin
      // Sent CMD58
      if(!sdCMDRPBusy) begin
        sdIndex = 58;
        sdArgument = 0;
        sdCMDRPStart = 1;
        state = 18;
      end
    end
    else if(state == 18) begin
      DI = sdCMDRPDI;
      if(sdCMDRPFinish) begin
        sdCMDRPStart = 0;
        state = 19;
      end
    end
    else if(state == 19) begin
      // Check response CMD58
      DI = 1;
      if(sdCMDRPResponse[30] == 0) begin
        state = 20;
      end
      else state = 23;
    end
    else if(state == 20) begin
      // Sent CMD16
      if(!sdCMDRPBusy) begin
        sdIndex = 16;
        sdArgument = 32'h00000200;
        sdCMDRPStart = 1;
        state = 21;
      end
    end
    else if(state == 21) begin
      DI = sdCMDRPDI;
      if(sdCMDRPFinish) begin
        sdCMDRPStart = 0;
        state = 22;
      end
    end
    else if(state == 22) begin
      DI = 1;
      if(sdCMDRPResponse == 0 || sdCMDRPResponse == 8'h40) begin
        state = 23;
      end
    end
    else if(state == 23) begin
      isFinish = 1;
    end
    else begin
      state = 0;
    end
    
    end
    
  end

endmodule