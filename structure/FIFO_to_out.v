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
  input enable );
  
  reg [2:0] state;
  
  always @(posedge clk) begin
    if(enable) begin
      if(state == 0) begin
        if(fifo_busy == 0 && fifo_empty == 0) begin
          isFinish = 0;
          fifo_re = 1;
					out_data = fifo_data;
          state = 1;
        end
      end
      else if(state == 1) begin
        fifo_re = 0;
        out_start = 1;
        state = 2;
      end
      else if(state == 2) begin
        if(out_finish) begin
          out_start = 0;
          state = 3;
        end
      end
      else begin
        out_start = 0;
        fifo_re = 0;
        isFinish = 1;
				state = 0;
      end
    end
  end
  
endmodule