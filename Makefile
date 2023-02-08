SIM ?= icarus
TOPLEVEL_LANG = verilog
VERILOG_SOURCES = \
    $(shell pwd)/blockmem_2p.sv \
    $(shell pwd)/blk_mem_gen.sv \
    $(shell pwd)/dut.sv 
    
TOPLEVEL = dut
MODULE = test_2p

ifeq ($(SIM), icarus)
    COMPILE_ARGS +=  -s glbl
    VERILOG_SOURCES += \
        /home/dkeeshan/projects/XilinxUnisimLibrary/verilog/src/glbl.v
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

waves:
	simvision -waves dut.vcd &
    
clean::
	rm -rf __pycache__/ .simvision/ .Xil/ results.xml *.trn *.dsn vivado* *.vcd
