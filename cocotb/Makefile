SIM?=icarus
TOPLEVEL_LANG=verilog
WORK_BASE?=${HOME}/projects
#WORK_BASE?=..
#XILINX_BASE=${HOME}/projects/XilinxUnisimLibrary

TOPLEVEL = dut
#MODULE = test_2p
MODULE = test_axis

IMPORT_SOURCES += \
    /home/dkeeshan/projects/verilog-axi/rtl/axi_config_wr.v \
    /home/dkeeshan/projects/verilog-axi/rtl/axi_config_rd.v \
    /home/dkeeshan/projects/verilog-axi/rtl/axi_config.v \

RTL_SOURCES += \
    ../rtl/blockmem_1p.sv \
    ../rtl/blockmem_1p_wrapper.sv \
    ../rtl/blockmem_2p.sv \
    ../rtl/blockmem_2p_wrapper.sv \
    ../rtl/blk_mem_gen.sv \
    ../rtl/axi_1p.sv \
    ../rtl/axi_2p.sv \
    ../rtl/axi_axis.sv \
   

VERILOG_DESIGN += ${XILINX_IP_SOURCES} ${RTL_SOURCES} ${IMPORT_SOURCES}

VERILOG_SOURCES = \
    ${VERILOG_DESIGN} \
    ./dut_axi_axis.sv
#     ./dut_axi_1p.sv
#    ./dut_axi_2p.sv

include ${WORK_BASE}/rtlflo/xilinx_helper.mak
include ${WORK_BASE}/rtlflo/cocotb_helper.mak
include ${WORK_BASE}/rtlflo/verible_helper.mak
include ${WORK_BASE}/rtlflo/git_helper.mak
