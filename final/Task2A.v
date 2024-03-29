`include "../structure/COM_to_FIFO.v"
`include "../module/UART_Reciever.v"
`include "../SD/SD_Write.v"

`include "../structure/FIFO_to_out.v"
`include "../module/FIFO.v"
`include "../module/SinglePulser.v"
`include "../module/SevenSegment.v"
`include "../module/CRC8.v"
`include "../module/Parity.v"
`include "../module/Flush.v"

`include "../final/clockConstant.v"

module Task2A(
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
  input DO,
  output SCLK,
  output DI,
  output CS,
  output L7,
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
  
  wire isComToFifoFinish;
  wire isFifoToOutFinish;
  wire isOutToSDFinish;
  
  wire [3:0] comToFifoError;
  wire [7:0] CRC;
  
  wire [7:0] outData;
  
  wire isOutStart;
  
  reg comToFifoEnable;
  reg fifoToOutEnable;
  
  wire [7:0] fifoDataIn;
  wire [7:0] fifoDataOut;
	
  wire [15:0] debug;
  
  SinglePulser sp1(.q(pb5), .d(pb5_raw), .clk(clktrigger));
  COM_to_FIFO comToFifo(
    .isFinish(isComToFifoFinish), 
    .CRC(CRC), 
    .error(comToFifoError), 
    .fifo_data_out(fifoDataIn), 
    .fifo_we(fifoWe), 
    .tx(tx), 
    .rx(rx), 
    .fifo_busy(isFifoBusy), 
    .clk(clk), 
    .enable(comToFifoEnable), 
    .reset(reset)
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
  FIFO_to_out fifoToOut(
    .isFinish(isFifoToOutFinish), 
    .fifo_re(fifoRe), 
    .out_data(outData), 
    .out_start(isOutStart), 
    .fifo_busy(isFifoBusy), 
    .fifo_empty(isFifoEmpty), 
    .fifo_data(fifoDataOut), 
    .out_finish(isOutToSDFinish), 
    .clk(clk), 
    .enable(fifoToOutEnable)
  );
  
  wire isSDWriteFinish;
  
  SD_Write sdWrite(
    .DO(DO),
    .SCLK(SCLK),
    .DI(DI),
    .CS(CS),
    .isFinish(isSDWriteFinish),
    .foData_raw(outData),
    .foStart(isOutStart),
    .foFinish(isOutToSDFinish),
    .sdInitFinish(L7),
    .clk(clk_raw),
    .reset(reset),
    .debug(debug)
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
  
  initial begin
    clk <= 0;
    clkcount <= 0;
    clkUARTcount <= 0;
    reset <= 1;
  end
  
  always @(posedge clk_raw) begin
    clkcount <= clkcount + 1;
		clktrigger <= clkcount[16];
	end
	
	always @(posedge clk_raw) begin
    if(clkUARTcount > `UART_COUNTER_RATE) begin
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
    comToFifoEnable = 1;
	end

endmodule