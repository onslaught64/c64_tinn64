import sys
from defame.exp_lut import ExpLut
from defame.train import Train


def main():
    train = Train(sys.argv[1])
    train.train()
    exp = ExpLut()
    output = open(sys.argv[2], "w")
    train.render_labels(output)
    exp.render_labels(output)
    exp.render(output)
    train.render(output)
    output.close()


if __name__ == "__main__":
    main()
