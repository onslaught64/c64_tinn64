
/*
Implement Tinn in 6502!!

exp_lut = list()

for i in range(256):
	exp_lut.append( 1 / (1 + math.exp(-((8 * (i/256))-4))) )

for i in exp_lut:
	print(str(i))


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

def act(a: float) -> float:
	"""Activation function."""
	if a > 4:
		return 1.0
	if a < -4: 
		return 0.0
	tmp = int(((a + 4) / 8) * 256)
	return exp_lut[tmp]
	# return 1 / (1 + math.exp(-a))

*/
