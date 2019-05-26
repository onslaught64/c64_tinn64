from fixedpointnumber import FixedPointNumber 


def fp(value: float):
    f = FixedPointNumber(value)
    print("BINARY:" + str(f) + " FLOAT:" + str(value))

fp(1.0)
fp(0.5)
fp(-0.5)
fp(-1.0)
fp(16.0)
fp(-16.0)
fp(0.000000001)
fp(0.999999999)
fp(-0.000000001)
fp(-0.999999999)

