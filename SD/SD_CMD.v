`include "../module/CRC7.v"

module SD_CMD(
  input [5:0] index,
  input [31:0] argument,
  input isStart,
  output reg isBusy,
  output reg isFinish,
  output reg DI,
  input clk );

  wire [39:0] dataForCRC;
  assign dataForCRC = {2'b01, index, argument};
  
  reg [7:0] i;
  reg [3:0] state;
  
  reg crcClear;
  reg crcEnable;
  reg crcBit;
  
  reg [6:0] CRC;

  initial begin
    isBusy <= 0;
    isFinish <= 0;
    state <= 0;
    i <= 0;
    crcClear <= 1;
    crcEnable <= 0;
    crcBit <= 0;
    DI <= 1;
  end
  
  always @(posedge clk) begin
    if(state == 0) begin
      crcClear = 1;
      crcEnable = 0;
			isFinish = 0;
			isBusy = 0;
      CRC = 0;
      DI = 1;
      if(isStart) begin
        isBusy = 1;
        state = 1;
      end
    end
    else if(state == 1) begin
      i = 39;
      crcClear = 0;
      state = 2;
    end
    else if(state == 2) begin
      crcBit = dataForCRC[i];
      crcEnable = 1;
      if(i == 0) begin
        state = 3;
      end
      else i = i - 1;
    end
    else if(state == 3) begin
      crcEnable = 0;
      case(index)
      0 : CRC = 7'h4A;
      8 : CRC = 7'h43;
      default : CRC = 0;
      endcase
      
      state = 4;
    end
    // Begin Sent CMD
    else if(state == 4) begin
      DI = 0;
      state = 5;
    end
    else if(state == 5) begin
      DI = 1;
      i = 5;
      state = 6;
    end
    else if(state == 6) begin
      DI = index[i];
      if(i == 0) begin
        i = 31;
        state = 7;
      end
      else i = i - 1;
    end
    else if(state == 7) begin
      DI = argument[i];
      if(i == 0) begin
        i = 6;
        state = 8;
      end
      else i = i - 1;
    end
    else if(state == 8) begin
      DI = CRC[i];
      if(i == 0) begin
        state = 9;
      end
      else i = i - 1;
    end
    else if(state == 9) begin
      DI = 1;
      crcClear = 1;
			isFinish = 1;
      isBusy = 1;
			if(!isStart) begin
				state = 0;
			end
    end
    else state = 0;
  end


endmodule