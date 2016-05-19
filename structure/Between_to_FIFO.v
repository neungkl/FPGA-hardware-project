module Between_to_FIFO(
  output reg isFinish,
  output [7:0] CRC,
  output [3:0] error,
  output [7:0] fifo_data_con,
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
  input reset );
  
  reg [2:0] state;
  reg crcEnable;
  reg crcBit;
  
  reg [2:0] i;
  
  reg [7:0] forSent;
  
  assign fifo_data_con = fifo_we ? forSent : 8'bZ;
  
  CRC8 crc(CRC, crcBit, clk, crcEnable, reset);
  
  always @(posedge clk) begin
    if(enable) begin
      if(state == 0) begin
        if(tsent == 1) begin
          trecieve <= 0;
          i <= 7;
          forSent <= {t7,t6,t5,t4,t3,t2,t1,t0};
          crcEnable <= 1;
          state <= 1;
        end
      end
      else if(state == 1) begin
        crcBit = forSent[i]; 
        if(i == 0) begin
          crcEnable = 0;
          state = 2;
        end
        else i = i - 1;
      end
      else if(state == 2) begin
        if(!fifo_busy) begin
          fifo_we <= 1;
          state <= 3;
        end
      end
      else if(state == 3) begin
        fifo_we <= 0;
        state <= 4;
      end
      else begin
        crcEnable <= 0;
        fifo_we <= 0;
        trecieve <= 1;
        isFinish <= 1;
      end
    end
  end
  
endmodule