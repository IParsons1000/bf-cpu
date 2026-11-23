module fifo_oneport
#( parameter ADDR_WIDTH = 8,
   parameter DATA_WIDTH = 8,
   parameter MEM_SIZE = 8'd255  )
(  input logic clk,
   input logic push,
   input logic pop,
   input logic [DATA_WIDTH-1:0] data_i,
   output logic empty,
   output logic full,
   output logic [DATA_WIDTH-1:0] data_o );

logic [DATA_WIDTH-1:0] mem [MEM_SIZE:0];
logic [ADDR_WIDTH-1:0] top;

initial begin
  top <= 0;
  data_o <= 0;
end

assign empty = top == 0;
assign full = top == MEM_SIZE-1;

always @(posedge clk) begin
  if (push && !full) begin
    mem[top] <= data_i;
  end else if (pop && !empty) begin
    data_o <= mem[top-1];
  end
end

always @(negedge clk) begin
  if (push && !full) top <= top + 1;
  else if (pop && !empty) top <= top - 1;
end

endmodule
