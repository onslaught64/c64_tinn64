#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import math
from fixedpointnumber import FixedPointNumber 
import numpy as np


def do_output(o, fp: FixedPointNumber, index):
    o.write(str(fp.render_byte_as_bin(index)) + "\n")


lut = [256]
vals = np.linspace(-11, 11, 256)
for i in range(256):
    tmp = 1 / (1 + math.exp(vals[i]*-1))
    lut[i] = FixedPointNumber(tmp)
output = open("../output/exp_lut.asm", "w")
print()
print("Rendering exponent lookup to file...")
output.write("// Activation Exponent Lookup: \n")
output.write(".align $100 \n")
output.write("exp_lut_lo: \n")
for i in range(256):
    do_output(output, lut[i], 2)
output.write("\n")
output.write(".align $100 \n")
output.write("exp_lut_mid: \n")
for i in range(256):
    do_output(output, lut[i], 1)
output.write("\n")
output.write(".align $100 \n")
output.write("exp_lut_hi: \n")
for i in range(256):
    do_output(output, lut[i], 0)
output.close()

