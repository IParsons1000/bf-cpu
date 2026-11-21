.PHONY: all rom_oneport ram_oneport bf_cpu

all: rom_oneport ram_oneport bf_cpu

rom_image.mem: rom_image.bf
	hexdump -v -e '/1 "%02x\n"' rom_image.bf > rom_image.mem

rom_oneport: rom_image.mem rom_oneport.sv
	verilator --binary -j 0 -Wall rom_oneport.sv

ram_oneport: ram_oneport.sv
	verilator --binary -j 0 -Wall ram_oneport.sv

bf_cpu: bf_cpu.sv
	verilator --binary -j 0 -Wall bf_cpu.sv
