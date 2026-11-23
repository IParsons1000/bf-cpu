module fifo_oneport_tb;

parameter ADDR_WIDTH = 8;
parameter DATA_WIDTH = 8;
parameter MEM_SIZE = 8'd255;

logic clk;
logic push;
logic pop;
logic empty;
logic full;
logic [DATA_WIDTH-1:0] test_mem [MEM_SIZE:0];
logic [DATA_WIDTH-1:0] test_data_i;
logic [DATA_WIDTH-1:0] test_data_o;
integer i;
integer r;

fifo_oneport #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_SIZE(MEM_SIZE)) fifo (.clk(clk), .push(push), .pop(pop), .data_i(test_data_i), .empty(empty), .full(full), .data_o(test_data_o));

always #10 clk <= ~clk;

initial begin

  clk = 0;
  push = 0;
  pop = 0;
  empty = 0;
  full = 0;
  test_data_i = 0;
  test_data_o = 0;
  r = 0;
  i = r; // need to use all bits of r somewhere

  for (i = 0; i <= MEM_SIZE; i = i + 1) begin
    @(posedge clk);
    r = $random;
    test_data_i = r[DATA_WIDTH-1:0];
    test_mem[i] = test_data_i;
    push = 1;
    @(negedge clk);
    push = 0;
  end

  repeat (2) @ (posedge clk);

  assert (full);

  for (; i >= 0; i = i - 1) begin
    @(posedge clk);
    $display("Testing %x (%2x)", test_addr, test_mem[test_addr]);
    pop = 1;
    assert (test_data_o == test_mem[i]);
    @(negedge clk);
    pop = 0;
  end

  assert (empty);

  $finish;

end

endmodule
