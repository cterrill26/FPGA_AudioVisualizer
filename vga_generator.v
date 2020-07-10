module vga_generator
#(parameter ADDR_WIDTH = 9, parameter DATA_WIDTH = 18, parameter MEM_DATA_WIDTH = 9)
(
	input done, vga_clk, FFT_clk, rst,
	input [(DATA_WIDTH-1):0] FFT_data_r, FFT_data_i,
	output reg [(ADDR_WIDTH-2):0] FFT_addr,
	output reg [3:0] VGA_R, 
	output [3:0] VGA_G, VGA_B,
	output VGA_HS,	VGA_VS
);

	reg [(ADDR_WIDTH-2):0] vga_addr;
	wire [(ADDR_WIDTH-2):0] fifo_wr_addr;
	wire [(ADDR_WIDTH-2):0] delay_FFT_addr;
	wire [(MEM_DATA_WIDTH-1):0] vga_data, fifo_wr_data;
	reg [2:0] reg_done, reading, counter;
	wire hblank, vblank, newline;
	wire [9:0] horizontal_count, vertical_count;
	wire addr_rst, fifo_we;	
	
	wire [(DATA_WIDTH-1):0] abs_FFT_data_r = (FFT_data_r[DATA_WIDTH-1])? ((~FFT_data_r) + 1) : FFT_data_r;
	wire [(DATA_WIDTH-1):0] abs_FFT_data_i = (FFT_data_i[DATA_WIDTH-1])? ((~FFT_data_i) + 1) : FFT_data_i;
	
	
	assign VGA_G = 0;
	assign VGA_B = 0;
	
	
	vga_fifo 
	#(.ADDR_WIDTH(ADDR_WIDTH-1), .DATA_WIDTH(9))
	vga_data_fifo
	(
		.FFT_clk(FFT_clk), 
		.vga_clk(vga_clk),
		.fifo_we(fifo_we),
		.fifo_wr_addr(fifo_wr_addr), 
		.fifo_rd_addr(vga_addr),
		.fifo_wr_data(fifo_wr_data),
		.fifo_rd_data(vga_data)
	);

	delay
	#(.WIDTH(ADDR_WIDTH-1), .CYCLES(2))
	del_FFT_addr
	(
		.clk(FFT_clk),
		.data_in(FFT_addr),
		.data_out(delay_FFT_addr)
	);
			
	vsync vertical(
		.newline_in(newline),
		.rst(rst),	
		.vsync_out(VGA_VS), 
		.blank_out(vblank), 
		.pixel_count(vertical_count)
	);
	
	hsync horizontal
	(
		.clk(vga_clk), 
		.rst(rst),
		.hsync_out(VGA_HS), 
		.blank_out(hblank), 
		.newline_out(newline), 
		.pixel_count(horizontal_count),
		.addr_rst(addr_rst)
	);
	
	magnitude_estimate
	#(.ADDR_WIDTH(ADDR_WIDTH-1), .DATA_WIDTH(DATA_WIDTH), .MEM_DATA_WIDTH(MEM_DATA_WIDTH))
	mag_est
	(
		.clk(FFT_clk), 
		.rst(rst), 
		.we(reading[2]),
		.addr(delay_FFT_addr),
		.abs_FFT_data_r(abs_FFT_data_r), 
		.abs_FFT_data_i(abs_FFT_data_i),
		.delay_we(fifo_we),
		.delay_addr(fifo_wr_addr),
		.data(fifo_wr_data)
	);
	
	
	initial
	begin
		reg_done = 3'b111;
		reading = 0;
	end
	
	always @ (posedge FFT_clk)
	begin
		if (~rst)
		begin
			reg_done <= 3'b111;
			reading <= 0;
		end
		else 
		begin
			reg_done[0] <= done;
			reg_done[2:1] <= reg_done[1:0];
			reading[2:1] <= reading[1:0];
			
			
			if ((~reg_done[2]) && reg_done[1])
				reading[0] <= 1;
			else if (FFT_addr == (2**(ADDR_WIDTH-1)-1))
				reading[0] <= 0;
			else
				reading[0] <= reading[0];
		end
		
		if (reading[0])
			FFT_addr <= FFT_addr + 1;
		else
			FFT_addr <= 0;
	
		
	end
	
	
	initial 
	begin
		VGA_R = 0;
		vga_addr = 0;
		counter = 0;
	end
	
	
	always @ (posedge vga_clk) 
	begin
		if (~rst)
			VGA_R <= 0;
		else if (hblank || vblank)
			VGA_R <= 0;
		else if (vertical_count[(MEM_DATA_WIDTH-1):0] > vga_data)
			VGA_R <= 4'b1100;
		else
			VGA_R <= 0;
	end
	
	always @ (posedge vga_clk) 
	begin
		if (~rst)
		begin
			vga_addr <= 0;
			counter <= 0;
		end		
		else if (addr_rst)
		begin
			vga_addr <= 0;
			counter <= 0;
		end
		else if (counter == 4)
		begin
			vga_addr <= vga_addr + 1;
			counter <= 0;
		end
		else if (counter == 1)
		begin
			vga_addr <= vga_addr + 1;
			counter <= counter + 1;
		end
		else
		begin
			vga_addr <= vga_addr;
			counter <= counter + 1;
		end
		
	end
	
