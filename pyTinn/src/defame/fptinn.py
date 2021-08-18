# -*- coding: utf-8 -*-

from typing import List
import math
import random
import numpy as np

from defame.exp_lut import ExpLut
from defame.fixedpointnumber import FixedPointNumber

"""
Build a new t object given number of inputs (nips), number of hidden neurons for the hidden layer (nhid), and number of outputs (nops).
"""


class Tinn(object):
    def __init__(self, nips: int, nhid: int, nops: int):
        self.nips = nips  # number of inputs
        self.nhid = nhid
        self.nops = nops
        self.b = [random.random() - 0.5 for _ in
                  range(2)]  # biases, Tinn only supports one hidden layer so there are two biases
        self.x1 = [[0] * nips for _ in range(nhid)]  # input to hidden layer
        self.h = [0] * nhid  # hidden layer
        self.x2 = [[random.random() - 0.5 for _ in range(nhid)] for _ in range(nops)]  # hidden to output layer weights
        self.o = [0] * nops  # output layer
        # we make exponent a lookup so we can emulate it precisely in C64
        self.lut: ExpLut = ExpLut()

    def xttrain(self, in_: [float], tg: [float], rate: float) -> float:
        """Trains a t with an input and target output with a learning rate. Returns error rate of the neural network."""
        self.fprop(in_)
        self.bprop(in_, tg, rate)
        return self.toterr(tg, self.o)

    def xtpredict(self, in_: [float]) -> [float]:
        """Returns an output prediction given an input."""
        self.fprop(in_)
        return self.o

    def err(self, a: float, b: float) -> float:
        """Error function."""
        return 0.5 * (a - b) * (a - b)

    def pderr(self, a: float, b: float) -> float:
        """Partial derivative of error function."""
        return a - b

    def toterr(self, tg: [float], o: [float]) -> float:
        """Total error."""
        return sum([self.err(tg[i], o[i]) for i in range(len(o))])

    def act(self, a: float) -> float:
        """Activation function."""
        fpn: FixedPointNumber = self.lut.eval(a)
        return fpn.value
        # return 1 / (1 + math.exp(-a))

    def pdact(self, a: float) -> float:
        """Partial derivative of activation function."""
        return a * (1 - a)

    def bprop(self, in_: [float], tg: [float], rate: float) -> None:
        """Back propagation."""
        for i in range(self.nhid):
            s = 0
            # Calculate total error change with respect to output.
            for j in range(self.nops):
                ab = self.pderr(self.o[j], tg[j]) * self.pdact(self.o[j])
                s += ab * self.x2[j][i]
                # Correct weights in hidden to output layer.
                self.x2[j][i] -= rate * ab * self.h[i]
            # Correct weights in input to hidden layer.
            for j in range(self.nips):
                self.x1[i][j] -= rate * s * self.pdact(self.h[i]) * in_[j]

    def map_to_fp(self):
        # copy the trained kernel to FixedPoint so we can treat our predictions
        # just like as if it was coming from the 6502.
        pass

    def fpfprop(self, in_: [float]) -> None:
        """Forward propagation."""
        # Calculate hidden layer neuron values.
        lut = ExpLut()
        for i in range(self.nhid):
            s = FixedPointNumber(self.b[0])  # start with bias
            for j in range(self.nips):
                inj = FixedPointNumber(in_[j])
                xij = FixedPointNumber(self.x1[i][j])
                o = FixedPointNumber.op(inj, xij, "*")
                s = FixedPointNumber.op(o, s, "+")
                # s += in_[j] * self.x1[i][j]
            self.h[i] = lut.eval(s.value)
        # Calculate output layer neuron values.
        for i in range(self.nops):
            s = FixedPointNumber(self.b[1])  # start with bias
            for j in range(self.nhid):
                hj = FixedPointNumber(self.h[j])
                xij = FixedPointNumber(self.x2[i][j])
                o = FixedPointNumber.op(hj, xij, "*")
                s = FixedPointNumber.op(o, s, "+")
                # s += self.h[j] * self.x2[i][j]
            self.o[i] = lut.eval(s.value)
