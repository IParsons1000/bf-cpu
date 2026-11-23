module bf_cpu
( input logic clk );

parameter ADDR_WIDTH = 8;
parameter DATA_WIDTH = 8;
parameter ROM_SIZE = 8'd255;
parameter STK_SIZE = 8'd255;
parameter RAM_SIZE = 8'd255;

logic [ADDR_WIDTH-1:0] pc;
logic [ADDR_WIDTH-1:0] mp;
logic [ADDR_WIDTH-1:0] sp;

logic [DATA_WIDTH-1:0] instr;
logic [DATA_WIDTH-1:0] m_data_i;
logic [DATA_WIDTH-1:0] m_data_o;
logic [DATA_WIDTH-1:0] s_data_i;
logic [DATA_WIDTH-1:0] s_data_o;

logic m_enable_w;
logic s_enable_w;

logic eom;

rom_oneport #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_SIZE(ROM_SIZE)) rom (.clk(clk), .addr(pc), .data(instr));
ram_oneport #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_SIZE(RAM_SIZE)) ram (.clk(clk), .addr(mp), .enable_w(m_enable_w), .data_i(m_data_i), .data_o(m_data_o));
ram_oneport #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_SIZE(STK_SIZE)) stack (.clk(clk), .addr(sp), .enable_w(s_enable_w), .data_i(s_data_i), .data_o(s_data_o));

initial begin

  pc = 0;
  mp = 0;
  sp = 0;

  instr = 0;
  m_data_i = 0;
  m_data_o = 0;
  s_data_i = 0;
  s_data_o = 0;

  m_enable_w = 0;
  s_enable_w = 0;

  eom = 0;

end

always @(posedge clk && !eom) begin

  m_enable_w = 0;

  case (instr)
    ">":
      begin
        if (mp == (RAM_SIZE-1))
          mp <= 0;
        else
          mp <= mp + 1;
      end
    "<":
      begin
        if (mp == 0)
          mp <= RAM_SIZE - 1;
        else
          mp <= mp - 1;
      end
    "+":
      begin
        m_data_o = m_data_i + 1;
        m_enable_w = 1;
      end
    "-":
      begin
        m_data_o = m_data_i - 1;
        m_enable_w = 1;
      end
    default: ;
  endcase

end

always @(negedge clk) begin

  if (pc == ROM_SIZE) begin
    eom <= 1;
  end else begin
    pc <= pc + 1;
  end

end

endmodule
