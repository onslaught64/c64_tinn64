# Quick! Draw! 64!


The AI in this project is based on pyTinn
https://github.com/nvalis/pyTinn



which is a port of the amazing Tinn
https://github.com/glouw/tinn


I was inspired that the actual trained neural net is very compact. How could Tinn be adapted to work on a smaller computer? Well, I have modified the pyTinn code to export 24bit fixed point data and use a lookup based activation function instead of calculating the exponent of e every time. Thus, Q!D!64! was born. 

Initially, I used the dataset that Tinn comes with - which is the NIST handwriting database. But then, what fun would that be? Instead wouldn't it be awesome if we could have a network that was trained on millions of doodles! 

Q!D!64! allows the user to draw on their favourite 8 bit machine and then it runs the perceptron network on the classic hardware classifying the image. Yes, we have ported modern AI to a C64. 


## Step 1: Installation
install Anaconda 3
run `setup.sh demo` the first time to create the Anaconda environment for this demo
type `source activate demo`
run `setup.sh demo` again... in future, you need only do this once

## Step 2: Download and Convert Training Data
Download the following files to the `test/` directory and run `python convert.py` 
* https://storage.cloud.google.com/quickdraw_dataset/full/numpy_bitmap/cat.npy
* https://storage.cloud.google.com/quickdraw_dataset/full/numpy_bitmap/coffee%20cup.npy
* https://storage.cloud.google.com/quickdraw_dataset/full/numpy_bitmap/computer.npy
* https://storage.cloud.google.com/quickdraw_dataset/full/numpy_bitmap/police%20car.npy
* https://storage.cloud.google.com/quickdraw_dataset/full/numpy_bitmap/teddy-bear.npy
* https://storage.cloud.google.com/quickdraw_dataset/full/numpy_bitmap/underwear.npy
* https://storage.cloud.google.com/quickdraw_dataset/full/numpy_bitmap/snake.npy
* https://storage.cloud.google.com/quickdraw_dataset/full/numpy_bitmap/square.npy
* https://storage.cloud.google.com/quickdraw_dataset/full/numpy_bitmap/submarine.npy
* https://storage.cloud.google.com/quickdraw_dataset/full/numpy_bitmap/toilet.npy

If you want to recognize other drawings, download the training set from the Quick! Draw! site here:
https://console.cloud.google.com/storage/browser/quickdraw_dataset/full/numpy_bitmap

Finally, open a shell, do the following from the project root:
```
cd data
source activate demo
python convert.py
```

## Step 3: Train the Neural Network and Export Trained Neurons and Biases
Open a shell, do the following from the project root:
```
cd pyTinn
source activate demo
python train.py
```
...and wait...

This trains the neural network and configures all weights and biases for the intermediate and output layers of the network and saves them as 24 bit fixed-point values 

...then do the following for the final data file to be generated...
```
python export_exp.py
```
This exports a specially crafted set of lookup tables that are used when the input value of the activation function is within range. Basically, a sigmoidal activation function required the exponent of e as follows:

`activation value = 1 / 1 + e^-input value` which, you can imagine would suck to calculate on a 6502, however the actual range of values that fall inside the curve between 0 and 1 is an input range of 8, so, hey, we calculate the activation function for the input range -4 to +4 in a lookup table instead.

This great article on activation functions helps a lot:
https://towardsdatascience.com/activation-functions-neural-networks-1cbd9f8d91d6

## Step 4: Build and Run
Open a shell, do the following from the project root:
```
cd tinn-fe
build
```
This expects to have a command called `kick` that will invoke Kick Assembler and also expects Vice to be installed and working using the command `x64`

## Extra Developer Notes
Read the code comments in `tinn-fe/nn.s` to understand how we mapped the activation function in python to one that works on a 6502 using only 24 bit multiplication and addition.


The following files are for unit testing the `math.s` library:
```
run-test
test-math.s
```

simply use `run-test` to compile a set of unit tests. It's quick and dirty, but it gets the job done. You will find that sometimes the tests fail because I am using zeropage of BASIC and the BASIC interrupts are still running. I was not fussed with fixing this, but it's easy to do if you ever want to take your unit testing really seriously.


Also, you will notice that the negation code is not tested explicitly, just implicitly - I had to figure out if it was working by hand - pretty much as the first thing I did writing the math library... 


While I am on the topic of the math library, I had considered making this by using floating point math, but it was so messy and I really struggled understanding the floating point math principles. As I was reading a book on John Carmack's DOOM engine I saw he did everything using fixed point, so I started trying to wrap my head around fixed and it seemed right, but I didn't quite understand when my math library was doing multiplcation how the fractions would do weird things, until I finally read this article on fixed point math and everything made sense: https://spin.atomicobject.com/2012/03/15/simple-fixed-point-math/ awesome article. 


I have tried to keep links to the code that helped inspire or clarify areas as well as direct usage wherever possible. If you think this is not the case, just let me know and I will update comments accordingly.

