module Out_to_com(
  output reg isFinish,
  output reg tx,
  input isStart,
  input [7:0] data,
  input clk,
  input enable,
	output reg [7:0] debug );
  
  reg [2:0] state;
  wire parBit;
  reg parEnable;
  reg parReset;
  
  reg [2:0] i;
	
  Parity par(parbit, tx, clk, parEnable, parReset);
  
  always @(posedge clk) begin
    if(enable) begin
      if(state == 0) begin
        if(isStart) begin
          isFinish = 0;
          parReset = 0;
					debug = data;
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
        parEnable = 1;
        if(i == 7) begin
          state = 3;
        end
        else i = i + 1;
      end
      else if(state == 3) begin
        parEnable = 0;
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
        parReset = 1;
        parEnable = 0;
      end
    end
  end
  
endmodule