# -*- coding: utf-8 -*-

from typing import List
import math
import random


# we make exponent a lookup so we can emulate it precisely in C64
exp_lut = list()
for i in range(256):
	exp_lut.append( 1 / (1 + math.exp(-((8 * (i/256))-4))) )

# for i in exp_lut:
# 	print(str(i))

class Tinn:
	def __init__(self, nips: int, nhid: int, nops: int):
		"""Build a new t object given number of inputs (nips), number of hidden neurons for the hidden layer (nhid), and number of outputs (nops)."""
		self.nips = nips  # number of inputs
		self.nhid = nhid
		self.nops = nops
		self.b = [random.random() - 0.5 for _ in range(2)]  # biases, Tinn only supports one hidden layer so there are two biases
		self.x1 = [[0] * nips for _ in range(nhid)]  # input to hidden layer
		self.h = [0] * nhid  # hidden layer
		self.x2 = [[random.random() - 0.5 for _ in range(nhid)] for _ in range(nops)]  # hidden to output layer weights
		self.o = [0] * nops  # output layer


def xttrain(t: Tinn, in_: float, tg: float, rate: float) -> float:
	"""Trains a t with an input and target output with a learning rate. Returns error rate of the neural network."""
	fprop(t, in_)
	bprop(t, in_, tg, rate)
	return toterr(tg, t.o)


def xtpredict(t: Tinn, in_: float) -> float:
	"""Returns an output prediction given an input."""
	fprop(t, in_)
	return t.o


def err(a: float, b: float) -> float:
	"""Error function."""
	return 0.5 * (a - b) * (a - b)


def pderr(a: float, b: float) -> float:
	"""Partial derivative of error function."""
	return a - b


def toterr(tg: List[float], o: List[float]) -> float:
	"""Total error."""
	return sum([err(tg[i], o[i]) for i in range(len(o))])

def act(a: float) -> float:
	"""Activation function."""
	if a > 4:
		return 1.0
	if a < -4: 
		return 0.0
	tmp = int(((a + 4) / 8) * 256)
	return exp_lut[tmp]
	# return 1 / (1 + math.exp(-a))


def pdact(a: float) -> float:
	"""Partial derivative of activation function."""
	return a * (1 - a)


def bprop(t: Tinn, in_: List[float], tg: float, rate: float) -> None:
	"""Back propagation."""
	for i in range(t.nhid):
		s = 0
		# Calculate total error change with respect to output.
		for j in range(t.nops):
			ab = pderr(t.o[j], tg[j]) * pdact(t.o[j])
			s += ab * t.x2[j][i]
			# Correct weights in hidden to output layer.
			t.x2[j][i] -= rate * ab * t.h[i]
		# Correct weights in input to hidden layer.
		for j in range(t.nips):
			t.x1[i][j] -= rate * s * pdact(t.h[i]) * in_[j]


def fprop(t: Tinn, in_: float) -> None:
	"""Forward propagation."""
	# Calculate hidden layer neuron values.
	for i in range(t.nhid):
		s = t.b[0]  # start with bias
		for j in range(t.nips):
			s += in_[j] * t.x1[i][j]
		t.h[i] = act(s)
	# Calculate output layer neuron values.
	for i in range(t.nops):
		s = t.b[1]  # start with bias
		for j in range(t.nhid):
			s += t.h[j] * t.x2[i][j]
		t.o[i] = act(s)
