"""
FIXED POINT NUMBER
------------------
24 bit signed fixed point number implementation
that outputs lo-med-hi byte for Kick Assembler

Zig/Defame
"""

msb_range = 64
bit_depth = 0x1000000


class FixedPointNumber(object):
    def __init__(self, value: float):
        self._fp: float = value
        self._int: int = 0
        self._bits = []
        self._reparse()

    def _go_neg(self, val):
        if (val & (1 << (24 - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
            val = val - (1 << 24)        # compute negative value
        return val & ((2 ** 24) - 1)

    def _reparse(self):
        value = self._fp
        self._int = int(round(((value/msb_range)*bit_depth)))
        self._bits = self._int.to_bytes(3, byteorder='little', signed=True)

    @property
    def value(self) -> float:
        return self._fp

    @property
    def scalar(self) -> int:
        return self._int

    def render_byte(self, index: int) -> str:
        return "$" + hex(self._bits[index]).replace('0x','').zfill(2)

    def __str__(self):
        output = ".byte "
        output = output + self.render_byte(0) # 8 (Lo)
        output = output + "," + self.render_byte(1) # 16 (Med)
        output = output + "," + self.render_byte(2) # 24 (Hi)
        output = output + "//"
        output = output + " FLOAT: "
        output = output + str(self.value).zfill(24)
        output = output + "\t\t SCALAR:"
        output = output + str(self.scalar).zfill(8)
        output = output + "\t\t HEX:"
        output = output + self.render_byte(2) + self.render_byte(1) + self.render_byte(0)        
        return output
