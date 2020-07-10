module FFT_mem
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
(
	input [(DATA_WIDTH-1):0] data_ar, data_ai, data_br, data_bi,
	input [(ADDR_WIDTH-1):0] addr0_a, addr0_b, addr1_a, addr1_b,
	input we_a, we_b, we_sel, q_sel, clk,
	output reg [(DATA_WIDTH-1):0] q_ar, q_ai, q_br, q_bi,
	output [(DATA_WIDTH-1):0] vga_data_r, vga_data_i

);

	wire [DATA_WIDTH-1:0] q0_ar, q0_ai, q0_br, q0_bi, q1_ar, q1_ai, q1_br, q1_bi;

	assign vga_data_r = q1_ar;
	assign vga_data_i = q1_ai;
	
	mem_dp
	#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
	mem_dp0_r 
	(
		.data_a(data_ar),
		.data_b(data_br),
		.addr_a(addr0_a),
		.addr_b(addr0_b),
		.we_a(we_a & (~we_sel)),
		.we_b(we_b & (~we_sel)),
		.clk(clk),
		.q_a(q0_ar),
		.q_b(q0_br)
	);
	
	mem_dp
	#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
	mem_dp0_i 
	(
		.data_a(data_ai),
		.data_b(data_bi),
		.addr_a(addr0_a),
		.addr_b(addr0_b),
		.we_a(we_a & (~we_sel)),
		.we_b(we_b & (~we_sel)),
		.clk(clk),
		.q_a(q0_ai),
		.q_b(q0_bi)
	);
	
	mem_dp
	#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
	mem_dp1_r 
	(
		.data_a(data_ar),
		.data_b(data_br),
		.addr_a(addr1_a),
		.addr_b(addr1_b),
		.we_a(we_a & we_sel),
		.we_b(we_b & we_sel),
		.clk(clk),
		.q_a(q1_ar),
		.q_b(q1_br)
	);
	
	mem_dp
	#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
	mem_dp1_i 
	(
		.data_a(data_ai),
		.data_b(data_bi),
		.addr_a(addr1_a),
		.addr_b(addr1_b),
		.we_a(we_a & we_sel),
		.we_b(we_b & we_sel),
		.clk(clk),
		.q_a(q1_ai),
		.q_b(q1_bi)
	);

	
	always @ (posedge clk)
	begin
		if (q_sel)
		begin
			q_ar <= q1_ar;
			q_ai <= q1_ai;
			q_br <= q1_br;
			q_bi <= q1_bi;
		end
		else
		begin
			q_ar <= q0_ar;
			q_ai <= q0_ai;
			q_br <= q0_br;
			q_bi <= q0_bi;
		end
	end

endmodule
