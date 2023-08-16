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
    
class AxiDriver:
    def __init__(self, dut, axi_prefix="s_axi", clk_name="s_aclk", reset_name=None, seednum=None):
        self.log = logging.getLogger(f"cocotb.AxiDriver")
        self.enable_logging()
        if reset_name is None:
            self.axi_master = AxiMaster(AxiBus.from_prefix(dut, axi_prefix), getattr(dut, clk_name))
        else:
            self.axi_master = AxiMaster(AxiBus.from_prefix(dut, axi_prefix), getattr(dut, clk_name), getattr(dut, reset_name))
        self.arid = 4
        self.awid = 4
        self.axi_master.write_if.log.setLevel(logging.WARNING)
        self.axi_master.read_if.log.setLevel(logging.WARNING)
        if seednum is not None:
            self.base_seed = seednum
        else:
            self.base_seed = randint(0,0xffffff)
        seed(self.base_seed)
        self.log.debug(f"Seed is set to {self.base_seed}")
        
    
    @property
    def length(self):
        if self.len is None:
            if not 0 == self.data and not self.data is None:
                return math.ceil(math.log2(self.data)/32)*4
            else:
                return 4
        return self.len

    @property
    def returned_val(self):
        if hasattr(self.read_op, "data"):
            return tointeger(self.read_op.data)
        else:
            return tointeger(self.read_op)
            
    def enable_logging(self):
        self.log.setLevel(logging.DEBUG)
    
    def disable_logging(self):
        self.log.setLevel(logging.WARNING)

    def enable_write_backpressure(self, seednum=None):
        if seednum is not None:
            self.base_seed = seednum
        self.axi_master.write_if.aw_channel.set_pause_generator(cycle_pause(self.base_seed+1))
        self.axi_master.write_if.w_channel.set_pause_generator(cycle_pause(self.base_seed+2))
        self.axi_master.write_if.b_channel.set_pause_generator(cycle_pause(self.base_seed+3))
    
    def enable_read_backpressure(self, seednum=None):
        if seednum is not None:
            self.base_seed = seednum
        self.axi_master.read_if.r_channel.set_pause_generator(cycle_pause(self.base_seed+4))        
        self.axi_master.read_if.ar_channel.set_pause_generator(cycle_pause(self.base_seed+5))        
    
    def enable_backpressure(self, seednum=None):
        self.enable_write_backpressure(seednum)      
        self.enable_read_backpressure(seednum)      
    
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
    
    def check_read(self, debug=True):
        if debug:
            self.log.debug(f"Read  0x{self.addr:08x}: 0x{self.returned_val:08x}")
        if not self.returned_val == self.data and not None == self.data:
            raise Exception(f"Expected 0x{self.data:08x} doesn't match returned 0x{self.returned_val:08x}")
    
    async def read(self, addr, data=None, length=None, debug=True):
        self.addr = addr
        self.data = data
        self.len = length
        self.read_op = await self.axi_master.read(self.addr, self.length, arid=self.arid)
        self.check_read(debug)
        return self.read_op
        

    async def write(self, addr, data=None, length=None, debug=True):
        self.len = length
        self.addr = addr
        if data is None:
            self.data = 0
            for i in range(0, self.length, 4):
                self.data = self.data | (randint(0, 0xffffffff) << i*8)
        else:
            self.data = data
        self.writedata = self.data
        if debug:
            self.log.debug(f"Write 0x{self.addr:08x}: 0x{self.data:08x}")
        bytesdata = tobytes(self.data, self.length)
        await self.axi_master.write(addr, bytesdata, awid=self.arid)

    async def rmodw(self, addr, data, length=None, debug=True):
        await self.read(addr, length=None, debug=False)
        newdata = data | self.returned_val
        if debug:
            self.log.debug(f"RmodW 0x{addr:08x}: 0x{self.returned_val:08x} | 0x{data:08x} -> 0x{newdata:08x}")
        await self.write(addr, newdata, length=None, debug=False)

    
    def init_read(self, *args, **kwargs):
        self.read_op = self.axi_master.init_read(*args, **kwargs) 
#         debug = True
#         if debug:
#             self.log.debug(f"Read  0x{self.addr:08x}: 0x{self.returned_val:08x}")
        return self.read_op 
    
    def read_nowait(self, addr, data=None, length=None, debug=True):
        self.len = length
        self.data = data
        self.read_op = self.init_read(addr, self.length, arid=self.arid)
        if debug:
            self.log.debug(f"Read  0x{addr:08x}")
    
    def write_nowait(self, addr, data, length=None, debug=True):
        self.len = length
        self.data = data
        if debug:
            self.log.debug(f"Write 0x{addr:08x}: 0x{data:08x}")
        bytesdata = tobytes(self.data, self.length)
        self.wr_op = self.axi_master.init_write(addr, bytesdata, awid=self.arid)

    
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

    def enable_backpressure(self):
        base_seed = randint(0,0xffffff)
        self.axis_source.set_pause_generator(cycle_pause(base_seed))

    def disable_backpressure(self):
        #self.axis_source.clear_pause_generator()
        self.axis_source.set_pause_generator(itertools.cycle([0,]))
    
    async def write(self, data, length=None):
        if length is None:
            if 0 == data:
                length = 4
            else:
                length = math.ceil(math.log2(data)/32)*4
        self.log.debug(f"Write 0x{data:08x}")
        bytesdata = tobytes(data, length)
        await self.axis_source.write(bytesdata)
