module magnitude_estimate
#(parameter ADDR_WIDTH = 6, parameter DATA_WIDTH = 18, parameter MEM_DATA_WIDTH = 9)
(
	input clk, rst, we,
	input [(ADDR_WIDTH-1):0] addr,
	input unsigned [(DATA_WIDTH-1):0] abs_FFT_data_r, abs_FFT_data_i,
	output delay_we,
	output [(ADDR_WIDTH-1):0] delay_addr,
	output reg unsigned [8:0] data
);

	//https://www.embedded.com/digital-signal-processing-tricks-high-speed-vector-magnitude-approximation/
	
	reg unsigned [(DATA_WIDTH-1):0] reg_term_r, reg_term_i;
	reg unsigned [DATA_WIDTH:0] reg_term_sum, mag;
	reg [3:0] reg_we;
	
	assign delay_we = reg_we[3];
	
	
	delay
	#(.WIDTH(ADDR_WIDTH), .CYCLES(4))
	del_addr
	(
		.clk(clk),
		.data_in(addr),
		.data_out(delay_addr)
	);
	
	
	always @ (posedge clk)
	begin
	
		if (~rst)
			reg_we <= 0;
		else
		begin
			reg_we <= we;
			reg_we[3:1] <= reg_we[2:0];
		end
		
		
		if (abs_FFT_data_r < abs_FFT_data_i)
		begin
			reg_term_r <= abs_FFT_data_r >> 1;
			reg_term_i <= abs_FFT_data_i;
		end
		else 
		begin
			reg_term_r <= abs_FFT_data_r;
			reg_term_i <= abs_FFT_data_i >> 1;
		end
		
		reg_term_sum <= reg_term_r + reg_term_i;
		mag <= reg_term_sum - (reg_term_sum >> 4);
		data <= 480 - mag[DATA_WIDTH-2:DATA_WIDTH-MEM_DATA_WIDTH-1];
		
	end
endmodule
