#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from fixedpointnumber import FixedPointNumber
import numpy as np
import math


def fp(value: float):
    f = FixedPointNumber(value)
    print(str(f))


print("Testing high byte negative to positive")
vals = np.linspace(-127, 127, 1024)
for i in vals:
    fp(i)

print("Testing exponent segments (256 byte range)")
for i in range(256):
    fp(1 / (1 + math.exp(-((8 * (i/256))-4))))


print("Testing activation function values")
vals = np.linspace(-11, 11, 256)
for i in vals:
    tmp = 1 / (1 + math.exp(-i))
    if (tmp > 0.0) and (tmp < 1.0):
        output = "A:"
        output = output + str(i)
        output = output + "\t func:"
        output = output + str(tmp)
        output = output + "\t FP:"
        output = output + str(FixedPointNumber(tmp))
        print(output)


'''
def act(a: float) -> float:
	"""Activation function."""
	if a > 4:
		return 1.0
	if a < -4:
		return 0.0
	tmp = int(((a + 4) / 8) * 256)
	return exp_lut[tmp]
	# return 1 / (1 + math.exp(-a))
	#
	# calc
	#
	#
	#
'''
