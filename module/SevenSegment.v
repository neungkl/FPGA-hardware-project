module SevenSegment(
	output a,
	output b,
	output c,
	output d,
	output e,
	output f,
	output g,
	output sg0,
	output sg1,
	output sg2,
	output sg3,
	input clk,
  input [3:0] mode,
  input [3:0] num0,
  input [3:0] num1,
  input [3:0] num2,
  input [3:0] num3
  );

reg [16:0] count;
reg [3:0] state;
reg [4:0] num;
reg clks;

reg [6:0] buff;

assign {a,b,c,d,e,f,g} = buff;
assign {sg3,sg2,sg1,sg0} = state;

initial begin
  count = 0;
	num = 0;
end

always @(posedge clk) begin
  count <= count + 1;
	clks <= count[16];
end

always @(posedge clks) begin
  
	if(mode == 0) begin
		case(state)
		4'b0111 : begin
			state = 4'b1011;
			num = num1;
		end
		4'b1011 : begin
			state = 4'b1101;
			num = num2;
		end
		4'b1101 : begin
			state = 4'b1110;
			num = num3;
		end
		4'b1110 : begin
			state = 4'b0111;
			num = num0;
		end
		default : state = 4'b0111;
		endcase
	end
	else if(mode == 1) begin
		case(state)
		4'b1110 : begin
			state = 4'b1101;
			num = num2;
		end
		4'b1101 : begin
			state = 4'b1110;
			num = num3;
		end
		default : state = 4'b1110;
		endcase
	end
	else if(mode == 2) begin
		case(state)
		4'b0111 : begin
		 state = 4'b1011;
		 num = 14;
		end
		4'b1011 : begin
		 state = 4'b1101;
		 num = 16;
		end
		4'b1101 : begin
		 state = 4'b1110;
		 num = 16;
		end
		4'b1110 : begin
		 num = num3;
		end
		endcase
	end
	
	case(num)
	0 : buff = 7'b1111110;
	1 : buff = 7'b0110000;
	2 : buff = 7'b1101101;
	3 : buff = 7'b1111001;
	4 : buff = 7'b0110011;
	5 : buff = 7'b1011011;
	6 : buff = 7'b1011111;
	7 : buff = 7'b1110000;
	8 : buff = 7'b1111111;
	9 : buff = 7'b1111011;
	10 : buff = 7'b1110111;
	11 : buff = 7'b0011111;
	12 : buff = 7'b1001110;
	13 : buff = 7'b0111101;
	14 : buff = 7'b1001111;
	15 : buff = 7'b1000111;
	16 : buff = 7'b0000101; //r
	default : buff = 7'b0110111;
	endcase
end

endmodule