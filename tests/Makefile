SIM?=icarus
TOPLEVEL_LANG=verilog
# WORK_BASE?=${HOME}/projects
PROJ_HOME?=..
#XILINX_BASE=${HOME}/projects/XilinxUnisimLibrary

TOPLEVEL = dut
#MODULE = test_2p
MODULE = test_axis

VERILOG_EXT_SOURCES += \
    ${PROJ_HOME}/repos/verilog-axi/rtl/axi_config_wr.v \
    ${PROJ_HOME}/repos/verilog-axi/rtl/axi_config_rd.v \
    ${PROJ_HOME}/repos/verilog-axi/rtl/axi_config.v \

VERILOG_INT_SOURCES += \
    ${PROJ_HOME}/rtl/blockmem_1p.sv \
    ${PROJ_HOME}/rtl/blockmem_1p_wrapper.sv \
    ${PROJ_HOME}/rtl/blockmem_2p.sv \
    ${PROJ_HOME}/rtl/blockmem_2p_wrapper.sv \
    ${PROJ_HOME}/rtl/blk_mem_gen.sv \
    ${PROJ_HOME}/rtl/axi_1p.sv \
    ${PROJ_HOME}/rtl/axi_2p.sv \
    ${PROJ_HOME}/rtl/axi_blockram.sv \
    ${PROJ_HOME}/rtl/axi_axis.sv \
   

VERILOG_DESIGN += \
	${XILINX_IP_SOURCES} \
	${VERILOG_INT_SOURCES} \
	${VERILOG_EXT_SOURCES}

VERILOG_SOURCES = \
    ${VERILOG_DESIGN} \
    ./dut_axi_axis.sv
#     ./dut_axi_1p.sv
#    ./dut_axi_2p.sv

include ${PROJ_HOME}/rtlflo/cocotb_helper.mak
