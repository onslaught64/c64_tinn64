#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import math
import random
import tinn
from fixedpointnumber import FixedPointNumber 
from itertools import (takewhile,repeat)
import sys


def update_progress(progress):
    barLength = 20 # Modify this to change the length of the progress bar
    status = ""
    if isinstance(progress, int):
        progress = float(progress)
    if not isinstance(progress, float):
        progress = 0
        status = "error: progress var must be float\r\n"
    if progress < 0:
        progress = 0
        status = "Halt...\r\n"
    if progress >= 1:
        progress = 1
        status = "Done...\r\n"
    block = int(round(barLength*progress))
    text = "\rProgress: [{0}] {1}% {2}".format( "#"*block + "-"*(barLength-block), round(progress*100), status)
    sys.stdout.write(text)
    sys.stdout.flush()


def rawincount(filename):
    f = open(filename, 'rb')
    bufgen = takewhile(lambda x: x, (f.raw.read(1024*1024) for _ in repeat(None)))
    return sum( buf.count(b'\n') for buf in bufgen )


class Data:
	def __init__(self, path, nips, nops):
		self.read_data(path, nips, nops)

	def __repr__(self):
		return str(len(self)) + " rows with " + str(len(self.in_[0])) + " inputs and " + str(len(self.tg[0])) + " outputs."

	def read_data(self, path, nips, nops):
		self.in_, self.tg = [], []
		count = rawincount(path)
		i = 0
		print("Importing " + str(count))
		with open(path) as data_file:
			for line in data_file:
				update_progress(i/count)
				i += 1
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
filename = "training.data"
if len(sys.argv) > 1:
	filename = sys.argv[1]
data = Data('../data/' + filename, nips, nops)
print("model init")
t = tinn.Tinn(nips, nhid, nops)

for _ in range(1):
	print("Shuffle...")
	data.shuffle()
	error = 0
	print("Training pass..." + str(_) )
	i = 0
	count = len(data.in_)
	for in_, tg in zip(data.in_, data.tg):
		error += tinn.xttrain(t, in_, tg, rate)
		update_progress(i/count)
		i += 1
	print()
	print("error " + str(error/len(data)) + " :: learning rate " + str(rate))
	rate *= anneal

in_ = data.in_[0]
tg = data.tg[0]
pd = tinn.xtpredict(t, in_)
print(' '.join(map(str, tg)))
print(' '.join(map(str, pd)))

# export KickAss fixed point lookups, neurons and biases 

output = open("../output/biases.asm","w")
output.write("// Biases: \n")
output.write(".align $100 \n")
output.write("t_biases: \n")
for i in t.b:
	do_output(output, i)
output.close()

output = open("../output/t_x1.asm","w")
output.write("// Input to Hidden: \n")
output.write(".align $100 \n")
output.write("t_x1: \n")
for i in t.x1:
	for j in i:
		do_output(output, j)
output.close()

output = open("../output/t_x2.asm","w")
output.write("// Hidden to Output: \n")
output.write(".align $100 \n")
output.write("t_x2: \n")
for i in t.x2:
	for j in i:
		do_output(output, j)
output.close()
