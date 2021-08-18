from tqdm import tqdm

from defame.data import Data
from defame.tinn import Tinn
from defame.train import Train
from defame.fixedpointnumber import FixedPointNumber
import sys


class FPTrain(object):
    def __init__(self, filename: str):
        self.nips = 256
        self.nhid = 32
        self.nops = 10
        self.rate = 1.0
        self.anneal = 0.998
        self.training_passes = 10
        print("loading training data")
        self.data = Data(filename, self.nips, self.nops)
        print("model init")
        self.t = Tinn(self.nips, self.nhid, self.nops)

    def __do_output(self, o, value: float):
        fp = FixedPointNumber(value)
        o.write(str(fp) + "\n")

    def train(self):
        for _ in range(self.training_passes):
            # print("Shuffle...")
            self.data.shuffle()
            error = 0
            print("Training pass..." + str(_))
            i = 0
            count = len(self.data.ins)
            for in_, tg in tqdm(zip(self.data.ins, self.data.tg), leave=False):
                if i > 10:
                    error += self.t.xttrain(in_, tg, self.rate)
                i += 1
            print("error " + str(error / len(self.data)) + " :: learning rate " + str(self.rate))
            print()
            self.rate *= self.anneal
        for i in range(50):
            in_ = self.data.ins[i]
            tg = self.data.tg[i]
            pd = self.t.xtpredict(in_)
            # print(' '.join(map(str, tg)))
            # print(' '.join(map(str, pd)))
            correct = 0
            for j in range(len(tg)):
                if tg[j] > 0:
                    correct = j
            pmax = 0
            pidx = -1
            for j in range(len(pd)):
                if pd[j] > pmax:
                    pmax = pd[j]
                    pidx = j
            print("PASS " + str(i) + " VALUE:" + str(correct) + " PREDICTION:" + str(pidx) + (
                "FAIL!" if pidx != correct else ""))


def main():
    train = Train(sys.argv[1])
    train.train()


if __name__ == "__main__":
    main()
