# Journal

## 2021-08-05:
First journal entry and it's late in the development cycle, but I wanted to record the rest of this process at least. One day I will write more here - for now - quick catchup:

* I started this project years ago but have been on a rollercoaster with changing careers so C64 never got much time
* Keep coming back to this because I really like the idea and I got some fresh inspiration this year
* My new job is based on imaging science in medical research and I have had to write thousands of lines of Python and also learn a heap more about modern AI so all of the Python side of this project is vastly improved from the janky place it started. This might have been my first Python project in fact.

Last night was 6502 night - hanging out with my Dad while he watched a TV show about the history of India I finished writing the forward propagation and activation functions in assembler. I think the first time I tried for some crazy reason to avoid using zeropage for this (!) but I must have been clinically insane. The new version of the fixedpoint math library is actually pretty good for doing this efficiently. 

Todo that I can't forget about from last night:
* test harness for nn2 - comparative validation between 6502 fixed point and python floating point implementations (both using a LUT for the activation functions)
* test activation function
* fix for math.mul to shadow x and y 
* copy some MNIST images to C64 bytemaps so I can do 1:1 validation

Ideas not to forget about:
* How would I extend math library to handle matrices? (dot product)
* Test the use of sigmoid activation for convolutional network (most use RELU)

## 2021-08-06:
Done tonight:
* Fix math.mul shadowing
* Added some documentation to the code as I went
* Moved around some test code and general test area cleanup
* Set up `test-nn` target
* fixed the `test-nn.asm` to work with nn2.asm and math.asm
* First pass of debug on nn2.asm amd put restructured the build so I can test the MNIST model without the loader

Todo not to forget about:
1. copy some mnist bytemaps 
2. routine to replace SCREEN_BUFFER with a test bytemap
3. test signmoid activation_function
4. test nn_forward_propagate classifier

## 2021-08-12:
Working on the NN test suite. At the moment there are some placeholder outputs in the activation function - which seems to be working now. The only issue is that I think that the resolution of the activation function may be too low for the network. Currently the forward propagation is failing.

 

