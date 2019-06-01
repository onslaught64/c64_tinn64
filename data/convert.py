import numpy as np
from progress.bar import Bar


osz = 16
sz = 28
sample = 1.75
thresh = 1 

def fs_image(source):
    output = [[int for i in range(sz)] for j in range(sz)]
    col = 0
    row = 0
    for i in range(len(source)):
        output[row][col] = source[i]
        col = col + 1
        if col == sz:
            col = 0
            row += 1
    return output


def rsz(source):
    output = [[int for i in range(osz)] for j in range(osz)]
    srow = 0
    scol = 0    
    for row in range(osz):
        for col in range(osz):
            output[row][col] = 1 if source[int(round(srow))][int(round(scol))] > thresh else 0
            scol += sample
        scol = 0
        srow += sample
    return output

"""
0 full_numpy_bitmap_cat.npy
1 full_numpy_bitmap_coffee cup.npy
2 full_numpy_bitmap_computer.npy
3 full_numpy_bitmap_police car.npy
4 full_numpy_bitmap_rainbow.npy
5 full_numpy_bitmap_underwear.npy
6 full_numpy_bitmap_snake.npy
7 full_numpy_bitmap_square.npy
8 full_numpy_bitmap_submarine.npy
9 full_numpy_bitmap_toilet.npy
"""

img_lib = list()
img_lib.append("full_numpy_bitmap_cat.npy")
img_lib.append("full_numpy_bitmap_coffee cup.npy")
img_lib.append("full_numpy_bitmap_computer.npy")
img_lib.append("full_numpy_bitmap_police car.npy")
img_lib.append("full_numpy_bitmap_rainbow.npy")
img_lib.append("full_numpy_bitmap_underwear.npy")
img_lib.append("full_numpy_bitmap_snake.npy")
img_lib.append("full_numpy_bitmap_square.npy")
img_lib.append("full_numpy_bitmap_submarine.npy")
img_lib.append("full_numpy_bitmap_toilet.npy")

img_idx = list()
img_idx.append("1 0 0 0 0 0 0 0 0 0")
img_idx.append("0 1 0 0 0 0 0 0 0 0")
img_idx.append("0 0 1 0 0 0 0 0 0 0")
img_idx.append("0 0 0 1 0 0 0 0 0 0")
img_idx.append("0 0 0 0 1 0 0 0 0 0")
img_idx.append("0 0 0 0 0 1 0 0 0 0")
img_idx.append("0 0 0 0 0 0 1 0 0 0")
img_idx.append("0 0 0 0 0 0 0 1 0 0")
img_idx.append("0 0 0 0 0 0 0 0 1 0")
img_idx.append("0 0 0 0 0 0 0 0 0 1")

output = open("training.data","w")
for index in range(len(img_lib)):
    img_set = np.load(img_lib[index])
    print("Processing " + img_lib[index] + "\n")
    max_count = len(img_set)
    with Bar('Processing', max=max_count) as bar:
        for img in img_set:
            line = ""
            s = rsz(fs_image(img))
            for i in range(osz):
                for j in range(osz):
                    line = line + str(float(s[j][i])) + " "
            line = line + img_idx[index] + "\n"
            output.write(line)   
            bar.next()     
