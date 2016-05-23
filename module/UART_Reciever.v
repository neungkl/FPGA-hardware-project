module UART_Reciever(
  output reg [7:0] data,
  output reg sent,
  output reg [3:0] error,
	input rx,
	input recieved,
  input clk );
  
  reg [2:0] index;
  reg [2:0] state;
	reg [2:0] state2;
	
  wire checkBit;
	
	assign checkBit = ^data;
  
	initial begin
		error = 0;
		sent = 0;
		data = 0;
		state = 0;
	end
	
	always @(posedge clk) begin
		if(sent == 0) begin
			if(state == 3 && error == 0) begin
				sent <= 1;
			end
		end
		else begin
			if(recieved) begin
				sent <= 0;
			end
		end
	end
	
  always @(posedge clk) begin
		if(state == 0) begin
			if(rx == 0) begin
				index = 0;
				error = 0;
				state = 1;
			end
		end
		else if(state == 1) begin
			data[index] = rx;
			if(index == 7) begin
				state = 2;
			end
			else index = index + 1;
		end
		else if(state == 2) begin
			if(checkBit != rx) error = 1;
			state = 3;
		end
		else if(state == 3) begin
			if(rx != 1) error = 2;
			state = 0;
		end
		else state = 0;
  end
   
endmodule