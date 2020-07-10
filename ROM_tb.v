module ROM_tb;

	parameter DATA_WIDTH=18; 
	parameter ADDR_WIDTH=3;
	
	reg [(ADDR_WIDTH-1):0] addr;
	reg clk;
	wire [(DATA_WIDTH-1):0] q;
	
	ROM
	#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
	UUT
	(
		.addr(addr),
		.clk(clk), 
		.q(q)
	);
	
	
	always
	begin
		#5 clk = ~clk;
	end
	
	initial
	begin
		clk = 0;
		addr = 0;
		
		#20 addr = 1;
		#20 addr = 2;
		#20 addr = 3;
		#20 addr = 4;
	end
endmodule