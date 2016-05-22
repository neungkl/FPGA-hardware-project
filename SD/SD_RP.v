module SD_RP(
  input DO,
  input [5:0] cmd,
  output reg isNewResponse,
  output reg [39:0] response,
  input clk,
	input reset );
  
  reg [5:0] i;
  reg [2:0] state;
  
  initial begin
    state = 0;
    response = 0;
  end
  
  always @(posedge clk) begin
		if(reset) begin
			state = 0;
			response = 40'hFFFFFFFFFF;
			isNewResponse = 0;
		end
		else begin
			if(state == 0) begin
				if(!DO) begin
					response = 0;
					case(cmd)
					8 : i = 38;
					default : i = 6;
					endcase
					state = 1;
				end
			end
			else if(state == 1) begin
				response[i] = DO;
				if(i == 0) state = 2;
				else i = i - 1;
			end
			else if(state == 2) begin
				response[39] = !DO;
				isNewResponse = 1;
				state = 0;
			end
			else state = 0;	
		end
    
  end
  
endmodule