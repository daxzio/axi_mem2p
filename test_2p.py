import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotbext.axi import AxiBus, AxiMaster

def tobytes(val, length=4):
    array = []
    for i in range(length):
        array.append((val>>(8*i))&0xff)
    return bytearray(array)
    
async def axi_read_verify(axi_master, addr, length, val):
    data = await axi_master.read(addr, length)
    
    assert data.data == val
    return

async def start_test(dut, period=10, units="ns"):
    cocotb.start_soon(Clock(dut.clk, period, units=units).start())
 
    dut.resetn.setimmediatevalue(0)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.resetn.value = 1    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
     

async def end_test(dut):
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

@cocotb.test()
async def test_dp_simple(dut):
    await start_test(dut)

    axi_master = AxiMaster(AxiBus.from_prefix(dut, "s_axi"), dut.clk, dut.resetn)
    
    #await axi_read_verify(axi_master, 0x0000, 4, b'test')
    
    data = await axi_master.read(0x0000, 4)
    
    assert data.data == b'\x00\x00\x00\x00'


    await axi_master.write(0x0000, b'test')
    data = await axi_master.read(0x0000, 4)
    
    assert data.data == b'test'

        
    await axi_master.write(0x0010, b'1234test')
    data = await axi_master.read(0x0010, 8)
    
    assert data.data == b'1234test'
    
    await axi_master.write(0x0020, b'xyfe')
    data = await axi_master.read(0x0020, 4)
    
    assert data.data == b'xyfe'
    
    #await axi_master.write(0x0010, 0x12345678)
    
    await end_test(dut)
    
@cocotb.test()
async def test_dp_init(dut):
    
    await start_test(dut)

    axi_master = AxiMaster(AxiBus.from_prefix(dut, "s_axi"), dut.clk, dut.resetn)

    data = await axi_master.read(0x0000, 4)
    
    assert data.data == b'test'
    assert data.data == b'\x74\x65\x73\x74'
    assert data.data == tobytes(0x74736574)
    
    await end_test(dut)    
