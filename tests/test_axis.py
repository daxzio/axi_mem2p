from cocotb import start_soon
from cocotb import test
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from interfaces.axi_driver import AxiDriver, AxiStreamDriver, AxiStreamReceiver
from random import randint

def axi_readback(indata, bits=32, length=4):
    #print(bits, (bits+31)&0xffffffe0)
    x = (2**bits)-1
    full_width = (bits+31)&0xffffffe0
    y = 0
    for i in range(0, length*8, full_width):
        #print(i, length*8,full_width)
        y = y | x<<i
    #print(f"0x{x:0x}")
    #print(f"0x{y:0x}")
    outdata = indata & y
    #print(f"0x{indata:0x}")
    #print(f"0x{outdata:0x}")
    return outdata


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
        #self.axi = AxiDriver(dut, reset_name="s_aresetn")
        self.axi = AxiDriver(dut)
        self.axi.awid = 0
        self.axi.arid = 0
        self.axis = AxiStreamReceiver(dut, axi_prefix="m_axi")
        self.axis.pause()
    
    async def wait_clkn(self, *args, **kwargs):
        await self.cr.wait_clkn(*args, **kwargs)

    async def start_test(self, *args, **kwargs):
        await self.cr.start_test(*args, **kwargs)

    async def end_test(self, *args, **kwargs):
        await self.cr.end_test(*args, **kwargs)


# @test()
# async def test_dut_simple(dut):
#     
#     tb = testbench(dut, reset_sense=0)
#     tb.axi.disable_backpressure()
#  
# 
#     await tb.start_test()
#     
#     await tb.wait_clkn(200)
#     
#     await tb.axi.write(0x00000000, length=6)
#     
#     await tb.axi.write(0x00000000, 0x2222222211111111)
#     await tb.axi.read(0x00000000, 0x2222222211111111)
#     
#     await tb.axi.write(0x00000000, 0x33333333)
#     await tb.axi.read(0x00000000, 0x2222222233333333)
# #     await tb.axi.write(0x00000000, 0x4444444433333333)
# #     await tb.axi.read(0x00000000, 0x4444444433333333)
# 
# 
#     await tb.wait_clkn(200)
#           
#     await tb.end_test()

# @test()
# async def test_dut_delay32(dut):
#     
#     tb = testbench(dut, reset_sense=0)
#     tb.axi.enable_backpressure()
#  
# 
#     await tb.start_test()
# #     
# #     await tb.wait_clkn(200)
# #     
#     await tb.axi.write(0x00000000, 0x0000000800000007000000060000000500000004000000030000000200000001)
#     await tb.axi.read( 0x00000000, 0x0000000800000007000000060000000500000004000000030000000200000001)
#     tb.axis.unpause()
#     tb.axis.enable_backpressure()
#     await tb.wait_clkn(10)
# 
#     data = await tb.axis.recv(debug=True)
#     data = await tb.axis.recv(0x0000000800000007000000060000000500000004000000030000000200000001, debug=True)
# #     data = await tb.axis.recv(0x0000000800000007000000060000000500000004000000030000000200000001, debug=True)
# #     data = await tb.axis.recv(0x0000000800000007000000060000000500000004000000030000000200000001, debug=True)
# #     data = await tb.axis.recv(0x0000000800000007000000060000000500000004000000030000000200000001, debug=True)
# #     data = await tb.axis.recv(0x0000000800000007000000060000000500000004000000030000000200000001, debug=True)
# #     data = await tb.axis.recv(0x0000000800000007000000060000000500000004000000030000000200000001, debug=True)
# #     data = await tb.axis.recv(0x0000000800000007000000060000000500000004000000030000000200000001, debug=True)
# #     data = await tb.axis.recv(0x0000000800000007000000060000000500000004000000030000000200000001, debug=True)
# 
# #     tb.axis.pause()
# #     await tb.wait_clkn()
# #     tb.axis.unpause()
# 
# 
#     await tb.wait_clkn(200)
#           
#     await tb.end_test()

# @test()
# async def test_dut_delay48(dut):
#     
#     tb = testbench(dut, reset_sense=0)
#     #tb.axi.enable_backpressure()
#  
# 
#     await tb.start_test()
# #     
# #     await tb.wait_clkn(200)
# #     
#     await tb.axi.write(0x00000000, 0x000000ab0000000f0000000e0000000d0000000c0000000b0000000a000000090000000800000007000000060000000500000004000000030000000200000001)
#     await tb.axi.read( 0x00000000, 0x000000ab0000000f0000000e0000000d0000000c0000000b0000000a000000090000000800000007000000060000000500000004000000030000000200000001)
#     
#        
#     
#     tb.axis.unpause()
#     tb.axis.enable_backpressure()
#     await tb.wait_clkn(10)
# 
#     data = await tb.axis.recv(debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     await tb.wait_clkn(200)
#           
#     await tb.axi.write(0x00000000, 0x9980e4943387f1a13345cbbcd7cdfa8bbc2a2fb59f4a5a935181db1b30fd238e0c6ee4008a1f45c173d3d8d030d4c903bc3d1c3c37ce26c21a0a6746e661317b0c3f6cdc7185669d60c7bdc873f93899484ac2673ae72975e37aa999c404406870dd41d893b157a47bbc812296fb4441f26adc1f20090df69f1231ec5999bd24)
#     await tb.axi.read( 0x00000000, 0x9980e4943387f1a13345cbbcd7cdfa8bbc2a2fb59f4a5a935181db1b30fd238e0c6ee4008a1f45c173d3d8d030d4c903bc3d1c3c37ce26c21a0a6746e661317b0c3f6cdc7185669d60c7bdc873f93899484ac2673ae72975e37aa999c404406870dd41d893b157a47bbc812296fb4441f26adc1f20090df69f1231ec5999bd24)
# 
#     await tb.end_test()

