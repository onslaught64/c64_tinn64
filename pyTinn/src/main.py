import sys
from defame.train import Train


def main():
    train = Train(sys.argv[1], sys.argv[2])
    train.train()
    train.export()


if __name__ == "__main__":
    main()
