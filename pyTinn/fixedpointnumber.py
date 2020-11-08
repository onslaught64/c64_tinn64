msb_range: int = 0x10
bit_depth: int = 0xffffff

class FixedPointNumber(object):
    def __init__(self, value: str):
        self._fp_value = value
        self._int_value = int(round((((value + (msb_range/2))/msb_range)*bit_depth)))
        self._bits = self._int_value.to_bytes(3, byteorder='big')
    
    @property
    def value(self) -> float:
        return self._fp_value

    @property
    def scalar(self) -> int:
        return self._int_value

    def render_byte(self, index: int) -> str:
        return hex(self._bits[index]).strip('0x')

    def __str__(self):
        output = ".byte "
        output = output + " $" + self.render_byte(0) # 8 (Drop this)
        output = output + ", $" + self.render_byte(1) # 16 (Keep this HI)
        output = output + ", $" + self.render_byte(2) # 24 (keep this LO)
        output = output + "//"
        output = output + " FLOAT: "
        output = output + str(self.value)
        output = output + "\t\t SCALAR:"
        output = output + str(self.scalar)
        return output
