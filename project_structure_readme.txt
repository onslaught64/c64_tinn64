Directory structure for this project...

.
├── bin 		contains project management commands, specifically project setup and some tools used by the Makefile for building datasets
├── data		source npy datasets should be here. Read more in the README.dm file to learn how to get these
├── example_output	example rendered files for those of us who don't have room for training data
├── original_assets	original graphics files for the demo
├── output		output of the training as assembly code that is linked to the C64 demo
├── pyTinn		Modified fixed-point python implementation of Tinn and related python training code
└── tinn-fe		C64 demo directory and Spindle configuration
    ├── rsrc		resource files used in the compilation process
    ├── spindle		spindle trackmo loader source code goes here (make this before anything else!)
    ├── src		actual C64 source code for the demo
    └── test		C64 unit tests (apparently thats a thing!) to test the math and neural network code

