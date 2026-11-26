/*
 * 
 * (c)2026 Ira Parsons
 * bf-cpu - a brainf*ck-native cpu
 *
 */

module bf_cpu_tb;

logic clk;

bf_cpu cpu (.clk(clk));

always #10 clk <= ~clk;

initial begin

  clk = 0;

  $finish;

end

endmodule
