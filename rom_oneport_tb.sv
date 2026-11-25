module rom_oneport_tb;

parameter ADDR_WIDTH = 16;
parameter DATA_WIDTH = 8;
parameter MEM_SIZE = 16'd65535;

logic clk;
logic [ADDR_WIDTH-1:0] test_addr;
logic [DATA_WIDTH-1:0] test_mem [MEM_SIZE:0];
logic [DATA_WIDTH-1:0] test_data;
integer i;

rom_oneport #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_SIZE(MEM_SIZE)) rom (.clk(clk), .addr(test_addr), .data(test_data));

always #10 clk <= ~clk;

initial begin

  clk = 0;
  test_addr = 0;
  test_data = 0;
  i = 0;

  $readmemh("rom_image.mem", test_mem);

  for (i = 0; i <= MEM_SIZE; i = i + 1) begin
    @(posedge clk);
    $display("Testing %4x (%2x)", test_addr, test_mem[test_addr]);
    assert (test_data == test_mem[test_addr]);
    @(negedge clk);
    test_addr = test_addr + 1;
  end

  $finish;

end

endmodule
