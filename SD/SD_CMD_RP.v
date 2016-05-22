module SD_CMD_RP(
  input [5:0] index,
  input [31:0] argument,
  input isStart,
  output reg isBusy,
  output reg isFinish,
  output DI,
  input DO,
  output reg [39:0] response,
  input clk );
  
  reg [2:0] state;
  
  reg sdCMDStart;
  wire sdCMDBusy;
  wire sdCMDFinish;
  wire [39:0] response_raw;
  
  wire sdRPNewResponse;
  
  reg reset = 0;
  
  SD_CMD sdcmd(
    .index(index),
    .argument(argument),
    .isStart(sdCMDStart),
    .isBusy(sdCMDBusy),
    .isFinish(sdCMDFinish),
    .DI(DI),
    .clk(clk)
  );
  
  SD_RP sdrp(
    .DO(DO),
    .cmd(index),
    .isNewResponse(sdRPNewResponse),
    .response(response_raw),
    .clk(clk),
    .reset(reset)
  );
  
  initial begin
    isBusy <= 0;
    isFinish <= 0;
    state <= 0;
    sdCMDStart <= 0;
    reset <= 1;
  end
  
  always @(posedge clk) begin
    if(state == 0) begin
      reset = 1;
      isFinish = 0;
      isBusy = 0;
      if(isStart) begin
        isBusy = 1;
        reset = 0;
        state = 1;
      end
    end
    else if(state == 1) begin
      if(!sdCMDBusy) begin
        sdCMDStart = 1;
        state = 2;
      end
    end
    else if(state == 2) begin
      if(sdCMDFinish) begin
        state = 3;
      end
    end
    else if(state == 3) begin
      if(sdRPNewResponse) begin
        response = response_raw;
        state = 4;
      end
    end
    else if(state == 4) begin
      sdCMDStart = 0;
      if(!sdCMDBusy) begin
        state = 5;
      end
    end
    else if(state == 5) begin
      isFinish = 1;
      reset = 1;
      if(!isStart) begin
        state = 0;
      end
    end
    else state = 0;
  end

endmodule