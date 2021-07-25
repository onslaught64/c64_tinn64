#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import math
from defame.fixedpointnumber import FixedPointNumber 
import numpy as np


class ExpLut(object):
    """
    This class creates a lookup table for the exponent function used in
    the sigmoidal activation function. The reason for choosing -11 and 11
    as the magic numbers for the range is that these two numbers are the
    point that activation function returns a fixed value (-1 and 1) so there
    is no need to calculate the value past those points, instead, just use a
    fixed number.
    """
    def __init__(self, size: int):
        self.__lut = [size]
        vals = np.linspace(-11, 11, 256)
        for i in range(size):
            tmp = 1 / (1 + math.exp(vals[i] * -1))
            self.__lut[i] = FixedPointNumber(tmp)

    def __getitem__(self, item: int):
        return self.__lut[item]

    def __len__(self):
        return len(self.__lut)

    def render(self, filename: str):
        output = open(filename, "w")
        output.write("// Activation Exponent Lookup: \n")
        output.write(".align $100 \n")
        output.write("exp_lut_lo: \n")
        output.write(".byte " + (",".join([fp.render_byte(2) for fp in self.__lut])))
        output.write("\n")
        output.write(".align $100 \n")
        output.write("exp_lut_mid: \n")
        output.write(".byte " + (",".join([fp.render_byte(1) for fp in self.__lut])))
        output.write("\n")
        output.write(".align $100 \n")
        output.write("exp_lut_hi: \n")
        output.write(".byte " + (",".join([fp.render_byte(0) for fp in self.__lut])))
        output.close()


