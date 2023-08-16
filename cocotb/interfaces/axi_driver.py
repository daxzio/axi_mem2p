import math
import logging
import itertools
from random import randint, seed
from cocotbext.axi import AxiBus, AxiMaster, AxiStreamBus, AxiStreamSource

def tobytes(val, length=4):
    array = []
    for i in range(length):
        array.append((val>>(8*i))&0xff)
    return bytearray(array)

def tointeger(val):
    result = 0
    for i, j in enumerate(val):
        result += int(j) << (8*i)
    return result

def cycle_pause(seednum=7):
    seed(seednum)
    length = randint(0, 0xfff)
    array = []
    for i in range(length):
        x = randint(0, 5)
        if 0 == x:
            array.append(1)
        else:
            array.append(0)
    return itertools.cycle(array)
    #return itertools.cycle([0, 0, 1])
    
class AxiDriver:
    def __init__(self, dut, axi_prefix="s_axi", clk_name="s_aclk", reset_name="reset"):
        self.log = logging.getLogger(f"cocotb.AxiDriver")
        self.enable_logging()
        #self.axi_master = AxiMaster(AxiBus.from_prefix(dut, axi_prefix), getattr(dut, clk_name), getattr(dut, reset_name))
        self.axi_master = AxiMaster(AxiBus.from_prefix(dut, axi_prefix), getattr(dut, clk_name))
        #self.axi_master.write_if.log.setLevel(logging.WARNING)
        #self.axi_master.read_if.log.setLevel(logging.WARNING)
        #self.enable_backpressure()
        
        
        
    def enable_logging(self):
        self.log.setLevel(logging.DEBUG)
    
    def disable_logging(self):
        self.log.setLevel(logging.WARNING)

    def enable_backpressure(self, seed=None):
        if seed is None:
            base_seed = randint(0,0xffffff)
        else:
            base_seed = seed
        self.axi_master.write_if.aw_channel.set_pause_generator(cycle_pause(base_seed+1))
        self.axi_master.write_if.w_channel.set_pause_generator(cycle_pause(base_seed+2))
        self.axi_master.write_if.b_channel.set_pause_generator(cycle_pause(base_seed+3))
    
        self.axi_master.read_if.r_channel.set_pause_generator(cycle_pause(base_seed+4))        
        self.axi_master.read_if.ar_channel.set_pause_generator(cycle_pause(base_seed+5))        
    
    def disable_backpressure(self):
#         self.axi_master.write_if.aw_channel.clear_pause_generator()
#         self.axi_master.write_if.w_channel.clear_pause_generator()
#         self.axi_master.write_if.b_channel.clear_pause_generator()
#     
#         self.axi_master.read_if.r_channel.clear_pause_generator()    
#         self.axi_master.read_if.ar_channel.clear_pause_generator()       
        self.axi_master.write_if.aw_channel.set_pause_generator(itertools.cycle([0,]))
        self.axi_master.write_if.w_channel.set_pause_generator(itertools.cycle([0,]))
        self.axi_master.write_if.b_channel.set_pause_generator(itertools.cycle([0,]))
    
        self.axi_master.read_if.r_channel.set_pause_generator(itertools.cycle([0,]))   
        self.axi_master.read_if.ar_channel.set_pause_generator(itertools.cycle([0,]))      
    
    async def read(self, addr, data=None, length=None):
        if length is None:
            if 0 == data or None == data:
                length = 4
            else:
                length = math.ceil(math.log2(data)/32)*4
        ret = await self.axi_master.read(addr, length)
        returned_val = tointeger(ret.data)
        self.log.debug(f"Read  0x{addr:08x}: 0x{returned_val:08x}")
        if not returned_val == data and not None == data:
            raise Exception(f"Expected 0x{data:08x} doesn't match returned 0x{returned_val:08x}")

    async def write(self, addr, data=None, length=None):
        if length is None:
            if 0 == data or None == data:
                length = 4
            else:
                length = math.ceil(math.log2(data)/32)*4
        
        if data is None:
            data = randint(0,0xffffffff)
            for i in range(int(length/4)-1):
                data = (data << 32) + randint(0,0xffffffff)
        self.log.debug(f"Write 0x{addr:08x}: 0x{data:08x}")
        self.tx_data = data
        bytesdata = tobytes(data, length)
        await self.axi_master.write(addr, bytesdata)

    
#     def write_nowait(self, addr, data):
#         self.wrqueue.put_nowait([addr, data])
#         self._wridle.clear()
#         return data
    
class AxiStreamDriver:
    def __init__(self, dut):
        self.log = logging.getLogger(f"cocotb.AxiStreamDriver")
        self.enable_logging()
        self.axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axi"), dut.s_aclk, dut.reset)
        self.axis_source.log.setLevel(logging.WARNING)
        self.enable_backpressure()
        
        
    def enable_logging(self):
        self.log.setLevel(logging.DEBUG)
    
    def disable_logging(self):
        self.log.setLevel(logging.WARNING)

    def enable_backpressure(self, seed=None):
        if seed is None:
            base_seed = randint(0,0xffffff)
        else:
            base_seed = seed
        self.axis_source.set_pause_generator(cycle_pause(base_seed))

    def disable_backpressure(self):
        #self.axis_source.clear_pause_generator()
        self.axis_source.set_pause_generator(itertools.cycle([0,]))
    
    async def write(self, data=None, length=None):
        if length is None:
            if 0 == data or None == data:
                length = 4
            else:
                length = math.ceil(math.log2(data)/32)*4
        if data is None:
            data = randint(0,0xffffff)
        self.log.debug(f"Write 0x{data:08x}")
        bytesdata = tobytes(data, length)
        await self.axis_source.write(bytesdata)
