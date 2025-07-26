OUTDIR := out
TARGET := $(OUTDIR)/tb_fp32_mul.vvp
SRC := fp32_mul.sv tb_fp32_mul.sv

.PHONY: all build test clean

all: build test

build: $(TARGET)

$(OUTDIR):
	mkdir -p $(OUTDIR)

$(TARGET): $(SRC) | $(OUTDIR)
	iverilog -g2012 -o $(TARGET) $(SRC)

test: $(TARGET)
	vvp $(TARGET)

clean:
	rm -rf $(OUTDIR)
