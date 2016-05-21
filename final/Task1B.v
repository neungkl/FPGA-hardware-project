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
  reg clktrigger;
  
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
	
  wire [7:0] debug;
	
  SinglePulser sp1(.q(pb5), .d(pb5_raw), .clk(clktrigger));
  
  Between_to_FIFO betweenToFifo(
    .isFinish(isBetweenToFifoFinish),
    .CRC(CRC),
    .error(dataError),
    .forSent(fifoDataIn),
    .fifo_we(fifoWe),
    .trecieve(trecieve),
    .t0(t0), .t1(t1), .t2(t2), .t3(t3), .t4(t4), .t5(t5), .t6(t6), .t7(t7),
    .tsent(tsent),
    .fifo_busy(isFifoBusy),
    .clk(clk),
    .enable(betweenToFifoEnable),
    .reset(reset)
  );
  
  FIFO_to_out fifoToOut(
    .isFinish(isFifoToOutFinish), 
    .fifo_re(fifoRe), 
    .out_data(outData), 
    .out_start(isOutStart), 
    .fifo_busy(isFifoBusy), 
    .fifo_empty(isFifoEmpty), 
    .fifo_data(fifoDataOut), 
    .out_finish(isOutToComFinish), 
    .clk(clk), 
    .enable(fifoToOutEnable)
  );
	
	Out_to_com outToCom(
    .isFinish(isOutToComFinish), 
    .tx(tx), 
    .isStart(isOutStart), 
    .data_raw(outData), 
    .clk(clk), 
    .enable(outToComEnable)
  );
	
  FIFO fo(
    .dataIn(fifoDataIn), 
    .dataOut(fifoDataOut), 
    .count(fifoCount), 
    .isEmpty(isFifoEmpty), 
    .isBusy(isFifoBusy), 
    .isFull(isFull), 
    .re(fifoRe), 
    .we(fifoWe), 
    .clk(clk), 
    .reset(reset)
  );
  
  SevenSegment svsg(
		.a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g), 
		.sg0(numsl0), .sg1(numsl1), .sg2(numsl2), .sg3(numsl3), 
		.clk(clk_raw), 
		.mode(4'b1), 
		.num0(outData[7:4]), 
		.num1(outData[3:0]), 
		.num2(CRC[7:4]), 
		.num3(CRC[3:0])
	);
  
  initial begin
    clk <= 0;
    clkcount <= 0;
    clkUARTcount <= 0;
    reset <= 1;
  end
  
  always @(posedge clk_raw) begin
    clkcount <= clkcount + 1;
		clktrigger <= clkcount[16];
    if(clkUARTcount > 1159) begin
      clkUARTcount <= 0;
			clk <= !clk;
    end
		else begin
			clkUARTcount <= clkUARTcount + 1;
		end
  end
	
	always @(posedge clk_raw) begin
		if(clktrigger) begin
			if(pb5) begin
				reset = 1;
			end
			else begin
				reset = 0;
			end
		end
    
    fifoToOutEnable = 1;
    outToComEnable = 1;
    betweenToFifoEnable = 1;
	end

endmodule