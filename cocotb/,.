SIM ?= icarus
TOPLEVEL_LANG = verilog
WORK_BASE?=${HOME}/projects
#XILINX_BASE=${HOME}/projects/XilinxUnisimLibrary

RTL_SOURCES += \
    ./blockmem_2p.sv \
    ./blockmem_2p_wrapper.sv \
    ./blk_mem_gen.sv \

VERILOG_DESIGN += \
    ${IP_SOURCES} \
    ${RTL_SOURCES}
    
VERILOG_SOURCES = \
    ${VERILOG_DESIGN} \
    ./dut.sv 

TOPLEVEL = dut
MODULE = test_2p

include ${WORK_BASE}/rtlflo/cocotb_helper.mak
