`include "../structure/COM_to_FIFO.v"
`include "../structure/FIFO_to_out.v"
`include "../module/FIFO.v"
`include "../module/SinglePulser.v"
`include "../module/SevenSegment.v"
`include "../module/CRC8.v"
`include "../module/UART_Reciever.v"
`include "../module/Flush.v"

module testInput1(
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
  input clk_raw );
  
  wire pb1;
  
  reg [16:0] clkcount;
  reg [11:0] clkUARTcount;
  reg clk;
  wire clktrigger;
  
  wire isFifoEmpty;
  wire isFifoBusy;
  wire isFifoFull;
  wire [9:0] fifoCount;
  wire fifoRe;
  wire fifoWe;
  reg reset;
  
  wire isComToFifoFinish;
  wire isFifoToOutFinish;
  wire [3:0] comToFifoError;
  wire [7:0] CRC;
  
  wire [7:0] outData;
  reg [3:0] state;
  reg [7:0] tmpData;
  
  wire isOutStart;
  reg isOutFinish;
  
  reg comToFifoEnable;
  reg fifoToOutEnable;
  
  wire [7:0] fifoDataIn;
  wire [7:0] fifoDataOut;
  
  assign clktrigger = clkcount[16];
	
  wire [7:0] debug;
	
	reg [3:0] flushState;
	Flush #(4) f1(flushState);
  
  SinglePulser sp1(pb1, pb1_raw, clktrigger);
  COM_to_FIFO comtofifo(isComToFifoFinish, CRC, comToFifoError, fifoDataIn, fifoWe, tx, rx, isFifoBusy, clk, comToFifoEnable, reset);
  FIFO_to_out fifotoout(isFifoToOutFinish, fifoRe, outData, isOutStart, isFifoBusy, isFifoEmpty, fifoDataOut, isOutFinish, clk, fifoToOutEnable);
  FIFO fo(fifoDataIn, fifoDataOut, fifoCount, isFifoEmpty, isFifoBusy, isFull, fifoRe, fifoWe, clk, reset);
  
  SevenSegment svsg(a, b, c, d, e, f, g, numsl0, numsl1, numsl2, numsl3, clk_raw, 0, tmpData[7:4], tmpData[3:0], CRC[7:4], CRC[3:0]);
  
  initial begin
    clk = 0;
    clkcount = 0;
    clkUARTcount = 0;
    reset = 1;
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
		else begin
			reset = 0;
		end
	end
  
  always @(posedge clk) begin
	
		if(state == 0) begin
			if(isOutStart) begin
				isOutFinish = 0;
				tmpData = outData;
				state = 1;
			end
		end
		else if(state == 1) begin
			isOutFinish = 1;
			state = 15;
		end
		else begin
			state = 0;
			isOutFinish = 1;
			comToFifoEnable = 1;
			fifoToOutEnable = 1;
		end
		flushState = state;
  end

endmodule