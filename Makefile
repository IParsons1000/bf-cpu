#
# (c)2026 Ira Parsons
# bf-cpu - a brainf*ck-native cpu
#
	
SYNTHESIZER ?= verilator
SYNTH_ARGS = --binary -j 0 -Wall
SYNTH_ARGS += -y src

OUTPUT_DIR = bin
SYNTH_ARGS += --Mdir $(OUTPUT_DIR)

ROM_IMG_SRC ?= rom_image.bf

SRC_TARGETS = rom_oneport ram_oneport fifo_oneport bf_cpu
TB_TARGETS = rom_oneport_tb ram_oneport_tb fifo_oneport_tb bf_cpu_tb
TEST_TARGETS = test_rom_oneport test_ram_oneport test_fifo_oneport test_bf_cpu

.PHONY: all test clean $(SRC_TARGETS) $(TB_TARGETS) $(TEST_TARGETS)

all: rom_oneport ram_oneport fifo_oneport bf_cpu

rom_image.mem: $(ROM_IMG_SRC)
	hexdump -v -e '/1 "%02x\n"' $(ROM_IMG_SRC) > rom_image.mem

rom_oneport: rom_image.mem src/rom_oneport.sv
	$(SYNTHESIZER) $(SYNTH_ARGS) src/rom_oneport.sv

rom_oneport_tb: rom_oneport test/rom_oneport_tb.sv
	$(SYNTHESIZER) $(SYNTH_ARGS) test/rom_oneport_tb.sv

ram_oneport: src/ram_oneport.sv
	$(SYNTHESIZER) $(SYNTH_ARGS) src/ram_oneport.sv

ram_oneport_tb: ram_oneport test/ram_oneport_tb.sv
	$(SYNTHESIZER) $(SYNTH_ARGS) test/ram_oneport_tb.sv

fifo_oneport: src/fifo_oneport.sv
	$(SYNTHESIZER) $(SYNTH_ARGS) src/fifo_oneport.sv

fifo_oneport_tb: fifo_oneport test/fifo_oneport_tb.sv
	$(SYNTHESIZER) $(SYNTH_ARGS) test/fifo_oneport_tb.sv

bf_cpu: src/bf_cpu.sv
	$(SYNTHESIZER) $(SYNTH_ARGS) bf_cpu.sv

bf_cpu_tb: bf_cpu test/bf_cpu_tb.sv
	$(SYNTHESIZER) $(SYNTH_ARGS) test/bf_cpu_tb.sv

test_rom_oneport: rom_oneport_tb
	$(OUTPUT_DIR)/Vrom_oneport_tb

test_ram_oneport: ram_oneport_tb
	$(OUTPUT_DIR)/Vram_oneport_tb

test_fifo_oneport: fifo_oneport_tb
	$(OUTPUT_DIR)/Vfifo_oneport_tb

test_bf_cpu: bf_cpu_tb
	$(OUTPUT_DIR)/Vbf_cpu_tb

test: test_rom_oneport test_ram_oneport test_fifo_oneport test_bf_cpu

clean:
	-rm -rf $(OUTPUT_DIR) rom_image.mem
