module SinglePulser(
	output reg q,
	input d,
	input wire clk
);

reg prev;

initial begin
	prev = 0;
end
	 
always @(posedge clk) begin
	if(d == 1 && prev == 0) q <= 1;
	else q <= 0;
	prev <= d;
end


endmodule
