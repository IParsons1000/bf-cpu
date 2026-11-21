.PHONY: all test rom_oneport rom_oneport_tb ram_oneport ram_oneport_tb bf_cpu bf_cpu_tb test_rom_oneport test_ram_oneport test_bf_cpu

all: rom_oneport ram_oneport bf_cpu

rom_image.mem: rom_image.bf
	hexdump -v -e '/1 "%02x\n"' rom_image.bf > rom_image.mem

rom_oneport: rom_image.mem rom_oneport.sv
	verilator --binary -j 0 -Wall rom_oneport.sv

rom_oneport_tb: rom_oneport rom_oneport_tb.sv
	verilator --binary -j 0 -Wall rom_oneport_tb.sv

ram_oneport: ram_oneport.sv
	verilator --binary -j 0 -Wall ram_oneport.sv

ram_oneport_tb: ram_oneport ram_oneport_tb.sv
	verilator --binary -j 0 -Wall ram_oneport_tb.sv

bf_cpu: bf_cpu.sv
	verilator --binary -j 0 -Wall bf_cpu.sv

bf_cpu_tb: bf_cpu bf_cpu_tb.sv
	verilator --binary -j 0 -Wall bf_cpu_tb.sv

test_rom_oneport: rom_oneport_tb
	obj_dir/Vrom_oneport_tb

test_ram_oneport: ram_oneport_tb
	obj_dir/Vram_oneport_tb

test_bf_cpu: bf_cpu_tb
	obj_dir/Vbf_cpu_tb

test: test_rom_oneport test_ram_oneport test_bf_cpu
