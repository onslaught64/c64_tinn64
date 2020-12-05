#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from fixedpointnumber import FixedPointNumber
import numpy as np
import math


def fp(value: float):
    f = FixedPointNumber(value)
    print(str(f))


print("Testing high byte negative to positive range")
vals = np.linspace(-1, 1, 0xf)
for i in vals:
    fp(i)

print("C64 TEST 4 VALUES")
fp(-0.03)
fp(0.275)
fp(-0.03 + 0.275)

print("C64 TEST 5 VALUES")
fp(7.9)
fp(0.27585)
fp(7.9 - 0.27585)

print("C64 TEST 7 VALUES")
fp(7.9)
fp(0.27585)
fp(7.9 * 0.27585)

print("C64 TEST 9 VALUES")
fp(-7.9)
fp(0.27585)
fp(-7.9 * 0.27585)




# print("Testing exponent segments (256 byte range)")
# for i in range(256):
#     fp(1 / (1 + math.exp(-((8 * (i/256))-4))))

# print("Testing activation function values")
# vals = np.linspace(-11, 11, 256)
# for i in vals:
#     tmp = 1 / (1 + math.exp(-i))
#     if (tmp > 0.0) and (tmp < 1.0):
#         output = "A:"
#         output = output + str(i)
#         output = output + "\t func:"
#         output = output + str(tmp)
#         output = output + "\t FP:"
#         output = output + str(FixedPointNumber(tmp))
#         print(output)


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
