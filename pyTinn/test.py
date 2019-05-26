#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import random
import tinn
from fixedpointnumber import FixedPointNumber 


class Data:
	def __init__(self, path, nips, nops):
		self.read_data(path, nips, nops)

	def __repr__(self):
		return f'{len(self)} rows with {len(self.in_[0])} inputs and {len(self.tg[0])} outputs.'

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
	o.write(str(fp) + " // " + str(value) + "\n")


nips = 256
nhid = 28
nops = 10
rate = 1.0
anneal = 0.998
data = Data('semeion.data', nips, nops)
t = tinn.Tinn(nips, nhid, nops)
for _ in range(1):
	data.shuffle()
	error = 0
	for in_, tg in zip(data.in_, data.tg):
		error += tinn.xttrain(t, in_, tg, rate)
	print(f'error {error/len(data)} :: learning rate {rate}')
	rate *= anneal

in_ = data.in_[0]
tg = data.tg[0]
pd = tinn.xtpredict(t, in_)
print(' '.join(map(str, tg)))
print(' '.join(map(str, pd)))

#todo: find the biggest and smallest numbers in the TINN export file!
rows = 0
biggest = 0.0
smallest = 0.0
longest = 0
longest_value = ""
numbers = list()

output = open("data.asm","w")
print()
print()
output.write("// Biases: \n")
for i in t.b:
	do_output(output, i)

output.write("// Input to Hidden: \n")
for i in t.x1:
	for j in i:
		do_output(output, j)
		
output.write("// Hidden to Output: \n")
for i in t.x2:
	for j in i:
		do_output(output, j)

output.close()

# for line in f:
# 	rows = rows + 1
# 	try:
# 		tmp = float(line.strip())
# 		if tmp > biggest:
# 			biggest = tmp
# 		if tmp < smallest:
# 			smallest = tmp
# 		tmpsz = len(str(tmp))
# 		if tmpsz > longest:
# 			longest = tmpsz
# 			longest_value = str(tmp)
# 		fp = FixedPointNumber(tmp)
# 		print(" " + str(fp) + " -> " + str(tmp))
# 		print()
# 	except ValueError:
# 		print(str(rows) + " is not a float")

# print(str(rows) + " rows...")
# print(str(biggest) + " biggest...")
# print(str(smallest) + " smallest...")
# print(longest_value + " is " + str(longest))






