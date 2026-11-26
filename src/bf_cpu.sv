/*
 *
 * (c)2026 Ira Parsons
 * bf-cpu - a brainf*ck-native cpu
 *
 */

module bf_cpu (
    input logic clk
);

  parameter ADDR_WIDTH = 16;
  parameter DATA_WIDTH = 8;
  parameter ROM_SIZE   = 16'd65535;
  parameter STK_SIZE   = 16'd65535;
  parameter RAM_SIZE   = 16'd65535;

  logic [ADDR_WIDTH-1:0] pc;
  logic [ADDR_WIDTH-1:0] mp;

  logic [DATA_WIDTH-1:0] instr;
  logic [DATA_WIDTH-1:0] m_data_i;
  logic [DATA_WIDTH-1:0] m_data_o;
  logic [ADDR_WIDTH-1:0] s_data_i;
  logic [ADDR_WIDTH-1:0] s_data_o;

  logic m_enable_w;
  logic s_push;
  logic s_pop;
  logic s_peek;
  logic s_empty;
  logic s_full;
  logic s_overflow;

  logic [ADDR_WIDTH-1:0] searching_bracket;

  integer stdin;

  rom_oneport #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH),
      .MEM_SIZE  (ROM_SIZE)
  ) rom (
      .clk (clk),
      .addr(pc),
      .data(instr)
  );
  ram_oneport #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH),
      .MEM_SIZE  (RAM_SIZE)
  ) ram (
      .clk(clk),
      .addr(mp),
      .enable_w(m_enable_w),
      .data_i(m_data_i),
      .data_o(m_data_o)
  );
  fifo_oneport #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(ADDR_WIDTH),
      .MEM_SIZE  (STK_SIZE)
  ) stack (
      .clk(clk),
      .push(s_push),
      .pop(s_pop),
      .peek(s_peek),
      .data_i(s_data_i),
      .empty(s_empty),
      .full(s_full),
      .data_o(s_data_o)
  );

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

    stdin = $fopen("/dev/stdin", "rb");

  end

  always_ff @(posedge clk) begin

    if (searching_bracket > 0) begin
      if (instr == "]") searching_bracket <= searching_bracket - 1;
      else if (instr == "[") searching_bracket <= searching_bracket + 1;
    end else if (s_peek) begin
      pc <= s_data_o + 1;
      s_peek <= 0;
    end else begin
      case (instr)
        ">": begin
          if (mp == (RAM_SIZE - 1)) mp <= 0;
          else mp <= mp + 1;
          m_enable_w <= 0;
          s_push <= 0;
          s_pop <= 0;
          s_peek <= 0;
        end
        "<": begin
          if (mp == 0) mp <= RAM_SIZE - 1;
          else mp <= mp - 1;
          m_enable_w <= 0;
          s_push <= 0;
          s_pop <= 0;
          s_peek <= 0;
        end
        "+": begin
          m_data_i <= m_data_o + 1;
          m_enable_w <= 1;
          s_push <= 0;
          s_pop <= 0;
          s_peek <= 0;
        end
        "-": begin
          m_data_i <= m_data_o - 1;
          m_enable_w <= 1;
          s_push <= 0;
          s_pop <= 0;
          s_peek <= 0;
        end
        "[": begin
          if (m_data_o == 0) begin
            searching_bracket <= 1;
            s_push <= 0;
          end else begin
            s_data_i <= pc;
            if (s_full) begin
              s_overflow <= 1;
              s_push <= 0;
            end else s_push <= 1;
          end
          m_enable_w <= 0;
          s_pop <= 0;
          s_peek <= 0;
        end
        "]": begin
          if (m_data_o != 0) begin
            if (s_empty) begin
              s_overflow <= 1;
              s_peek <= 0;
            end else s_peek <= 1;
            s_pop <= 0;
          end else begin
            if (s_empty) begin
              s_overflow <= 1;
              s_pop <= 0;
            end else s_pop <= 1;
            s_peek <= 0;
          end
          m_enable_w <= 0;
          s_push <= 0;
        end
        ".": begin
          $write("%c", m_data_o);
          m_enable_w <= 0;
          s_push <= 0;
          s_pop <= 0;
          s_peek <= 0;
        end
        ",": begin
          m_data_i <= $fgetc(stdin);
          m_enable_w <= 1;
          s_push <= 0;
          s_pop <= 0;
          s_peek <= 0;
        end
        default: begin
          m_enable_w <= 0;
          s_push <= 0;
          s_pop <= 0;
          s_peek <= 0;
        end
      endcase
    end

    if (instr == 0 || pc == ROM_SIZE || s_overflow) $finish;
    else if (!s_peek) pc <= pc + 1;

  end

endmodule
