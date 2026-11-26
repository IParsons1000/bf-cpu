module fifo_oneport
#( parameter ADDR_WIDTH = 16,
   parameter DATA_WIDTH = 16,
   parameter MEM_SIZE = 16'd65535  )
(  input logic clk,
   input logic push,
   input logic pop,
   input logic peek,
   input logic [DATA_WIDTH-1:0] data_i,
   output logic empty,
   output logic full,
   output logic [DATA_WIDTH-1:0] data_o );

logic [DATA_WIDTH-1:0] mem [MEM_SIZE:0];
logic [ADDR_WIDTH-1:0] top;
logic dirty_push;
logic dirty_pop;

initial begin
  top = 0;
  dirty_push = 0;
  dirty_pop = 0;
  data_o = 0;
end

assign empty = top == 0;
assign full = top == MEM_SIZE;

always_ff @(negedge clk) begin

  dirty_push <= (push && !full);
  dirty_pop <= (pop && !empty);

  if (push && !full) begin
    mem[top] <= data_i;
  end else if ((pop || peek) && !empty) begin
    data_o <= mem[top-1];
  end
end

always_ff @(dirty_push or dirty_pop) begin
  if (dirty_push) begin
    if (!full) top <= top + 1;
  end else if (dirty_pop) begin
    if (!empty) top <= top - 1;
  end
end

endmodule
