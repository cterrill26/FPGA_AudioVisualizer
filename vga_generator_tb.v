module vga_generator_tb;

	parameter DATA_WIDTH = 18;
	parameter ADDR_WIDTH = 9;
	
	reg done, vga_clk, FFT_clk, rst;
	reg [(DATA_WIDTH-1):0] FFT_data_r, FFT_data_i;
	wire [(ADDR_WIDTH-2):0] FFT_addr;
	wire [3:0] VGA_R;
	wire [3:0] VGA_G, VGA_B;
	wire VGA_HS,	VGA_VS;
	
	vga_generator
	#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
	DUT
	(
		.done(done), 
		.vga_clk(vga_clk), 
		.FFT_clk(FFT_clk), 
		.rst(rst),
		.FFT_data_r(FFT_data_r), 
		.FFT_data_i(FFT_data_i),
		.FFT_addr(FFT_addr),
		.VGA_R(VGA_R), 
		.VGA_G(VGA_G), 
		.VGA_B(VGA_B),
		.VGA_VS(VGA_VS)
	);
	
	
	always 
	begin
		#5; 
		vga_clk = ~vga_clk;
		FFT_clk = ~FFT_clk;
		
		#5; 
		vga_clk = ~vga_clk;
		FFT_clk = ~FFT_clk;
		FFT_data_r = $random;
		FFT_data_i = $random;
	end
	
	initial
	begin
		vga_clk = 0;
		FFT_clk = 0;
		rst  = 0;
		done = 0;
		
		#20;	
		rst = 1;
		
		
		#60;
		done = 1;
		
		#10;
		done = 0;
		
		
		
	end

endmodule
