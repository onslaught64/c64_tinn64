import math
from fixedpointnumber import FixedPointNumber 


def do_output(o, value:float, index):
	fp = FixedPointNumber(value)
	o.write(str(fp.render_selected_byte(index)) + "\n")


output = open("../output/exp_lut.asm","w")
print()
print("Rendering exponent lookup to file...")
output.write("// Activation Exponent Lookup: \n")
output.write(".align $100 \n")
output.write("exp_lut_lo: \n")
for i in range(256):
        do_output(output,( 1 / (1 + math.exp(-((8 * (i/256))-4)))),2)
output.write("exp_lut_med: \n")
for i in range(256):
        do_output(output,( 1 / (1 + math.exp(-((8 * (i/256))-4)))),1)
output.write("exp_lut_hi: \n")
for i in range(256):
        do_output(output,( 1 / (1 + math.exp(-((8 * (i/256))-4)))),0)
output.close()

