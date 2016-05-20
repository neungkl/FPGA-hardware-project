module CRC8(CRC, BITVAL, BITSTRB, ENABLE, CLEAR);
   input        BITVAL;                            // Next input bit
   input        BITSTRB;                           // Current bit valid (Clock)
   input        CLEAR;                             // Init CRC value
   input 		 		ENABLE;
   output [7:0] CRC;                               // Current output CRC value

   reg    [7:0] CRC;                               // We need output registers
   wire         inv;
   
   assign inv = BITVAL ^ CRC[7];                   // XOR required?
	 
	 initial begin
			CRC = 0;
	 end
   
   always @(posedge BITSTRB or posedge CLEAR) begin
      if (CLEAR) begin
         CRC = 0;                                  // Init before calculation
         end
      else if(ENABLE) begin
         CRC[7] = CRC[6];
         CRC[6] = CRC[5];
         CRC[5] = CRC[4];
         CRC[4] = CRC[3];
         CRC[3] = CRC[2];
         CRC[2] = CRC[1] ^ inv;
         CRC[1] = CRC[0] ^ inv;
         CRC[0] = inv;
      end
end
   
endmodule