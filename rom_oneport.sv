module rom_oneport
#( parameter ADDR_WIDTH = 8,
   parameter DATA_WIDTH = 8,
   parameter MEM_SIZE = 256  )
(  input logic clk,
   input logic enable,
   input logic [ADDR_WIDTH-1:0] addr,
   output logic [DATA_WIDTH-1:0] data );

logic [DATA_WIDTH-1:0] mem [MEM_SIZE-1:0];
logic [DATA_WIDTH-1:0] temp;

initial begin
  $readmemh("rom_image.mem", mem);
end

always @(posedge clk) begin
  if (enable) temp <= mem[addr];
end

assign data = temp;

endmodule