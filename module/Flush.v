module Flush(data);
	parameter SIZE = 8;
	input [SIZE-1:0] data;
	
	wire out;
	assign out = |data;
endmodule