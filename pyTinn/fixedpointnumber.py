import math

class FixedPointNumber(object):
    def __init__(self, value: str):
        self.bits = dict()
        self.width = 24
        self._reset()
        self._parse_float(float(value))

    def _reset(self):
        self.bits = dict()
        for i in range(self.width):
            self.bits[i] = False

    def _parse_float(self, value: float):
        integer = abs(round(value))
        fractional = round((abs(value) - abs(round(value))) * 65535)
        negative = False
        if value < 0:
            negative = True
            self.set_bit(23, True)
            fractional = fractional - 1 
        else:
            self.set_bit(23, False)
        ibits = self.to_bits(integer)
        fbits = self.to_bits(fractional)
        bptr = 24
        idx = 0
        while bptr > 8:
            bit = 0
            if idx < len(fbits):
                bit = fbits[idx]
            if negative: 
                if bit == 1:
                    bit = 0
                else:
                    bit = 1
            self.set_bit(bptr-1,False if bit == 0 else True)
            idx += 1
            bptr -= 1
        idx = 0
        while bptr > 1:
            bit = 0
            if idx < len(ibits):
                bit = ibits[idx]
            if negative: 
                if bit == 1:
                    bit = 0
                else:
                    bit = 1
            self.set_bit(bptr-1,False if bit == 0 else True)
            idx += 1
            bptr -= 1
        if negative:
            self.set_bit(0,True)
        else:
            self.set_bit(0,False)
        return
    
    def to_bits(self, value: int) -> list:
        final = value
        tmp_bits = list()
        while final > 0:
            tmp_bits.append(final % 2)
            final = math.floor(final/2)
        return tmp_bits

    def set_bit(self, offset: int, value: bool):
        self.bits[offset] = value 

    def render_byte_as_bin(self, offset: int) -> str:
        output = ""
        for i in range(8):
            output = output + ("1" if self.bits[(offset * 8) + i] else "0")
        return output

    def __str__(self):
        output = ".byte "
        output = output + " %" + self.render_byte_as_bin(0) # 8
        output = output + ", %" + self.render_byte_as_bin(1) # 16 
        output = output + ", %" + self.render_byte_as_bin(2) # 24
        # output = output + str(self.bits)
        return output

