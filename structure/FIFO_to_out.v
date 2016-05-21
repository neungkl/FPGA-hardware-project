module FIFO_to_out(
  output reg isFinish,
  output reg fifo_re,
  output reg [7:0] out_data,
  output reg out_start,
  input fifo_busy,
  input fifo_empty,
  input [7:0] fifo_data,
  input out_finish,
  input clk,
  input enable,
	output reg [2:0] state );
  
  always @(posedge clk) begin
    if(enable) begin
			if(state == 0) begin
				fifo_re = 0;
        isFinish = 1;			
				state = 3'o1;
			end
      if(state == 1) begin
				if(fifo_busy == 0 && fifo_empty == 0 && out_finish) begin
					isFinish = 0;
					fifo_re = 1;
					out_data = fifo_data;
					state = 3'o2;        
				end
      end
      else if(state == 2) begin
        fifo_re = 0;
        out_start = 1;
        state = 3'o3;
      end
      else if(state == 3) begin
        if(out_finish) begin
          out_start = 0;
          state = 3'o4;
        end
      end
      else begin
				state = 3'o0;
      end
    end
  end
  
endmodule