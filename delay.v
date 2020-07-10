module delay
#(parameter WIDTH = 1, parameter CYCLES = 1)
(
	input clk,
	input [(WIDTH-1):0] data_in,
	output [(WIDTH-1):0] data_out
);

	reg [(WIDTH-1):0] regs [(CYCLES-1):0];
	assign data_out = regs[CYCLES-1];
	
	integer i;
	
	always @ (posedge clk)
	begin
		regs[0] <= data_in;
		for (i = 1; i < CYCLES; i = i+1)
			regs[i] <= regs[i-1];
	end

endmodule
