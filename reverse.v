module reverse
#(parameter WIDTH = 6)
(
	input [(WIDTH-1):0] data_in,
	output [(WIDTH-1):0] data_out
);

	genvar i;
	
	generate
		for (i = 0; i < WIDTH; i = i + 1)
		begin : reversal
			assign data_out[i] = data_in[WIDTH-1-i];
		end
	endgenerate

endmodule
