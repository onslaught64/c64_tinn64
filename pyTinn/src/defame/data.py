import random
from tqdm import tqdm


class Data(object):
    def __init__(self, path, nips, nops):
        self.ins = []
        self.tg = []
        self.read_data(path, nips, nops)

    def __repr__(self):
        return str(len(self)) + " rows with " + str(len(self.ins[0])) + " inputs and " + str(
            len(self.tg[0])) + " outputs."

    def read_data(self, path, nips, nops):
        i = 0
        with open(path) as data_file:
            for line in tqdm(data_file):
                i += 1
                row = list(map(float, line.split()))
                self.ins.append(row[:nips])
                self.tg.append(row[nips:])

    def shuffle(self):
        indexes = list(range(len(self.ins)))
        random.shuffle(indexes)
        self.ins = [self.ins[i] for i in indexes]
        self.tg = [self.tg[i] for i in indexes]

    def __len__(self):
        return len(self.ins)
