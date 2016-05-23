module Out_to_com(
  output reg isFinish,
  output reg tx,
  input isStart,
  input [7:0] data_raw,
  input clk,
  input enable );
  
  reg [2:0] state;
  wire parBit;
	
	reg [7:0] data;
  
  reg [2:0] i;
	
  assign parBit = ^data;
	
	initial begin
		state <= 0;
	end
  
  always @(posedge clk) begin
    if(enable) begin
      if(state == 0) begin
        isFinish = 1;
        if(isStart) begin
          isFinish = 0;
					data = data_raw;
          state = 1;
        end
      end
      else if(state == 1) begin
        tx = 0;
        state = 2;        
        i = 0;
      end
      else if(state == 2) begin
        tx = data[i];
        if(i == 7) begin
          state = 3;
        end
        else i = i + 1;
      end
      else if(state == 3) begin
        tx = parBit;
        state = 4;
      end
      else if(state == 4) begin
        tx = 1;
        state = 5;
      end
      else begin
        tx = 1;
				isFinish = 1;
        state = 0;
      end
    end
  end
  
endmodule