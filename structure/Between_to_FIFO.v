module Between_to_FIFO(
  output reg isFinish,
  output [7:0] CRC,
  output [3:0] error,
  output reg [7:0] forSent,
  output reg fifo_we,
  output reg trecieve,
  input t0,
  input t1,
  input t2,
  input t3,
  input t4,
  input t5,
  input t6,
  input t7,
  input tsent,
  input fifo_busy,
  input clk,
  input enable,
  input reset,
	output reg [7:0] debug );
  
  reg [2:0] state;
  reg crcEnable;
  reg crcBit;
  
  reg [2:0] i;
  
  reg [7:0] flush;
	
	Flush #(8) f1(flush);
  
  CRC8 crc(CRC, crcBit, clk, crcEnable, reset);
  
  always @(posedge clk) begin
    if(enable) begin
			case(state)
			0 : begin
				crcEnable = 0;
				fifo_we = 0;
				trecieve = 1;
				isFinish = 1;
				if(tsent == 0) begin
					debug = forSent;
					state = 1;
				end
			end
			1 : begin
				if(tsent == 1) begin
          trecieve = 0;
          i = 7;
          forSent = {t0,t1,t2,t3,t4,t5,t6,t7};
					flush = forSent;
          state = 2;
        end
			end
			2 : begin
				crcBit = forSent[i]; 
				crcEnable = 1;
        if(i == 0) begin
          state = 3;
        end
        else i = i - 1;
			end
			3 : begin
				crcEnable = 0;
        if(!fifo_busy) begin
          fifo_we = 1;
          state = 4;
        end
			end
			4 : begin
				fifo_we = 0;
        state = 5;
			end
			default : state = 0;
			endcase
			
      flush = state;
    end
  end
  
endmodule