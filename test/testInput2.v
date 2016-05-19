`include "../structure/Out_to_com.v"
`include "../structure/FIFO_to_out.v"
`include "../module/FIFO.v"
`include "../module/SinglePulser.v"
`include "../module/SevenSegment.v"
`include "../module/Flush.v"
`include "../module/Parity.v"

module testInput2(
  output a,
  output b,
  output c,
  output d,
  output e,
  output f,
  output g,
  output numsl0,
  output numsl1,
  output numsl2,
  output numsl3,
  output tx,
  input rx,
  input pb1_raw,
  input pb2_raw,
  input clk_raw );
  
  wire pb1;
  wire pb2;
  
  reg [16:0] clkcount;
  reg [11:0] clkUARTcount;
  reg clk;
  wire clktrigger;
  
  wire isFifoEmpty;
  wire isFifoBusy;
  wire isFifoFull;
  wire [9:0] fifoCount;
  wire fifoRe;
  reg fifoWe;
  reg reset;
  
  wire isFifoToOutFinish;
  wire isOutToComFinish;
  
  wire [7:0] outData;
  reg [3:0] state;
  reg [7:0] tmpData;
  
  wire isOutStart;
  
  reg fifoToOutEnable;
  reg outToComEnable;
  
  reg [7:0] fifoDataIn;
  wire [7:0] fifoDataOut;
  
  reg beginUpload;
  reg [7:0] value;
  
  assign clktrigger = clkcount[16];
	
  wire [7:0] debug;
  //assign debug = fifoDataOut;
  
	reg [3:0] flushState;
	Flush #(4) f1(flushState);
	
  SinglePulser sp1(pb1, pb1_raw, clktrigger);
  SinglePulser sp2(pb2, pb2_raw, clktrigger);
  FIFO_to_out fifotoout(isFifoToOutFinish, fifoRe, outData, isOutStart, isFifoBusy, isFifoEmpty, fifoDataOut, isOutToComFinish, clk, fifoToOutEnable);
  Out_to_com outtocom(isOutToComFinish, tx, isOutStart, outData, clk, outToComEnable);
  FIFO fo(fifoDataIn, fifoDataOut, fifoCount, isFifoEmpty, isFifoBusy, isFull, fifoRe, fifoWe, clk, reset);
  
  SevenSegment svsg(a, b, c, d, e, f, g, numsl0, numsl1, numsl2, numsl3, clk_raw, 0, debug[3:0], outData[3:0], value[7:4], value[3:0]);
  
  initial begin
    clk = 0;
    clkcount = 0;
    clkUARTcount = 0;
    reset = 1;
    value = 8'h41;
		beginUpload = 0;
  end
  
  always @(posedge clk_raw) begin
    clkcount = clkcount + 1;
		clkUARTcount = clkUARTcount + 1;
    if(clkUARTcount > 1159) begin
      clkUARTcount = 0;
			clk = !clk;
    end
  end
	
	always @(posedge clktrigger) begin
		if(pb1) begin
			reset = 1;
		end
    else if(pb2) begin
      beginUpload = 1;
    end
		else begin
      beginUpload = 0;
			reset = 0;
		end
	end
  
  always @(posedge clk) begin
	
		if(state == 0) begin
			if(beginUpload) begin
        fifoDataIn = value;
        state = 1;
      end
		end
    else if(state == 1) begin
			if(!isFifoBusy) begin
				fifoWe = 1;
				state = 2;
			end
		end
		else if(state == 2) begin
      fifoWe = 0;
			value = value + 1;
      state = 3;
    end
    else if(state == 3) begin
      if(beginUpload == 0) begin
        state = 4;
      end
    end
		else begin
			state = 0;
			fifoToOutEnable = 1;
			outToComEnable = 1;
		end
		flushState = state;
  end

endmodule