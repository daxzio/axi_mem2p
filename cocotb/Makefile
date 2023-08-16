SIM?=icarus
TOPLEVEL_LANG=verilog
#WORK_BASE?=${HOME}/projects
WORK_BASE?=..
#XILINX_BASE=${HOME}/projects/XilinxUnisimLibrary

TOPLEVEL = dut
MODULE = test_2p

RTL_SOURCES += \
    ../rtl/blockmem_2p.sv \
    ../rtl/blockmem_2p_wrapper.sv \
    ../rtl/blk_mem_gen.sv \
    

VERILOG_DESIGN += ${XILINX_IP_SOURCES} ${RTL_SOURCES} ${IMPORT_SOURCES}

VERILOG_SOURCES = \
    ${VERILOG_DESIGN} \
    ./dut.sv

include ${WORK_BASE}/rtlflo/xilinx_helper.mak
include ${WORK_BASE}/rtlflo/cocotb_helper.mak
include ${WORK_BASE}/rtlflo/verible_helper.mak
include ${WORK_BASE}/rtlflo/git_helper.mak
