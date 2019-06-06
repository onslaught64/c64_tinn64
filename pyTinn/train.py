#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import random
import tinn
from fixedpointnumber import FixedPointNumber 


class Data:
	def __init__(self, path, nips, nops):
		self.read_data(path, nips, nops)

	def __repr__(self):
		return str(len(self)) + " rows with " + str(len(self.in_[0])) + " inputs and " + str(len(self.tg[0])) + " outputs."

	def read_data(self, path, nips, nops):
		self.in_, self.tg = [], []
		with open(path) as data_file:
			for line in data_file:
				row = list(map(float, line.split()))
				self.in_.append(row[:nips])
				self.tg.append(row[nips:])

	def shuffle(self):
		indexes = list(range(len(self.in_)))
		random.shuffle(indexes)
		self.in_ = [self.in_[i] for i in indexes]
		self.tg = [self.tg[i] for i in indexes]

	def __len__(self):
		return len(self.in_)


def do_output(o, value:float):
	fp = FixedPointNumber(value)
	o.write(str(fp) + "\n")


nips = 256
nhid = 32
nops = 10
rate = 1.0
anneal = 0.998
print("loading training data")
data = Data('../data/training.data', nips, nops)
print("model init")
t = tinn.Tinn(nips, nhid, nops)
for _ in range(1):
	data.shuffle()
	error = 0
	print("training pass...")
	for in_, tg in zip(data.in_, data.tg):
		error += tinn.xttrain(t, in_, tg, rate)
	print("error " + str(error/len(data)) + " :: learning rate " + str(rate))
	rate *= anneal

in_ = data.in_[0]
tg = data.tg[0]
pd = tinn.xtpredict(t, in_)
print(' '.join(map(str, tg)))
print(' '.join(map(str, pd)))

# export KickAss fixed point lookups, neurons and biases 
output = open("data.asm","w")
print()
print()
output.write("// Activation Exponent Lookup:")
output.write(".align $100")
output.write("exp_lut:")
for i in range(256):
        do_output(output,( 1 / (1 + math.exp(-((8 * (i/256))-4)))))

output.write("// Biases: \n")
output.write(".align $100")
output.write("t_biases:"
for i in t.b:
	do_output(output, i)

output.write("// Input to Hidden: \n")
output.write(".align $100")
output.write("t_x1:")
for i in t.x1:
	for j in i:
		do_output(output, j)
		
output.write("// Hidden to Output: \n")
output.write(".align $100")
output.write("t_x2:")
for i in t.x2:
	for j in i:
		do_output(output, j)

output.close()
