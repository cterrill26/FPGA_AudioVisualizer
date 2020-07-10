module FFT_processor
#(parameter DATA_WIDTH=18, parameter ADDR_WIDTH=5, parameter MIC_BITS = 18)
(
	input clk, rst, start,
	input mic_we,
	input [(ADDR_WIDTH-1):0] mic_addr,
	input [(MIC_BITS-1):0] mic_data,
	input [(ADDR_WIDTH-2):0] vga_addr,
	output [(DATA_WIDTH-1):0] vga_data_r, vga_data_i,
	output done
);

	wire [(DATA_WIDTH-1):0] mem_out_ar, mem_out_ai, mem_out_br, mem_out_bi;
	wire [(DATA_WIDTH-1):0] butterfly_out_ar, butterfly_out_ai, butterfly_out_br, butterfly_out_bi;
	wire [(ADDR_WIDTH-1):0] addr0_a, addr0_b, addr1_a, addr1_b;
	wire we_a, we_b, we_sel, q_sel;
	wire [(DATA_WIDTH-1):0] twiddle_r, twiddle_i;
	
	reg [(DATA_WIDTH-1):0] sel_mem_in_ar, sel_mem_in_ai, delay_mem_in_br, delay_mem_in_bi;
	
	
	FFT_mem
	#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
	mem
	(
		.data_ar(sel_mem_in_ar),
		.data_ai(sel_mem_in_ai),
		.data_br(delay_mem_in_br),
		.data_bi(delay_mem_in_bi),
		.addr0_a(addr0_a),
		.addr0_b(addr0_b),
		.addr1_a(addr1_a),
		.addr1_b(addr1_b),
		.we_a(we_a), 
		.we_b(we_b), 
		.we_sel(we_sel), 
		.q_sel(q_sel), 
		.clk(clk),
		.q_ar(mem_out_ar),
		.q_ai(mem_out_ai),
		.q_br(mem_out_br),
		.q_bi(mem_out_bi),
		.vga_data_r(vga_data_r), 
		.vga_data_i(vga_data_i)
	);

	butterfly_pipeline
	#(.DATA_WIDTH(DATA_WIDTH))
	butterfly
	(
		.clk(clk),
		.in_ar(mem_out_ar), 
		.in_ai(mem_out_ai), 
		.in_br(mem_out_br), 
		.in_bi(mem_out_bi), 
		.twiddle_r(twiddle_r),
		.twiddle_i(twiddle_i),
		.out_ar(butterfly_out_ar), 
		.out_ai(butterfly_out_ai), 
		.out_br(butterfly_out_br), 
		.out_bi(butterfly_out_bi)
	);
	
	FFT_controller
	#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
	controller
	(
		.clk(clk), 
		.rst(rst),
		.start(start),
		.we_a(we_a), 
		.we_b(we_b),
		.we_sel(we_sel),
		.q_sel(q_sel),
		.addr0_a(addr0_a), 
		.addr0_b(addr0_b), 
		.addr1_a(addr1_a), 
		.addr1_b(addr1_b),
		.twiddle_r(twiddle_r), 
		.twiddle_i(twiddle_i),
		.mic_we(mic_we),
		.mic_addr(mic_addr),
		.vga_addr(vga_addr),
		.done(done)
	);
	
	always @ (posedge clk)
	begin
		delay_mem_in_br <= butterfly_out_br;
		delay_mem_in_bi <= butterfly_out_bi;
		
		if(~done)
		begin
			sel_mem_in_ar <= butterfly_out_ar;
			sel_mem_in_ai <= butterfly_out_ai;
		end
		else
		begin
			sel_mem_in_ar <= {{(DATA_WIDTH - MIC_BITS){mic_data[MIC_BITS-1]}}, mic_data};
			sel_mem_in_ai <= 0;
		end
	end
endmodule
