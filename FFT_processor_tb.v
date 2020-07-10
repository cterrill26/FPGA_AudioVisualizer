module FFT_processor_tb;

	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 18;
	//depending on your compiler, you might need to add a single quote (') before the open bracket ({)
	parameter integer samples[0:2**ADDR_WIDTH-1] = {424, 326, -426, 401, 10, 140, -61, 208, -163, -345, -455, -420, -389, 95, 374, -65, 90, 435, -421, -127, -356, 111, 256, 465, -462, 47, -349, 111, -99, 220, 245, -193};
	integer i;
	
	reg clk, rst, start;
	reg mic_we;
	reg [(ADDR_WIDTH-1):0] mic_addr;
	reg [(DATA_WIDTH-1):0] mic_data;
	reg [(ADDR_WIDTH-1):0] vga_addr;
	wire [(DATA_WIDTH-1):0] vga_data_r, vga_data_i;
	wire done;
	
	FFT_processor
	#(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH))
	DUT
	(
		.clk(clk), 
		.rst(rst), 
		.start(start),
		.mic_we(mic_we),
		.mic_addr(mic_addr),
		.mic_data(mic_data),
		.vga_addr(vga_addr),
		.vga_data_r(vga_data_r), 
		.vga_data_i(vga_data_i),
		.done(done)
	);
	
	always
	begin
		#5 clk = ~clk;
	end
	
	initial 
	begin
		clk = 0;
		rst = 0;
		start = 0;
		mic_we = 0;
		mic_addr = 0;
		mic_data = 0;
		vga_addr = 0;
		
		#20;
		rst = 1;
		
		#20;
		mic_we = 1;
		
		for (i = 0; i < 2**ADDR_WIDTH; i = i+1)
		begin
			mic_addr = i;
			mic_data = samples[i];
			#10;
		end

		mic_we = 0;
		
		#20;
		start = 1;
		#10;
		start = 0;
		
		while (~done)
			#10;
			
		for (i = 0; i < 2**ADDR_WIDTH; i = i+1)
		begin
			vga_addr = i;
			#10;
		end
	end
	
endmodule
