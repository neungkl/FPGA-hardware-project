`include "../structure/Out_to_com.v"
`include "../structure/FIFO_to_out.v"
`include "../structure/Between_to_FIFO.v"
`include "../module/FIFO.v"
`include "../module/SinglePulser.v"
`include "../module/SevenSegment.v"
`include "../module/Flush.v"
`include "../module/Parity.v"
`include "../module/CRC8.v"

module Task1B(
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
  input pb5_raw,
  input clk_raw,
  input t0,
  input t1,
  input t2,
  input t3,
  input t4,
  input t5,
  input t6,
  input t7,
  input tsent,
  output trecieve );
  
  wire pb5;
  
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
  
  wire isFifoToOutFinish;
  wire isOutToComFinish;
  wire isBetweenToFifoFinish;
  
  wire [7:0] outData;
  wire [7:0] CRC;
  wire [3:0] dataError;
  
  wire isOutStart;
  
  reg fifoToOutEnable;
  reg outToComEnable;
  reg betweenToFifoEnable;
  
  wire [7:0] fifoDataIn;
  wire [7:0] fifoDataOut;
  
  assign clktrigger = clkcount[16];
	
  wire [7:0] debug;
	
  SinglePulser sp1(pb5, pb5_raw, clktrigger);
  
  Between_to_FIFO betweenToFifo(
    isBetweenToFifoFinish,
    CRC,
    dataError,
    fifoDataIn,
    fifoWe,
    trecieve,
    t0, t1, t2, t3, t4, t5, t6, t7,
    tsent,
    isFifoBusy,
    clk,
    betweenToFifoEnable,
    reset,
		debug
  );
  
  FIFO_to_out fifoToOut(
    isFifoToOutFinish, 
    fifoRe, 
    outData, 
    isOutStart, 
    isFifoBusy, 
    isFifoEmpty, 
    fifoDataOut, 
    isOutToComFinish, 
    clk, 
    fifoToOutEnable
  );
  FIFO fo(
    fifoDataIn, 
    fifoDataOut, 
    fifoCount, 
    isFifoEmpty, 
    isFifoBusy, 
    isFull, 
    fifoRe, 
    fifoWe, 
    clk, 
    reset
  );
  Out_to_com outToCom(
    isOutToComFinish, 
    tx, 
    isOutStart, 
    outData, 
    clk, 
    outToComEnable
  );
  
  SevenSegment svsg(a, b, c, d, e, f, g, numsl0, numsl1, numsl2, numsl3, clk_raw, 0, debug[7:4], debug[3:0], CRC[7:4], CRC[3:0]);
  
  initial begin
    clk = 0;
    clkcount = 0;
    clkUARTcount = 0;
    reset = 1;
  end
  
  always @(posedge clk_raw) begin
    clkcount = clkcount + 1;
		clkUARTcount = clkUARTcount + 1;
    if(clkUARTcount > 1302) begin
      clkUARTcount = 0;
			clk = !clk;
    end
  end
	
	always @(posedge clktrigger) begin
		if(pb5) begin
			reset = 1;
		end
		else begin
			reset = 0;
		end
    
    fifoToOutEnable = 1;
    outToComEnable = 1;
    betweenToFifoEnable = 1;
	end

endmodule