module testClock(output pk, input clk);

  reg [9:0] count;
  
  assign pk = count[2]; 

  initial begin
    count = 0;
  end

  always @(posedge clk) begin
    count = count + 1;
  end

endmodule