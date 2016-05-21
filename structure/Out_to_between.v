module Out_to_between(
  output reg isFinish,
  output t0,
  output t1,
  output t2,
  output t3,
  output t4,
  output t5,
  output t6,
  output t7,
  output reg tsent,
  input trecieve,
  input isStart,
  input [7:0] data,
  input clk );
  
  reg [7:0] forSent;
  reg [2:0] state;
  
  assign {t0,t1,t2,t3,t4,t5,t6,t7} = forSent;
  
  always @(posedge clk) begin
		if(state == 0) begin
      tsent = 0;
      isFinish = 1;
			if(isStart) begin
				state = 1;
				forSent = data;
			end
		end
		else if(state == 1) begin
			isFinish = 0;
			tsent = 1;
			state = 2;
		end
		else if(state == 2) begin
			tsent = 1;
			state = 3;
		end
    else if(state == 3) begin
      if(trecieve) begin
        tsent = 0;
        state = 4;
      end
    end
    else begin
      state = 0;
    end
  end
  
endmodule