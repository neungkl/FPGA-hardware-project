`include "../final/Task1B.v"
`include "../final/Task1A.v"

module testTask1AB(
  output a,
  output b,
  output c,
  output d,
  output e,
  output f,
  output g,
  output numsl0,
  output numsl1,
  output numsl2,
  output numsl3,
  output tx,
  input rx,
  input pb5_raw,
  input clk_raw );
  
  Task1A tA(
		.rx(rx),
		.pb5_raw(pb5_raw),
		.clk_raw(clk_raw),
		.t0(t0),
		.t1(t1),
		.t2(t2),
		.t3(t3),
		.t4(t4),
		.t5(t5),
		.t6(t6),
		.t7(t7),
		.tsent(tsent),
		.trecieve(trecieve) 
	);
  Task1B tB(
   .a(a),
   .b(b),
   .c(c),
   .d(d),
   .e(e),
   .f(f),
   .g(g),
   .numsl0(numsl0),
   .numsl1(numsl1),
   .numsl2(numsl2),
   .numsl3(numsl3),
   .tx(tx),
   .pb5_raw(pb5_raw),
   .clk_raw(clk_raw),
   .t0(t0),
   .t1(t1),
   .t2(t2),
   .t3(t3),
   .t4(t4),
   .t5(t5),
   .t6(t6),
   .t7(t7),
   .tsent(tsent),
   .trecieve(trecieve)
  );
  
endmodule