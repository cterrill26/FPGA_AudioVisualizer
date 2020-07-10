# FPGA_AudioVisualizer
Verilog code for an efficient and scalable DFT calculator (using the FFT algorithm). Meant to be implemented on an Intel DE10-Lite FPGA development board. Reads audio data from an external mic and displays the frequency components on a VGA monitor.

This project is inspired by Kenny Chan's (@kennych418) repo of the same name, and sections of the Verilog from the mic translator and VGA generator are draw directly from his project. The architecture of the FFT processor is drawn from [this](http://web.mit.edu/6.111/www/f2017/handouts/FFTtutorial121102.pdf?fbclid=IwAR1bvgwIdH4KpCR6y5HdHb4cVpvUhySQTUzOMBI4a99tWIJc6waVf-O8PHQ) paper.

## To Run
Create a new Quartus project, select the device you wish to use, and import the files in this repo (besides this README) into the project. Click Assignment -> Device, then click Device and Pin Options. Select the Configuration option on the left, and for Configuration mode select Single Uncompressed Image with Memory Initialization. 

Open the twiddle_script.py file and edit **data_width** to the number of bits you will carry in the FFT calculation, and edit the **addr_width** to log<sub>2</sub>(s), where s is the number of samples you wish to take. Running this script in your project folder will generate **rom_r_init.txt** and **rom_i_init.txt**, which are used to initialize the ROMs which hold the twiddle values for the FFT calculation. 

Similarly setting the **DATA_WIDTH** and **ADDR_WIDTH** parameters in DAV.v will cause these parameters to trickle down to the rest of the design units. Note that though much of the design units will adjust nicely based on these parameters, not everything will work immediately. Mainly, the interface between the FFT processor and the VGA generator requires **ADDR_WIDTH** to be an odd number (a small change needs to be made if **ADDR_WIDTH** is even), and the VGA generator output logic for VGA_R is hard coded to work for a 512-point DFT calculation. 

Finally, use the Quartus Pin Planner to associate the top module's ports to physical pins on the FPGA.

## Overview
I will write a more detailed design description when I get a chance. For now, I will provide a super brief description of what is going on. 

The mic translator continuously reads audio data and fills the mic FIFO, which holds the data for one set of samples. Once this FIFO is filled, the data will be read out of the FIFO and written into one of the memories used in the FFT processor. Once the data is transferred, a start signal is sent to the FFT processor, which will start the DFT calculation. 

The idea behind the architecture of the FFT processor can be understood by reading the paper linked in the second paragraph of this README. 

Once the DFT calculation is done, the VGA generator reads the transform data out of one of the FFT memories, passes it through a complex magnitude estimator, and writes the result into the VGA FIFO (it’s not really a FIFO, but that's what I call it). As the VGA logic scans across the screen from left to right, the values are read from the memory one by one and compared to the vertical counter to determine whether to light up the pixel or not. Instead of showing all 512 points of the frequency data (about half of which are redundant due to the input signal being real), this design only displays frequencies 1 to 256 (inclusive, counting from 0) from the DFT calculation. With 256 points being displayed and 640 horizontal pixels assumed for the VGA monitor, each point gets 2.5 pixels. To accomplish this, the frequency points are alternately assigned 2 then 3 pixels each, allowing for the 256 frequency points to fill the whole display. 

The sampling rate of the mic translator is about 39 kHz. With 256 frequencies being displayed, the frequency range of the output is about 76 Hz to 19.5 kHz, which is approximately equal to the human range of hearing.
