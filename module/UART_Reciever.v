module UART_Reciever(
  output reg [7:0] data,
  output reg sent,
  output reg [3:0] error,
	input rx,
	input recieved,
  input clk
	);
  
  reg [2:0] index;
  reg [2:0] state;
  
  wire checkBit;
  reg parityEnable;
  reg parityClr;
  wire bitForCheck;
	
	reg [2:0] flush;
	Flush #(3) f1(flush);
  
  assign bitForCheck = rx;
	
  Parity par(checkBit, bitForCheck, clk, parityEnable, parityClr);
  
	initial begin
		error <= 0;
		sent <= 0;
		data <= 0;
		parityEnable <= 0;
		parityClr <= 1;
	end
	
  always @(posedge clk) begin
		case(state)
			0 : begin
				if(rx == 0) begin
					parityClr = 0;
					parityEnable = 1;
					index = 0;
					error = 0;
					sent = 0;
					state = 1;
				end
			end
			1 : begin
				data[index] = rx;
				if(index == 7) begin
					state = 2;
					parityEnable = 0;
				end
				else index = index + 1;
			end
			2 : begin
				parityClr = 1;
				//if(checkBit != rx) error = 1;
				state = 3;
			end
			3 : begin
				if(rx != 1) error = 2;
				state = 4;
			end
			4 : begin
				if(error == 0) begin
					sent = 1;
					state = 5;
				end
				else state = 0;
			end
			5 : begin
				if(recieved) begin
					sent = 0;
					state = 0;
				end
			end
			default : state = 0;
		endcase
		flush = state;
  end
   
endmodule