@test()
async def test_dut_delay48b(dut):
    
    tb = testbench(dut, reset_sense=0)
    tb.axi.enable_backpressure()
 

    await tb.start_test()
#     
#     await tb.wait_clkn(200)
#     
    await tb.axi.write(0x00000000, length=8)
    data0 = tb.axi.writedata
    newdata0 = axi_readback(data0, 48, length=8)
    await tb.axi.read( 0x00000000, newdata0, length=8)
    
    length = 16
    await tb.axi.write(0x00000000, length=length)
    data0 = tb.axi.writedata
    newdata0 = axi_readback(data0, 48, length=length)
    await tb.axi.read( 0x00000000, newdata0, length=length)
    
    length = 32
    await tb.axi.write(0x00000000, length=length)
    data0 = tb.axi.writedata
    newdata0 = axi_readback(data0, 48, length=length)
    await tb.axi.read( 0x00000000, newdata0, length=length)
    
    length = 64
    await tb.axi.write(0x00000000, length=length)
    data0 = tb.axi.writedata
    newdata0 = axi_readback(data0, 48, length=length)
    await tb.axi.read( 0x00000000, newdata0, length=length)
    
    length = 128
    await tb.axi.write(0x00000000, length=length)
    data0 = tb.axi.writedata
    newdata0 = axi_readback(data0, 48, length=length)
    await tb.axi.read( 0x00000000, newdata0, length=length)
    
    length = 256
    await tb.axi.write(0x00000000, length=length)
    data0 = tb.axi.writedata
    newdata0 = axi_readback(data0, 48, length=length)
    await tb.axi.read( 0x00000000, newdata0, length=length)
    
    await tb.axi.write(0x00000000, 0xcaeb5bd8de6d03f939e29c0cef8dc17849c0f13a95bae9502a99c3cb9e94549f7ea2631f507c63d593bc8cb22ca772ee71dc3021c7600b3c1e510925d18bbc683bd362514d13349f5a097e1202f008e281de86c836cc868ee91cde5af37f7cc08cd72d3ab702dee7c82e5dfbf00987b0f3859bbffd3f322627cf5e4399e0e451fca656d013d6834d51fc91b7fd083643ffe240290cabe8481dbfd9cf988c9f42f72a5337d6ef6ff71ae700dbcc8f3ae6b188ffc7fa53b71b4a94022fa2484ba2f7e39398ed13a543f686d7f093630a0a7dbeeb98b082a27b6888ad95cc0e5c8e0df5ced76d2dc1b343508b0de750e302838cf275802f94042d02aa978a61b224)
       
    
    tb.axis.unpause()
    tb.axis.enable_backpressure()
    await tb.wait_clkn(10)

    #data = await tb.axis.recv(debug=True)
    data = await tb.axis.recv(0x56d013d6834d91b7fd08364340290cabe848d9cf988c9f425337d6ef6ff700dbcc8f3ae6ffc7fa53b71b022fa2484ba29398ed13a543d7f093630a0aeb98b082a27bad95cc0e5c8eced76d2dc1b38b0de750e302f275802f9404aa978a61b224, debug=True)
    data = await tb.axis.recv(0x5bd8de6d03f99c0cef8dc178f13a95bae950c3cb9e94549f631f507c63d58cb22ca772ee3021c7600b3c0925d18bbc6862514d13349f7e1202f008e286c836cc868ede5af37f7cc02d3ab702dee75dfbf00987b09bbffd3f32265e4399e0e451, debug=True)
    data = await tb.axis.recv(debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
#     data = await tb.axis.recv(0x000800000007000600000005000400000003000200000001, debug=True)
    await tb.wait_clkn(200)
          

    await tb.end_test()

# @test()
# async def test_dut_rdwr(dut):
#     
#     tb = testbench(dut, reset_sense=0)
#     #tb.axi.enable_backpressure(13)
#  
# 
#     await tb.start_test()
#     
#     await tb.wait_clkn(200)
#     
#     tb.axi.write_nowait(0x00000040, length=32)
#     data0 = tb.axi.writedata
#     await tb.wait_clkn(3)
#     tb.axi.read_nowait(0x00000140, length=32)
#     tb.axi.write_nowait(0x00000080, length=32)
#     data1 = tb.axi.writedata
#     tb.axi.read_nowait(0x00000180, length=32)
#     
# #     tb.
#     await tb.axi.read_op.wait()
#     await tb.axi.write_op.wait()
#     await tb.wait_clkn(20)
#     
#     await tb.axi.write(0x00000000, length=32)
#     await tb.axi.read(0x00000000, length=32)
# 
#     await tb.axi.read(0x00000040, data0)
#     await tb.axi.read(0x00000080, data1)
# 
#     await tb.wait_clkn(200)
#           
#     await tb.end_test()
