module SD_CLK_COUNT(
  input clk,
  output reg [2:0] num
);

  initial begin
    num <= 0;
  end

  always @(posedge clk) begin
    num <= num + 1;
  end

endmodule