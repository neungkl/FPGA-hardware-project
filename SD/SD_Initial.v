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
  output [15:0] debug );
  
  reg [5:0] state;
  reg [15:0] count;
  
  reg [8:0] clk250khzCount;
  reg clk250khz;
  
  reg [5:0] sdIndex;
  reg [31:0] sdArgument;
  reg sdCMDStart;
  wire sdCMDBusy;
  wire sdCMDFinish;
  wire sdCMDDI;
  
  wire sdRPNewResponse;
	reg sdRPRecieved;
  wire [39:0] sdRPResponse;
  
  wire sdClk;
  assign sdClk = clk250khz;
  
  assign debug = {sdRPResponse[7:0], 2'b0, state[5:0]};
  
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
    .cmd(sdIndex),
    .isRecieved(sdRPRecieved),
    .isNewResponse(sdRPNewResponse),
    .response(sdRPResponse),
    .clk(sdClk)
  );
  
  initial begin
    state <= 0;
    count <= 10;
    clk250khz <= 0;
    clk250khzCount <= 0;
		sdRPRecieved <= 0;
  end  
  
  always @(posedge clk) begin
    if(clk250khzCount >= 100) begin
      clk250khzCount <= 0;
      clk250khz <= !clk250khz;
			SCLK <= clk250khz;
    end
    else begin
      clk250khzCount <= clk250khzCount + 1;
    end
  end
  
  always @(posedge clk) begin
  
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
      // Sent clock 74 times
      if(count > 30000) begin
        count = 0;
        state = 2;
      end
      else count = count + 1;
    end
    else if(state == 2) begin
      // CS Low with delay 16 clocks
			CS = 0;
      if(count > 5000) begin
				count = 0;
        state = 3;
      end
      else count = count + 1;
    end
    else if(state == 3) begin
      // sent CMD0
      if(!sdCMDBusy) begin
        sdIndex = 0;
        sdArgument = 0;
        sdCMDStart = 1;
        state = 4;
      end
    end
    else if(state == 4) begin
			DI = sdCMDDI;
      if(sdCMDFinish) begin
        sdCMDStart = 0;
        state = 5;
      end
    end
    else if(state == 5) begin
      // Wait response CMD0
			DI = 1;
      if(sdRPNewResponse) begin
        sdRPRecieved = 1;
        state = 6;
      end
    end
    else if(state == 6) begin
			if(!sdRPNewResponse) begin
				sdRPRecieved = 0;
				if(sdRPResponse == 40'h0000000001) begin
					state = 7;
				end
			end
    end
    else if(state == 8) begin
      // Sent CMD55
      if(!sdCMDBusy) begin
        sdIndex = 55;
        sdArgument = 0;
        sdCMDStart = 1;
        state = 9;
      end
    end
    else if(state == 9) begin
      DI = sdCMDDI;
      if(sdCMDFinish) begin
        sdCMDStart = 0;
        state = 10;
      end
    end
    else if(state == 10) begin
      // Wait response CMD55
      DI = 1;
			if(sdRPNewResponse) begin
				sdRPRecieved = 1;
				state = 11;
			end
    end
    else if(state == 11) begin
			if(!sdRPNewResponse) begin
				sdRPRecieved = 0;
				if(sdRPResponse == 40'h0000000001) begin
					state = 12;
				end
			end
    end
    else if(state == 12) begin
      // Sent ACMD41
      if(!sdCMDBusy) begin
        sdIndex = 41;
        sdArgument = 32'h00100000;
        sdCMDStart = 1;
        state = 13;
      end
    end
    else if(state == 13) begin
      DI = sdCMDDI;
      if(sdCMDFinish) begin
        sdCMDStart = 0;
        state = 14;
      end
    end
    else if(state == 14) begin
      // Wait response ACMD41
      DI = 1;
      if(sdRPNewResponse) begin
				sdRPRecieved = 1;
				state = 15;
			end
    end
    else if(state == 15) begin
			if(!sdRPNewResponse) begin
				sdRPRecieved = 0;
				if(sdRPResponse == 0) begin
					state = 16;
				end
				else state = 15;
			end			
    end
		else if(state == 16) begin
		end
    else begin
      state = 0;
    end
  end

endmodule