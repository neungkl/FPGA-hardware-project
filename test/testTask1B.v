`include "../final/Task1B.v"

module testTask1B(
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
  input pb4_raw,
  input pb5_raw,
  input clk_raw );
  
  wire pb4;
	
	wire t0,t1,t2,t3,t4,t5,t6,t7;
  reg tsent;
  wire trecieve;
  
  reg [16:0] clkcount;
  reg [11:0] clkUARTcount;
  reg clk;
  reg nextval;
  wire clktrigger;
  
  reg [7:0] buff; 
	reg [7:0] flush;
	
	Flush #(8) f1(flush);
  
  assign clktrigger = clkcount[16];
  assign {t0,t1,t2,t3,t4,t5,t6,t7} = buff;
  
  SinglePulser sp(pb4, pb4_raw, clktrigger);
  
  Task1B testModule(a, b, c, d, e, f, g, numsl0, numsl1, numsl2, numsl3, tx, rx, pb5_raw, clk_raw, t0, t1, t2, t3, t4, t5, t6, t7, tsent, trecieve);
  
  reg [2:0] state;
  
  initial begin
    clk = 0;
    clkcount = 0;
    clkUARTcount = 0;
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
		if(pb4) begin
      nextval = 1;
    end
		else begin
      nextval = 0;
		end
	end
  
  always @(posedge clk) begin
    if(state == 0) begin
			buff = 8'h40;
			state = 1;
			tsent = 0;
			flush = tsent;
		end
		else if(state == 1) begin
			if(nextval == 1) begin
				flush = buff;
				tsent = 1;
				state = 2;
			end
    end
    else if(state == 2) begin
      if(trecieve) begin
        tsent = 0;
				state = 3;
			end
		end
		else if(state == 3) begin
			if(nextval == 0) begin
				buff = buff + 1;
				flush = buff;
				state = 1;
			end
    end
    else begin
			state = 0;
    end
		flush = state;
  end
  
endmodule