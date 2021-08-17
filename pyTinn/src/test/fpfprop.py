from defame.train import Train
from defame.fixedpointnumber import FixedPointNumber
import sys

def main():
    train = Train(sys.argv[1])
    train.train()



if __name__ == "__main__":
    main()
