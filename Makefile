BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5

all: pwm.fs

# Synthesis
vereact.json: vereact.v
	yosys -p "read_verilog vereact.v; synth_gowin -top vereact -json vereact.json"

# Place and Route
vereact_pnr.json: vereact.json
	nextpnr-gowin --json veract.json --freq 27 --write vereact_pnr.json --device ${DEVICE} --family ${FAMILY} --cst ${BOARD}.cst

# Generate Bitstream
vereact.fs: vereact_pnr.json
	gowin_pack -d ${FAMILY} -o vereact.fs vereact_pnr.json

# Program Board
load: vereact.fs
	sudo /opt/oss-cad-suite/bin/openFPGALoader -b ${BOARD} vereact.fs -f

test.o: pwm_tb.v pwm.v
	iverilog -o test.o pwm_tb.v

test: test.o
	./test.o

view: test.o
	./test.o && gtkwave pwm.vcd

# Cleanup build artifacts
clean:
	rm pwm.vcd pwm.fs test.o

.PHONY: load clean test view
.INTERMEDIATE: vereact_pnr.json vereact.json test.o pwm.vcd
