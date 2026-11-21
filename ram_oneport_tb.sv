module ram_oneport_tb;

parameter ADDR_WIDTH = 8;
parameter DATA_WIDTH = 8;
parameter MEM_SIZE = 8'd255;

logic clk;
logic enable_w;
logic [ADDR_WIDTH-1:0] test_addr;
logic [DATA_WIDTH-1:0] test_mem [MEM_SIZE:0];
logic [DATA_WIDTH-1:0] test_data;
integer i;
integer r;

ram_oneport #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_SIZE(MEM_SIZE)) ram (.clk(clk), .addr(test_addr), .enable_w(enable_w), .data_i(test_data), .data_o(test_data));

always #10 clk <= ~clk;

initial begin

  clk = 0;
  enable_w = 0;
  test_addr = 0;
  test_data = 0;
  r = 0;
  i = r; // need to use all bits of r somewhere

  for (i = 0; i <= MEM_SIZE; i = i + 1) begin
    @(posedge clk);
    r = $random;
    test_data = r[DATA_WIDTH-1:0];
    test_mem[test_addr] = test_data;
    enable_w = 1;
    @(negedge clk);
    enable_w = 0;
    test_addr = test_addr + 1;
  end

  repeat (2) @ (posedge clk);

  for (; i >= 0; i = i - 1) begin
    @(posedge clk);
    $display("Testing %x (%2x)", test_addr, test_mem[test_addr]);
    assert (test_data == test_mem[test_addr]);
    @(negedge clk);
    test_addr = test_addr - 1;
  end

  $finish;

end

endmodule
