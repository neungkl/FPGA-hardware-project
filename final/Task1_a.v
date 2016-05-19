`include "../structure/COM_to_FIFO.v"
`include "../structure/FIFO_to_out.v"
`include "../structure/Out_to_between.v"
`include "../module/FIFO.v"
`include "../module/SinglePulser.v"
`include "../module/SevenSegment.v"
`include "../module/CRC8.v"
`include "../module/Parity.v"
`include "../module/UART_Reciever.v"
`include "../module/Flush.v"

module Task1_a(
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
  output t0,
  output t1,
  output t2,
  output t3,
  output t4,
  output t5,
  output t6,
  output t7,
  output tsent,
  input trecieve );
  
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
  
  wire isComToFifoFinish;
  wire isFifoToOutFinish;
  wire isOutToBeetweenFinish;
  
  wire [3:0] comToFifoError;
  wire [7:0] CRC;
  
  wire [7:0] outData;
  
  wire isOutStart;
  
  reg comToFifoEnable;
  reg fifoToOutEnable;
  
  wire [7:0] fifoDataIn;
  wire [7:0] fifoDataOut;
  
  assign clktrigger = clkcount[16];
	
  wire [7:0] debug;
  
  SinglePulser sp1(pb5, pb5_raw, clktrigger);
  COM_to_FIFO comToFifo(
    isComToFifoFinish, 
    CRC, 
    comToFifoError, 
    fifoDataIn, 
    fifoWe, 
    tx, 
    rx, 
    isFifoBusy, 
    clk, 
    comToFifoEnable, 
    reset
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
  FIFO_to_out fifoToOut(
    isFifoToOutFinish, 
    fifoRe, 
    outData, 
    isOutStart, 
    isFifoBusy, 
    isFifoEmpty, 
    fifoDataOut, 
    isOutToBeetweenFinish, 
    clk, 
    fifoToOutEnable
  );
  Out_to_between outToBetween(
    isOutToBeetweenFinish, 
    t0, t1, t2, t3, t4, t5, t6, t7,
    tsent,
    trecieve,
    isOutStart,
    outData,
    clk
  );
  
  SevenSegment svsg(a, b, c, d, e, f, g, numsl0, numsl1, numsl2, numsl3, clk_raw, 0, outData[7:4], outData[3:0], CRC[7:4], CRC[3:0]);
  
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
		if(pb5) begin
			reset = 1;
		end
		else begin
			reset = 0;
		end
    
    fifoToOutEnable = 1;
    comToFifoEnable = 1;
	end

endmodule