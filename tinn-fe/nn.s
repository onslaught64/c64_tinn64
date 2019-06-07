/*
Notes on memory map:
Code $0800 -> $3000											= Base Data $3000
Model input->hidden = 256 inputs * 32 hiddens * 3 bytes 	= $6000 bytes		$3000 - $9000 
Model hidden->output = 32 hiddens * 10 outputs * 3 bytes 	= $3c0 bytes		$9000 - $
Neurons input = bytemap from picture = 256 bytes 			= $ff bytes			
Neurons hidden = 32 hiddens * 3 bytes						= $60 bytes
Neurons output = 10 outputs * 3 bytes						= $1e bytes

*/



/*


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

