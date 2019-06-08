import math

class FixedPointNumber(object):
    def __init__(self, value: str):
        self.bits = [int for i in range(24)]
        self.fp_value = 0
        self._parse_float(float(value))

    def _parse_float(self, value: float):
        self.fp_value = int(round(value * 65536))       
        assert(self.fp_value < 8388607) #7fffff
        assert(self.fp_value > -8388607) #-7fffff
        bits = self.to_bits(abs(self.fp_value))
        bptr = 24
        idx = 0
        while bptr > 0:
            if idx < len(bits):
                self.bits[bptr-1]=bits[idx]
            else:
                self.bits[bptr-1]=0
            bptr -= 1
            idx += 1
        if self.fp_value < 0:
            #twos complement based on examination of 6502 
            for i in range(len(self.bits)):
                self.bits[i] = 1 if self.bits[i] == 0 else 0
            carry = 1
            bit_index = 23
            while carry == 1 and bit_index > -1:
                if self.bits[bit_index] == 0:
                    self.bits[bit_index] = 1
                    carry = 0
                else:
                    self.bits[bit_index] = 0
                    bit_index -= 1
        return
    
    def to_bits(self, value: int) -> list:
        final = value
        tmp_bits = list()
        while final > 0:
            tmp_bits.append(final % 2)
            final = math.floor(final/2)
        return tmp_bits

    def render_byte_as_bin(self, offset: int) -> str:
        output = ""
        for i in range(8):
            output = output + ("1" if self.bits[(offset * 8) + i] > 0 else "0")
        return output

    def get_fp_value(self):
        return self.fp_value

    def __str__(self):
        output = ".byte "
        output = output + " %" + self.render_byte_as_bin(0) # 8
        output = output + ", %" + self.render_byte_as_bin(1) # 16 
        output = output + ", %" + self.render_byte_as_bin(2) # 24
        output = output + "//"
        output = output + " FIXED: "
        output = output + str(hex(self.fp_value))
        output = output + "\t\t FLOAT "
        output = output + str(self.fp_value / 65536)
        return output

    def render_selected_byte(self, index):
        output = ".byte "
        output = output + " %" + self.render_byte_as_bin(index) # 8
        output = output + "//"
        output = output + " FIXED: "
        output = output + str(hex(self.fp_value))
        output = output + "\t\t FLOAT "
        output = output + str(self.fp_value / 65536)
        return output

