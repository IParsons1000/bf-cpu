module ram_oneport
#( parameter ADDR_WIDTH = 8,
   parameter DATA_WIDTH = 8,
   parameter MEM_SIZE = 8'd255  )
(  input logic clk,
   input logic [ADDR_WIDTH-1:0] addr,
   input logic enable_w,
   input logic [DATA_WIDTH-1:0] data_i,
   output logic [DATA_WIDTH-1:0] data_o );

logic [DATA_WIDTH-1:0] mem [MEM_SIZE:0];

always_ff @(posedge clk) begin
  if (enable_w) mem[addr] <= data_i;
  data_o <= mem[addr];
end

endmodule
