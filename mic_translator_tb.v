module mic_translator_tb;

	parameter ADDR_WIDTH = 3;
	parameter DATA_WIDTH = 18;
	
	reg clk = 1;
	reg rst = 1; 
	reg DOUT = 0;
	wire start;
	wire BCLK, LRCLK, mic_we;
	wire [(ADDR_WIDTH-1):0] mic_addr;
	wire [(DATA_WIDTH-1):0] mic_data;
	
	mic_translator
	#(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH))
	DUT
	(
		.clk(clk), 
		.rst(rst), 
		.DOUT(DOUT),
		.start(start),
		.BCLK(BCLK), 
		.LRCLK(LRCLK), 
		.mic_we(mic_we),
		.mic_addr(mic_addr),
		.mic_data(mic_data)
	);
	
	always 
	begin
		#10
		clk = ~clk;
		DOUT = $random;
		#10
		clk = ~clk;
	end
	
	initial 
	begin
		#25;
		rst = 0;
		#30;
		rst = 1;
	end
endmodule
