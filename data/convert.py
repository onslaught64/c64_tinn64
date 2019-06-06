import numpy as np
import sys


def update_progress(progress):
    barLength = 20 # Modify this to change the length of the progress bar
    status = ""
    if isinstance(progress, int):
        progress = float(progress)
    if not isinstance(progress, float):
        progress = 0
        status = "error: progress var must be float\r\n"
    if progress < 0:
        progress = 0
        status = "Halt...\r\n"
    if progress >= 1:
        progress = 1
        status = "Done...\r\n"
    block = int(round(barLength*progress))
    text = "\rProgress: [{0}] {1}% {2}".format( "#"*block + "-"*(barLength-block), round(progress*100), status)
    sys.stdout.write(text)
    sys.stdout.flush()


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
img_lib.append("full_numpy_bitmap_teddy-bear.npy")
img_lib.append("full_numpy_bitmap_underwear.npy")
img_lib.append("full_numpy_bitmap_snake.npy")
img_lib.append("full_numpy_bitmap_square.npy")
img_lib.append("full_numpy_bitmap_submarine.npy")
img_lib.append("full_numpy_bitmap_toilet.npy")

img_idx = list()
img_idx.append("1 0 0 0 0 0 0 0 0 0") #cat
img_idx.append("0 1 0 0 0 0 0 0 0 0") #coffee
img_idx.append("0 0 1 0 0 0 0 0 0 0") #computer
img_idx.append("0 0 0 1 0 0 0 0 0 0") #po po
img_idx.append("0 0 0 0 1 0 0 0 0 0") #teddy 
img_idx.append("0 0 0 0 0 1 0 0 0 0") #undies
img_idx.append("0 0 0 0 0 0 1 0 0 0") #snake
img_idx.append("0 0 0 0 0 0 0 1 0 0") #square
img_idx.append("0 0 0 0 0 0 0 0 1 0") #sub
img_idx.append("0 0 0 0 0 0 0 0 0 1") #dunny

output = open("training.data","w")
for index in range(len(img_lib)):
    img_set = np.load(img_lib[index])
    max_count = len(img_set)
    cur_count = 0
    print("Processing " + img_lib[index])
    for img in img_set:
        line = ""
        s = rsz(fs_image(img))
        for i in range(osz):
            for j in range(osz):
                line = line + str(float(s[i][j])) + " "
        line = line + img_idx[index] + "\n"
        output.write(line)
        update_progress(cur_count/max_count)
        cur_count += 1
