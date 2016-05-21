`include "../SD/SD_Initial.v"
`include "../module/SevenSegment.v"
`include "../module/SinglePulser.v"

module testSDInit(
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
  input DO,
  output SCLK,
  output DI,
  output CS,
  input pb1_raw,
  input clk_raw );
  
  wire [15:0] debug;
  
  reg [16:0] clkcount;
  reg clktrigger;
  wire pb1;
  
  reg [3:0] checkStart;
  reg isInitStart;
  
  SD_Initial sdinit(
    .DO(DO),
    .SCLK(SCLK),
    .DI(DI),
    .CS(CS),
    .clk(clk_raw),
    .isStart(isInitStart),
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
  
  SinglePulser sp1(.q(pb1), .d(pb1_raw), .clk(clktrigger));
  
	reg [2:0] state;
	
  initial begin
    isInitStart = 0;
    clkcount = 0;
    checkStart = 0;
		state = 0;
  end
  
  always @(posedge clk_raw) begin
    clkcount = clkcount + 1;
    clktrigger = clkcount[16];
  end
  
  always @(posedge clktrigger) begin
		if(state == 0) begin
			if(pb1) state = 1;
		end
		else if(state == 1) begin
			if(pb1) begin
				isInitStart = 1;
				checkStart = 14;
			end
		end
		else state = 0;
  end
  
endmodule