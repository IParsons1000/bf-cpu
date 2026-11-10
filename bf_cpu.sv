module bf_cpu
( input logic clk,
  input logic enable );

local parameter ADDR_WIDTH = 8;
local parameter DATA_WIDTH = 8;
local parameter ROM_SIZE = 256;

logic [ADDR_WIDTH-1:0] pc;

logic [DATA_WIDTH-1:0] instr;

rom_oneport #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_SIZE(ROM_SIZE)) rom (.clk(clk), .enable(enable), .addr(pc), .data(instr));

endmodule