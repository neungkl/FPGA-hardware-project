`include "../structure/Out_to_com.v"
`include "../structure/Between_to_FIFO.v"
`include "../SD/SD_Read.v"

`ifdef TASK1_MAIN_MODULE
`else

`include "../structure/FIFO_to_out.v"
`include "../module/FIFO.v"
`include "../module/SinglePulser.v"
`include "../module/SevenSegment.v"
`include "../module/CRC8.v"
`include "../module/Parity.v"
`include "../module/Flush.v"
`include "../final/clockConstant.v"
`define TASK1_MAIN_MODULE 1

`endif

module Task2B(
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
	output L7,
  output tx,
  input pb1_raw,
  input pb5_raw,
  input clk_raw );
  
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
  
  wire [7:0] outData;
  wire [7:0] CRC;
  
  wire isOutStart;
  
  reg fifoToOutEnable;
  reg outToComEnable;
  
  wire [7:0] fifoDataIn;
  wire [7:0] fifoDataOut;
	
  SinglePulser sp1(.q(pb1), .d(pb1_raw), .clk(clktrigger));
  SinglePulser sp2(.q(pb5), .d(pb5_raw), .clk(clktrigger));
  
  wire [15:0] debug;
  
  reg isSDReadStart;
  wire isSDReadFinish;
  wire [15:0] debugRaw;
	
  SD_Read sdRead(
    .DO(DO),
    .SCLK(SCLK),
    .DI(DI),
    .CS(CS),
    .isStart(isSDReadStart),
    .isInitSDFinish(L7),
    .isFinish(isSDReadFinish),
    .foDataSent(fifoDataIn),
    .foWe(fifoWe),
    .foBusy(isFifoBusy),
    .foFull(isFifoFull),
    .clk(clk),
    .reset(reset),
    .debug(debugRaw)
  );
  
  // Between_to_FIFO betweenToFifo(
  //   .isFinish(isBetweenToFifoFinish),
  //   .CRC(CRC),
  //   .error(dataError),
  //   .forSent(fifoDataIn),
  //   .fifo_we(fifoWe),
  //   .trecieve(trecieve),
  //   .t0(t0), .t1(t1), .t2(t2), .t3(t3), .t4(t4), .t5(t5), .t6(t6), .t7(t7),
  //   .tsent(tsent),
  //   .fifo_busy(isFifoBusy),
  //   .clk(clk),
  //   .enable(betweenToFifoEnable),
  //   .reset(reset)
  // );
  
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
		.mode(4'b0), 
		.num0(debug[15:12]), 
		.num1(debug[11:8]), 
		.num2(debug[7:4]), 
		.num3(debug[3:0])
	);
  
  assign debug = { debugRaw[15:0] };
  
  initial begin
    clk <= 0;
    clkcount <= 0;
    clkUARTcount <= 0;
    reset <= 1;
    isSDReadStart <= 0;
  end
  
  always @(posedge clk_raw) begin
    clkcount <= clkcount + 1;
		clktrigger <= clkcount[16];
    if(clkUARTcount >= `UART_COUNTER_RATE) begin
      clkUARTcount <= 0;
			clk <= !clk;
    end
		else begin
			clkUARTcount <= clkUARTcount + 1;
		end
    
    fifoToOutEnable = 1;
    outToComEnable = 1;
  end
	
  always @(posedge clktrigger) begin
    if(pb5) begin
        isSDReadStart = 0;
				reset = 1;
			end
			else begin
				reset = 0;
			end
      
      if(pb1) begin
        isSDReadStart = 1;
      end
      else begin
				if(reset) begin
					isSDReadStart = 0;
				end
      end
  end

endmodule