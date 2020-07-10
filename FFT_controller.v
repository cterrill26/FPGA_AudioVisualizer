module FFT_controller
#(parameter DATA_WIDTH=18, parameter ADDR_WIDTH=4, parameter PIPELINE_DELAY = 10)
(
	input clk, rst, start,
	output we_sel, q_sel,
	input mic_we,
	input [(ADDR_WIDTH-1):0] mic_addr,
	input [(ADDR_WIDTH-2):0] vga_addr,
	output reg we_a, we_b,
	output reg [(ADDR_WIDTH-1):0] addr0_a, addr0_b, addr1_a, addr1_b,
	output reg [(DATA_WIDTH-1):0] twiddle_r, twiddle_i,
	output reg done
);

	reg [($clog2(ADDR_WIDTH)-1):0] i, next_i;
	reg [($clog2(PIPELINE_DELAY+2**(ADDR_WIDTH-1)-1)-1):0] j, next_j;
	reg [(ADDR_WIDTH-1):0] mem_addr_unshifted_a, mem_addr_unshifted_b, mem_addr_a, mem_addr_b, next_mem_addr_a, next_mem_addr_b;
	reg [((ADDR_WIDTH*2)-1):0] temp_a, temp_b;
	reg [(ADDR_WIDTH-2):0] twiddle_addr, twiddle_mask, next_twiddle_mask;
	reg next_done;
	reg [(ADDR_WIDTH-1):0] next_addr0_a, next_addr0_b, next_addr1_a, next_addr1_b;
	reg next_we_a, next_we_b;
	wire [(DATA_WIDTH-1):0] rom_out_r, rom_out_i, delay_rom_out_r, delay_rom_out_i;
	wire [(ADDR_WIDTH-1):0] delay_mem_addr_a, delay_mem_addr_b;
	wire [(ADDR_WIDTH-1):0] mic_addr_reversed;
	
	assign we_sel = (~i[0]) & (~done);
	assign q_sel = i[0];
	
	ROM
	#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH-1), .REAL(1))
	twiddle_rom_r
	(
		.addr(twiddle_addr),
		.clk(clk),
		.q(rom_out_r)
	);
	
	ROM
	#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH-1), .REAL(0))
	twiddle_rom_i
	(
		.addr(twiddle_addr),
		.clk(clk),
		.q(rom_out_i)
	);
	
	delay
	#(.WIDTH(DATA_WIDTH), .CYCLES(2))
	delay_rom_r
	(
		.clk(clk),
		.data_in(rom_out_r),
		.data_out(delay_rom_out_r)
	);
	
	delay
	#(.WIDTH(DATA_WIDTH), .CYCLES(2))
	delay_rom_i
	(
		.clk(clk),
		.data_in(rom_out_i),
		.data_out(delay_rom_out_i)
	);
	
	
	delay
	#(.WIDTH(ADDR_WIDTH), .CYCLES(PIPELINE_DELAY-4))
	delay_mem_a
	(
		.clk(clk),
		.data_in(mem_addr_a),
		.data_out(delay_mem_addr_a)
	);
	
	delay
	#(.WIDTH(ADDR_WIDTH), .CYCLES(PIPELINE_DELAY-4))
	delay_mem_b
	(
		.clk(clk),
		.data_in(mem_addr_b),
		.data_out(delay_mem_addr_b)
	);
	
	reverse
	#(.WIDTH(ADDR_WIDTH))
	mic_reverse
	(
		.data_in(mic_addr),
		.data_out(mic_addr_reversed)
	);
	
	
	//sequential
	always @ (posedge clk)
	begin		
		addr0_a <= next_addr0_a;
		addr0_b <= next_addr0_b;
		addr1_a <= next_addr1_a;
		addr1_b <= next_addr1_b;	
		twiddle_r <= delay_rom_out_r;
		twiddle_i <= delay_rom_out_i;
		twiddle_addr <= j[(ADDR_WIDTH-2):0] & twiddle_mask;
		twiddle_mask <= next_twiddle_mask;
		mem_addr_unshifted_a[0] <= 0;
		mem_addr_unshifted_a[(ADDR_WIDTH-1):1] <= j[(ADDR_WIDTH-2):0];
		mem_addr_unshifted_b[0] <= 1;
		mem_addr_unshifted_b[(ADDR_WIDTH-1):1] <= j[(ADDR_WIDTH-2):0];
		mem_addr_a <= next_mem_addr_a;
		mem_addr_b <= next_mem_addr_b;
		
			
		if(~rst)
		begin
			done <= 1;
			we_a <= 0;
			we_b <= 0;
			i <= 0;
			j <= 0;
		end
		else
		begin
			done <= next_done;
			we_a <= next_we_a;
			we_b <= next_we_b;
			i <= next_i;
			j <= next_j;
		end
			
	end
	
	
	//combinational
	always @ (*)
	begin
		//default values
		next_i = 0;
		next_j = 0;
		next_twiddle_mask = 0;
		next_done = done;
		next_we_a = 0;
		next_we_b = 0;
		next_addr0_a = mem_addr_a;
		next_addr0_b = mem_addr_b;
		next_addr1_a = delay_mem_addr_a;
		next_addr1_b = delay_mem_addr_b;
				
		//barrel shifter
		temp_a = {mem_addr_unshifted_a, mem_addr_unshifted_a};
		temp_b = {mem_addr_unshifted_b, mem_addr_unshifted_b};
		temp_a = temp_a << i;
		temp_b = temp_b << i;
		next_mem_addr_a = temp_a[((ADDR_WIDTH*2)-1):ADDR_WIDTH];
		next_mem_addr_b = temp_b[((ADDR_WIDTH*2)-1):ADDR_WIDTH];
		
		
		if (~done)
		begin
			if (i[0])
			begin
				next_addr0_a = delay_mem_addr_a;
				next_addr0_b = delay_mem_addr_b;
				next_addr1_a = mem_addr_a;
				next_addr1_b = mem_addr_b;
			end
			
			if (j >= (PIPELINE_DELAY-2) && j < (PIPELINE_DELAY+2**(ADDR_WIDTH-1)-2))
			begin
				next_we_a = 1;
				next_we_b = 1;
			end
		end
		else
		begin
			next_we_a = mic_we;
			next_addr0_a = mic_addr_reversed;
			next_addr1_a = {1'b0, vga_addr} + 1; //plus one cuz i want to display points 1-256, not 0 to 255
		end
		
		
		if (~done)
		begin
			if (j == (PIPELINE_DELAY+2**(ADDR_WIDTH-1)-2))
			begin
				if (i == (ADDR_WIDTH-1))
					next_done = 1;
				else
				begin
					next_i = i + 1;
					next_j = 0;
					next_twiddle_mask[(ADDR_WIDTH-3):0] = twiddle_mask[(ADDR_WIDTH-2):1];
					next_twiddle_mask[(ADDR_WIDTH-2)] = 1;
				end
			end
			else 
			begin
				next_i = i;
				next_j = j + 1;
				next_twiddle_mask = twiddle_mask;
			end
		end
		else
		begin		
			if (start)
				next_done = 0;
		end
	end
endmodule
