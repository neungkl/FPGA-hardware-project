`include "../module/SinglePulser.v"
`include "../module/SevenSegment.v"

module testSegment(
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
  input clk,
  input dp1_raw);
  
wire dp1;
reg [3:0] num;

reg [9:0] clkcount;
wire clktrigger;

assign clktrigger = clkcount[9];

initial begin
  num = 0;
  clkcount = 0;
end

SinglePulser sp1(dp1, dp1_raw, clktrigger);
SevenSegment svseg(a,b,c,d,e,f,g,numsl0,numsl1,numsl2,numsl3,clk,0,4,3,2,num);

always @(posedge clk) begin
	clkcount = clkcount + 1;
end

always @(posedge clktrigger) begin
  if(dp1) begin
    num = num + 1;
  end
end

endmodule