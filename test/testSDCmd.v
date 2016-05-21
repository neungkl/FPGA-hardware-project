`include "../SD/SD_CMD.v"

module testSDCmd();

  reg [5:0] index;
  reg [31:0] argument;
  reg isStart;
  reg clk;
	
  wire isBusy, isFinish, DI;
  
  SD_CMD cmd(
    .index(index),
    .argument(argument),
    .isStart(isStart),
    .isBusy(isBusy),
    .isFinish(isFinish),
		.DI(DI),
    .clk(clk)
  );
  
  reg [2:0] state;
  
  initial begin
    
    state = 0;
    clk = 0;
		
    #20;
    // Edit index & argument then check CRC
    index = 6'h77;
    argument = 0;
    isStart = 1;
    
		#50000 $finish;
  end
  
  always begin
    #5 clk = !clk;
  end
  
  always @(posedge clk) begin
    if(isFinish) begin
			isStart = 0;
    end else if(!isStart) begin
			isStart = 1;
		end
  end
  
endmodule