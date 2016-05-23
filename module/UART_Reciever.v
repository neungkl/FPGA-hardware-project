module UART_Reciever(
  output reg [7:0] data,
  output reg sent,
  output reg [3:0] error,
	input rx,
	input recieved,
  input clk );
  
  reg [2:0] index;
	
  wire checkBit;
	reg [10:0] data_raw;
	
	assign checkBit = ^data;
  
	initial begin
		error = 0;
		sent = 0;
		data_raw = 11'h7FF;
	end
	
  always @(negedge clk) begin
		
		data_raw = data_raw << 1;
		data_raw[0] = rx;
		
		if(sent) begin
			if(recieved) begin
				sent = 0;
			end
		end
		
		if(data_raw[10] == 0) begin
			
			error = 0;
			data = {data_raw[2], data_raw[3], data_raw[4], data_raw[5], data_raw[6], data_raw[7], data_raw[8], data_raw[9]};
			
			if(data_raw[1] != checkBit) error = 1;
			else if(data_raw[0] != 1) error = 2;
			
			if(error == 0) begin
				sent = 1;
			end
			
			data_raw = 11'h7FF;
		end
		
  end
   
endmodule