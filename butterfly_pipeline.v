module butterfly_pipeline
#(parameter DATA_WIDTH=8)
(
	input clk,
	input signed [(DATA_WIDTH-1):0] in_ar, in_ai, in_br, in_bi, twiddle_r, twiddle_i,
	output reg signed [(DATA_WIDTH-1):0] out_ar, out_ai, out_br, out_bi
);

	wire [(DATA_WIDTH-1):0] delay_in_ar, delay_in_ai;
	reg signed [(DATA_WIDTH-1):0] reg_product0_r, reg_product0_i, reg_product1_r, reg_product1_i;
	reg signed [(DATA_WIDTH-1):0] reg_product_r, reg_product_i;
	
	wire signed [((DATA_WIDTH*2)-1):0] product0_r, product0_i, product1_r, product1_i;
	assign product0_r = twiddle_r * in_br;
	assign product0_i = twiddle_r * in_bi;
	assign product1_r = twiddle_i * in_bi;
	assign product1_i = twiddle_i * in_br;
	
	delay
	#(.WIDTH(DATA_WIDTH), .CYCLES(2))
	delay_ar
	(
		.clk(clk),
		.data_in(in_ar),
		.data_out(delay_in_ar)
	);
	
	delay
	#(.WIDTH(DATA_WIDTH), .CYCLES(2))
	delay_ai
	(
		.clk(clk),
		.data_in(in_ai),
		.data_out(delay_in_ai)
	);
	
	always @ (posedge clk)
	begin
		//--cycle 1
		//complex multiply individual products
		reg_product0_r <= product0_r[((DATA_WIDTH*2)-2):(DATA_WIDTH-1)];
		reg_product0_i <= product0_i[((DATA_WIDTH*2)-2):(DATA_WIDTH-1)];
		reg_product1_r <= product1_r[((DATA_WIDTH*2)-2):(DATA_WIDTH-1)];
		reg_product1_i <= product1_i[((DATA_WIDTH*2)-2):(DATA_WIDTH-1)];
		
		//--cycle 2
		//complex multiply full result
		reg_product_r <= reg_product0_r - reg_product1_r;
		reg_product_i <= reg_product0_i + reg_product1_i;
		
		//--cycle 3
		//set outputs
		out_ar <= delay_in_ar + reg_product_r;
		out_ai <= delay_in_ai + reg_product_i;
		out_br <= delay_in_ar - reg_product_r;
		out_bi <= delay_in_ai - reg_product_i;
	end
endmodule
