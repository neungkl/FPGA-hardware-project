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
  
	wire a1,b1,c1,d1,e1,f1,g1;
  wire a2,b2,c2,d2,e2,f2,g2;
  
  assign a = (!numsl2 || !numsl3) ? a1 : a2;
  assign b = (!numsl2 || !numsl3) ? b1 : b2;
  assign c = (!numsl2 || !numsl3) ? c1 : c2;
  assign d = (!numsl2 || !numsl3) ? d1 : d2;
  assign e = (!numsl2 || !numsl3) ? e1 : e2;
  assign f = (!numsl2 || !numsl3) ? f1 : f2;
  assign g = (!numsl2 || !numsl3) ? g1 : g2;
	
  Task1A tA(
		.a(a1),
		.b(b1),
		.c(c1),
		.d(d1),
		.e(e1),
		.f(f1),
		.g(g1),
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
   .a(a2),
   .b(b2),
   .c(c2),
   .d(d2),
   .e(e2),
   .f(f2),
   .g(g2),
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