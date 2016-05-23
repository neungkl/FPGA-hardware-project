module UART_Reciever(
  output reg [7:0] data,
  output reg sent,
  output reg [3:0] error,
	input rx,
	input recieved,
  input clk );
  
  reg [2:0] index;
	
  wire checkBit;
	reg [9:0] data_raw;
	reg isNewData;
	
	assign checkBit = ^data_raw[8:1];
  
	initial begin
		error = 0;
		sent = 0;
		data_raw = 10'h3FF;
		isNewData = 0;
	end
	
	always @(posedge clk) begin
		if(sent == 0) begin
			if(isNewData && error == 0) begin
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
		
		data_raw = data_raw << 1;
		data_raw[0] = rx;
		
		if(data_raw[9] == 0) begin
			if(data[1] != checkBit) error = 1;
			else if(data[0] != 1) error = 2;
			
			isNewData = 1;
			data = data_raw[8:1];
		end
		
		if(recieved) begin
			isNewData = 0;
		end
		
  end
   
endmodule