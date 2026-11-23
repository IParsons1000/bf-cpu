module bf_cpu_tb;

logic clk;

bf_cpu cpu (.clk(clk));

always #10 clk <= ~clk;

initial begin

  clk = 0;

  //$finish;

end

endmodule
