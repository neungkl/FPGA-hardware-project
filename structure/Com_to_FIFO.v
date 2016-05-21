module COM_to_FIFO(
  output reg isFinish,
  output [7:0] CRC,
  output [3:0] error,
  output reg [7:0] fifo_data_out,
  output reg fifo_we,
  output tx,
  input rx,
  input fifo_busy,
  input clk,
  input enable,
  input reset,
	output reg [2:0] state );
  
	wire [7:0] fifo_data;
  wire isGetSending;
  reg isGetRecieved;
  reg crcEnable;
  reg crcBit;
  
  reg [2:0] i;
  
  assign tx = rx;
  
  UART_Reciever uartrc(fifo_data, isGetSending, error, rx, isGetRecieved, clk);
  CRC8 crc(CRC, crcBit, clk, crcEnable, reset);
  
  always @(posedge clk) begin
    if(enable) begin
      if(state == 0) begin
        if(isGetSending == 1) begin
					isFinish = 0;
          fifo_data_out = fifo_data;
          isGetRecieved = 1;
          state = 1;
        end
      end
      else if(state == 1) begin
        if(isGetSending == 0) begin
          isGetRecieved = 0;
          state = 2;
        end
      end
      else if(state == 2) begin
        if(fifo_busy == 0) begin
          fifo_we = 1;
          state = 3;
        end
      end
      else if(state == 3) begin
        fifo_we = 0;
        i = 7;
        state = 4;
      end
      else if(state == 4) begin
        crcBit = fifo_data_out[i];
				crcEnable = 1;
        if(i == 0) begin
          state = 5;
        end
        else i = i - 1;
      end
      else begin
				isFinish = 1;
        state = 0;
        fifo_we = 0;
        crcEnable = 0;
      end
    end
  end
  
endmodule