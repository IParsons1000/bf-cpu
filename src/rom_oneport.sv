/*
 * 
 * (c)2026 Ira Parsons
 * bf-cpu - a brainf*ck-native cpu
 *
 */

module rom_oneport #(
    parameter ADDR_WIDTH = 16,
    parameter DATA_WIDTH = 8,
    parameter MEM_SIZE   = 16'd65535
) (
    input logic clk,
    input logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] data
);

  logic [DATA_WIDTH-1:0] mem[MEM_SIZE:0];

  initial begin
    $readmemh("rom_image.mem", mem);

    if (addr < MEM_SIZE) data = mem[addr];
  end

  always_ff @(negedge clk) begin
    data <= (addr < MEM_SIZE) ? mem[addr] : 0;
  end

endmodule
