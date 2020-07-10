module FFT_controller_tb;

	parameter ADDR_WIDTH = 4;
	parameter DATA_WIDTH = 18;
	
	reg clk, rst, start;
	wire we_sel, q_sel;
	wire we_a, we_b;
	wire [(ADDR_WIDTH-1):0] addr0_a, addr0_b, addr1_a, addr1_b;
	wire [(DATA_WIDTH-1):0] twiddle_r, twiddle_i;
	wire done;
	
	FFT_controller
	#(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH))
	DUT
	(
		.clk(clk), 
		.rst(rst), 
		.start(start),
		.we_sel(we_sel), 
		.q_sel(q_sel),
		.we_a(we_a), 
		.we_b(we_b),
		.addr0_a(addr0_a), 
		.addr0_b(addr0_b), 
		.addr1_a(addr1_a), 
		.addr1_b(addr1_b),
		.twiddle_r(twiddle_r), 
		.twiddle_i(twiddle_i),
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
		
		#20;
		rst = 1;
		
		#20;
		start = 1;
		#10;
		start = 0;
	end
	
endmodule