endmodule



module hsync
(
	input clk, rst,
	output reg hsync_out, 
	output reg blank_out, 
	output reg newline_out, 
	output [9:0] pixel_count,
	output reg addr_rst
);

	parameter TOTAL_COUNTER = 800;
	parameter SYNC = 96;
	parameter BACKPORCH = 48;
	parameter DISPLAY = 640;
	parameter FRONTPORCH = 16;

	reg [9:0] counter;
	
	assign pixel_count = counter;
	
	initial
	begin
		counter = 0;
		addr_rst = 0;
		hsync_out = 1;
		blank_out = 0;
		newline_out = 0;
	end
	
	
	always @ (posedge clk) begin	
		if (~rst)
			counter <= 0;
		else if(counter < TOTAL_COUNTER)		//reset counter if every 800 clk cycles
			counter <= counter + 1;
		else
			counter <= 0;		
	end
	
	always @ (posedge clk) begin	
		if(counter == TOTAL_COUNTER-1)		//reset counter if every 800 clk cycles
			addr_rst <= 1;
		else
			addr_rst <= 0;		
	end
	
	always @ (posedge clk) begin	//hsync
		if(counter < (DISPLAY + FRONTPORCH))
			hsync_out <= 1;
		else if(counter >= (DISPLAY + FRONTPORCH) && counter < (DISPLAY + FRONTPORCH + SYNC))
			hsync_out <= 0;
		else if(counter >= (DISPLAY + FRONTPORCH + SYNC))	
			hsync_out <= 1;			
	end
	
	always @ (posedge clk) begin	//blank, high during display interval
		if(counter < DISPLAY)
			blank_out <= 0;
		else
			blank_out <= 1;
	end
	
	always @ (posedge clk) begin	//newline
		if(counter == 0)
			newline_out <= 1;
		else
			newline_out <= 0;
	end

endmodule


module vsync
(
	input newline_in, rst,
	output reg vsync_out, 
	output reg blank_out, 
	output [9:0] pixel_count
);

	parameter TOTAL_COUNTER = 525;
	parameter SYNC = 2;
	parameter BACKPORCH = 33;
	parameter DISPLAY = 480;
	parameter FRONTPORCH = 10;
	
	reg [9:0] counter;
	
	assign pixel_count = counter;
	
	initial 
	begin
		counter = 0;
		vsync_out = 0;
		blank_out = 0;
	end
	
	always @ (posedge newline_in) begin	//counter
		if (~rst)
			counter <= 0;
		else if(counter < TOTAL_COUNTER)
			counter <= counter + 1;
		else
			counter <= 0;
	end
	
	always @ (posedge newline_in) begin	//vsync
		if(counter < (DISPLAY + FRONTPORCH))
			vsync_out <= 1;
		else if(counter >= (DISPLAY + FRONTPORCH) && counter < (DISPLAY + FRONTPORCH + SYNC))
			vsync_out <= 0;
		else if(counter >= (DISPLAY + FRONTPORCH + SYNC))
			vsync_out <= 1;
	end
	
	always @ (posedge newline_in) begin	//blank
		if(counter < DISPLAY)
			blank_out <= 0;
		else
			blank_out <= 1;
	end

endmodule


