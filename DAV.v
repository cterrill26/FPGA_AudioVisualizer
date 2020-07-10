module DAV
#(parameter ADDR_WIDTH = 9, parameter DATA_WIDTH = 22, parameter MIC_BITS = 18)
(
	input clk, rst, DOUT,
	output BCLK, LRCLK,
	output [3:0] VGA_R, VGA_G, VGA_B,
	output VGA_HS,	VGA_VS
);
	
	wire clk_50M = clk;
	wire clk_2M5, clk_25M;
	
	wire start, mic_we;
	wire [(ADDR_WIDTH-1):0] mic_addr;
	wire [(MIC_BITS-1):0] mic_data;
	wire [(ADDR_WIDTH-2):0] vga_addr;
	wire [(DATA_WIDTH-1):0] vga_data_r, vga_data_i;
	wire done;
	
	
	clkdiv
	#(.THRESHOLD(0))
	generate_clk_25M
	(
		.clk_in(clk_50M),
		.clk_out(clk_25M)
	);
	
	clkdiv
	#(.THRESHOLD(9))
	generate_clk_2M5
	(
		.clk_in(clk_50M),
		.clk_out(clk_2M5)
	);
	
	mic_translator
	#(.ADDR_WIDTH(ADDR_WIDTH), .MIC_BITS(MIC_BITS))
	mic
	(
		.clk(clk_2M5), 
		.rst(rst),
		.BCLK(BCLK),
		.DOUT(DOUT),
		.LRCLK(LRCLK),
		.mic_we(mic_we),
		.mic_addr(mic_addr),
		.mic_data(mic_data),
		.start(start)
	);
	
	
	FFT_processor
	#(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MIC_BITS(MIC_BITS))
	FFT
	(
		.clk(clk_2M5), 
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
	
	vga_generator
	#(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_DATA_WIDTH(9))
	vga
	(
		.done(done),
		.vga_clk(clk_25M), 
		.FFT_clk(clk_2M5), 
		.rst(rst),
		.FFT_addr(vga_addr),
		.FFT_data_r(vga_data_r),
		.FFT_data_i(vga_data_i),
		.VGA_R(VGA_R), 
		.VGA_G(VGA_G), 
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),	
		.VGA_VS(VGA_VS)
	);

endmodule
