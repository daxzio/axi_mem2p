from cocotb import start_soon
from cocotb import test
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from interfaces.axi_driver import AxiDriver
from random import randint

class clkreset:
    def __init__(self, dut, reset_sense=1):
        self.clk = dut.s_aclk
        self.reset = dut.s_aresetn
        self.reset_sense = reset_sense

    async def wait_clkn(self, length=1):
        for i in range(int(length)):
            await RisingEdge(self.clk)

    async def start_test(self, period=17, units="ns"):
        start_soon(Clock(self.clk, period, units=units).start())        
        
        self.reset.setimmediatevalue(self.reset_sense)
        await self.wait_clkn(100)
        self.reset.value = (~self.reset_sense)  & 0x1
        await self.wait_clkn(100)

    async def end_test(self, length=10):
        await self.wait_clkn(length)

class testbench:
    def __init__(self, dut, reset_sense=1):
        self.cr = clkreset(dut, reset_sense=reset_sense)
        self.axi = AxiDriver(dut, reset_name="s_aresetn")
        self.axi.awid = 0
        self.axi.arid = 0


@test()
async def test_dut_simple(dut):
    
    tb = testbench(dut, reset_sense=0)
    tb.axi.disable_backpressure()
 

    await tb.cr.start_test()
    
    await tb.cr.wait_clkn(200)
    
    await tb.axi.write(0x00000000, 0x2222222211111111)
    await tb.axi.read(0x00000000, 0x2222222211111111)
    
    await tb.axi.write(0x00000000, 0x33333333)
    await tb.axi.read(0x00000000, 0x2222222233333333)
#     await tb.axi.write(0x00000000, 0x4444444433333333)
#     await tb.axi.read(0x00000000, 0x4444444433333333)


    await tb.cr.wait_clkn(200)
          
    await tb.cr.end_test()

@test()
async def test_dut_delay(dut):
    
    tb = testbench(dut, reset_sense=0)
    tb.axi.enable_backpressure(7)
 

    await tb.cr.start_test()
    
    await tb.cr.wait_clkn(200)
    
    await tb.axi.write(0x00000000, 0x0000000800000007000000060000000500000004000000030000000200000001)
    await tb.axi.read(0x00000000, 0x0000000800000007000000060000000500000004000000030000000200000001)
    
    await tb.axi.write(0x00000000, length=256)
    await tb.axi.read(0x00000000, tb.axi.tx_data)

    await tb.axi.write(0x00000000, length=256)
    await tb.axi.read(0x00000000, tb.axi.tx_data)

    await tb.axi.write(0x00000000, length=256)
    await tb.axi.read(0x00000000, tb.axi.tx_data)

    await tb.axi.write(0x00000000, length=4)
    await tb.axi.read(0x00000000, tb.axi.tx_data)
    await tb.axi.write(0x00000000, length=4)
    await tb.axi.read(0x00000000, tb.axi.tx_data)
    await tb.axi.write(0x00000000, length=4)
    await tb.axi.read(0x00000000, tb.axi.tx_data)
    await tb.axi.write(0x00000000, length=4)
    await tb.axi.read(0x00000000, tb.axi.tx_data)
    await tb.axi.write(0x00000000, length=4)
    await tb.axi.read(0x00000000, tb.axi.tx_data)
    await tb.axi.write(0x00000000, length=4)
    await tb.axi.read(0x00000000, tb.axi.tx_data)
    await tb.axi.write(0x00000000, length=4)
    await tb.axi.read(0x00000000, tb.axi.tx_data)
    await tb.axi.write(0x00000000, length=4)
    await tb.axi.read(0x00000000, tb.axi.tx_data)
    await tb.axi.write(0x00000000, length=4)
    await tb.axi.read(0x00000000, tb.axi.tx_data)

    await tb.axi.write(0x00000000, length=8)
    await tb.axi.read(0x00000000, tb.axi.tx_data)
    
    await tb.cr.wait_clkn(200)
          
    await tb.cr.end_test()
