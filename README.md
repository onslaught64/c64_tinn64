# Quick! Draw! 64!


The AI in this project is based on pyTinn
https://github.com/nvalis/pyTinn



which is a port of the amazing Tinn
https://github.com/glouw/tinn


I was inspired that the actual trained neural net is very compact. How could Tinn be adapted to work on a smaller computer? Well, I have modified the pyTinn code to export 24bit fixed point data and use a lookup based activation function instead of calculating the exponent of e every time. Thus, Q!D!64! was born. 

Initially, I used the dataset that Tinn comes with - which is the NIST handwriting database. But then, what fun would that be? Instead wouldn't it be awesome if we could have a network that was trained on millions of doodles! 

Q!D!64! allows the user to draw on their favourite 8 bit machine and then it runs the perceptron network on the classic hardware classifying the image. Yes, we have ported modern AI to a C64. 


## Requirements
This codebase expects you to be on linux. If you are trying to make this work on Windows, install WSL2 and Ubuntu first.

There needs to be a command called `kick` which takes the name of the file being assembled as its parameters. This wrapper should call the Kick Assembler jar file ( http://theweb.dk/KickAssembler/Main.html#frontpage )


## Step 1: Installation
Just use `make install`

## Step 2: Download Training Data
Download the following files to the `test/` directory  
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

## Step 3: Convert Training Data
Type `make convert`

## Step 4: Train Your Neural Networks 
There are two nets to train, one for MNIST (numeral recognition) and one for Quick! Draw! with 10 drawings to classify.

Type `make train_mnist` and then `make train_qd` to train both datasets. These will create the required asm files and put them into the appropriate directory. 

To finally compile the C64 demo, use `make clean` and then `make disk.d64` 

--------------------------

This python code trains the neural network and configures all weights and biases for the intermediate and output layers of the network and saves them as 24 bit fixed-point values. There is also a specially crafted set of lookup values that are used when the input value of the activation function is within range. Basically, a sigmoidal activation function required the exponent of e as follows: `activation value = 1 / 1 + e^-input value` which, you can imagine would suck to calculate on a 6502, however the actual range of values that fall inside the curve between 0 and 1 is an input range of 8, so, hey, we calculate the activation function for the input range -4 to +4 in a lookup table instead.

Actually, to ensure that the AI is trained using the same activation function, this lookup strategy is also used in the modified pyTinn Python training code for forward propoagation. 

This great article on activation functions helps a lot:
https://towardsdatascience.com/activation-functions-neural-networks-1cbd9f8d91d6




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


