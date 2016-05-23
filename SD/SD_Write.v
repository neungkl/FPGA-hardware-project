`include "../SD/SD_CMD.v"
`include "../SD/SD_RP.v"
`include "../SD/SD_CMD_RP.v"

module SD_Write(
  input DO,
  output reg SCLK,
  output reg DI,
  output reg CS,
  output reg isFinish,
  input [7:0] foData_raw,
  input foStart,
  output reg foFinish,
  input clk,
  input reset,
  output [15:0] debug );
  
  parameter MEM_SIZE = 9;
  
  integer ADDR_SIZE = (1 << MEM_SIZE) - 1;
  
  reg [2:0] state;
  reg [2:0] state2;
  reg [7:0] foData;
  
  reg [7:0] data [0:ADDR_SIZE];
  reg [MEM_SIZE:0] id;
  
  reg sentBegin;
  reg sentFinish;
  
  initial begin
    foStart <= 0;
    foFinish <= 1;
    id <= 0;
    state <= 0;
    state2 <= 0;
    sentBegin <= 0;
    sentFinish <= 0;
  end
  
  always @(posedge clk) begin
    if(reset) begin
      foStart <= 0;
      foFinish <= 1;
      id <= 0;
      state <= 0;
      state2 <= 0;
      sentBegin <= 0;
      sentFinish <= 0;
    end
    else begin
    
    if(state == 0) begin
      if(foStart) begin
        foData = foData_raw;
        foFinish = 0;
        state = 1;
      end
    end
    else if(state == 1) begin
      data[id] = foData;
      if(id == ADDR_SIZE) begin
        state = 2;
      end
      else
        id = id + 1;
        state = 3;
      end
    end
    else if(state == 2) begin
      sentBegin = 1;
      if(sentFinish) begin
        sentBegin = 0;
        sentFinish = 0; 
        id = 0;
        state = 3;
      end
    end
    else if(state == 3) begin
      foFinish = 1;
      if(!foStart) begin
        state = 0;
      end
    end
    else state = 0;
    
    if(state2 == 0) begin
    end
    else state2 = 0;
    
    
    end
     
  end
  
endmodule