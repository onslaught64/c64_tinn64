#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import math
from typing import IO
from defame.abstract_renderer import AbstractRenderer
from defame.fixedpointnumber import FixedPointNumber 
import numpy as np


class ExpLut(AbstractRenderer):
    """
    This class creates a lookup table for the exponent function used in
    the sigmoidal activation function. The reason for choosing -11 and 11
    as the magic numbers for the range is that these two numbers are the
    point that activation function returns a fixed value (0 and 1) so there
    is no need to calculate the value past those points, instead, just use a
    fixed number.

    Due to base 2 division, the follpwing is true:
    Range for linspace = 0 -> 22
    22 in fixedpoint is $580000 = %01011000 00000000 00000000
                                            01011000 00000000           Step 1: drop low byte
                                            >>>>>>>0 10110000 0000000   Step 2: shift high and mid right 7 bits
                                                     --------
                                                     $B0 is the max index
    Therefore, we need to split up the sigmoid function from 0 -> $B0, not $100
    Decimal is 176
    """
    def __init__(self):
        self.__lut = []
        vals = np.linspace(-11, 11, 176)
        for i in range(176):
            tmp = 1 / (1 + math.exp(vals[i] * -1))
            self.__lut.append(FixedPointNumber(tmp))

    def __getitem__(self, item: int):
        return self.__lut[item]

    def eval(self, input):
        if input > 11:
            return 1.0
        if input < -11:
            return 0.0
        tmp = input + 11  # make range 0 -> 22 instead of -11 to +11
        tmp = (tmp / 22) * 176
        tmp = int(tmp)
        return self.__lut[tmp]

    def __len__(self):
        return len(self.__lut)

    def render_labels(self, file_handle: IO):
        pass

    def render(self, file_handle: IO):
        file_handle.write("// Activation Exponent Lookup: \n")
        file_handle.write(".align $100 \n")
        file_handle.write("exp_lut_lo: \n")
        file_handle.write(".byte " + (",".join([fp.render_byte(0) for fp in self.__lut])))
        file_handle.write("\n")
        file_handle.write(".align $100 \n")
        file_handle.write("exp_lut_mid: \n")
        file_handle.write(".byte " + (",".join([fp.render_byte(1) for fp in self.__lut])))
        file_handle.write("\n")
        file_handle.write(".align $100 \n")
        file_handle.write("exp_lut_hi: \n")
        file_handle.write(".byte " + (",".join([fp.render_byte(2) for fp in self.__lut])))
