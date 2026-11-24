module bf_cpu
( input logic clk );

parameter ADDR_WIDTH = 8;
parameter DATA_WIDTH = 8;
parameter ROM_SIZE = 8'd255;
parameter STK_SIZE = 8'd255;
parameter RAM_SIZE = 8'd255;

logic [ADDR_WIDTH-1:0] pc;
logic [ADDR_WIDTH-1:0] mp;
//logic [ADDR_WIDTH-1:0] sp;

logic [DATA_WIDTH-1:0] instr;
logic [DATA_WIDTH-1:0] m_data_i;
logic [DATA_WIDTH-1:0] m_data_o;
logic [DATA_WIDTH-1:0] s_data_i;
logic [DATA_WIDTH-1:0] s_data_o;

logic m_enable_w;
logic s_push;
logic s_pop;
logic s_peek;
logic s_empty;
logic s_full;
logic s_overflow;

logic searching_bracket;

logic eom;

rom_oneport #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_SIZE(ROM_SIZE)) rom (.clk(clk), .addr(pc), .data(instr));
ram_oneport #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_SIZE(RAM_SIZE)) ram (.clk(clk), .addr(mp), .enable_w(m_enable_w), .data_i(m_data_i), .data_o(m_data_o));
fifo_oneport #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_SIZE(STK_SIZE)) stack (.clk(clk), .push(s_push), .pop(s_pop), .peek(s_peek), .data_i(s_data_i), .empty(s_empty), .full(s_full), .data_o(s_data_o));

initial begin

  pc = 0;
  mp = 0;
  //sp = 0;

  instr = 0;
  m_data_o = 0;
  m_data_i = m_data_o;
  s_data_o = 0;
  s_data_i = s_data_o;

  m_enable_w = 0;
  s_push = 0;
  s_pop = s_push;
  s_peek = s_pop;
  s_empty = !s_peek;
  s_full = !s_empty;
  s_overflow = s_full;

  searching_bracket = 0;

  eom = 0;

end

always @(posedge clk && !eom) begin

  $display("Instruction: \'%c\' (%x) / MP = %x / mem = %x", instr, instr, mp, m_data_o);

  if (searching_bracket) begin
    if (instr == "]") searching_bracket <= 0;
  end else begin
    m_enable_w <= (instr == "+" || instr == "-");
    s_push <= (instr == "[" && m_data_o != 0 && !s_full);
    s_pop <= (instr == "]" && m_data_o == 0 && !s_empty);
    s_peek <= (instr == "]" && m_data_o != 0 && !s_empty);

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
          m_data_i <= m_data_o + 1;
        end
      "-":
        begin
          m_data_i <= m_data_o - 1;
        end
      "[":
        begin
          if (m_data_o == 0) begin
            searching_bracket <= 1;
          end else begin
            s_data_i <= pc;
            if (s_full) s_overflow <= 1;
            //push
          end
        end
      "]":
        begin
          if (m_data_o != 0) begin
            if (s_empty) s_overflow <= 1;
            //peek
          end else begin
            if (s_empty) s_overflow <= 1;
            //pop
          end
        end
      ".": $display("Program Output: \'%c\' (%2x)", m_data_o, m_data_o);
      ",": ;
      default: ;
    endcase
  end

  if (instr == 0 || pc == ROM_SIZE || s_overflow) eom <= 1;

end

always @(negedge clk && !eom) begin
  if (s_peek) pc <= s_data_o + 1;
  else pc <= pc + 1;
end

always @(posedge clk && eom) $finish;

endmodule
