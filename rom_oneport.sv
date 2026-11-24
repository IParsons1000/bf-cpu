module rom_oneport
#( parameter ADDR_WIDTH = 8,
   parameter DATA_WIDTH = 8,
   parameter MEM_SIZE = 8'd255  )
(  input logic clk,
   input logic [ADDR_WIDTH-1:0] addr,
   output logic [DATA_WIDTH-1:0] data );

logic [DATA_WIDTH-1:0] mem [MEM_SIZE:0];

initial begin
  $readmemh("rom_image.mem", mem);

  repeat (2) @(posedge clk);

  if (addr < MEM_SIZE) data = mem[addr];
end

assign data = (addr < MEM_SIZE) ? mem[addr] : 0;

endmodule
