module bf_cpu_tb;

logic clk;

bf_cpu cpu (.clk(clk));

initial begin

  clk = 0;

  $finish;

end

endmodule
