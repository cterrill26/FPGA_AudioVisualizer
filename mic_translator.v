`define _CALIBRATION {13'd226, 5'd0}

module mic_translator
#(parameter ADDR_WIDTH = 6, parameter MIC_BITS = 18, parameter DELAY_START_BITS = 3)
(
	input clk, rst, DOUT,
	output start,
	output reg BCLK, LRCLK, mic_we,
	output reg [(ADDR_WIDTH-1):0] mic_addr,
	output [(MIC_BITS-1):0] mic_data
);

	reg [4:0] negedge_cnt, posedge_cnt;
	reg [(ADDR_WIDTH-1):0] fifo_wr_addr, fifo_rd_addr;
	reg [(MIC_BITS-1):0] fifo_wr_data, data_buffer;
	reg fifo_we, begin_transfer, reading, LR;
	reg [(DELAY_START_BITS - 1):0] delay_start;
	wire [(MIC_BITS-1):0] fifo_rd_data;
	
	assign start = delay_start[(DELAY_START_BITS - 1)];
	assign mic_data = fifo_rd_data;
	
	
	mic_fifo 
	#(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(MIC_BITS))
	mic_data_fifo
	(
		.clk(clk), 
		.fifo_we(fifo_we),
		.fifo_wr_addr(fifo_wr_addr), 
		.fifo_rd_addr(fifo_rd_addr),
		.fifo_wr_data(fifo_wr_data),
		.fifo_rd_data(fifo_rd_data)
	);
	
	
	initial 
	begin
		BCLK = 1;
		LRCLK = 1;
		negedge_cnt = 0;
		LR = 1;
		begin_transfer = 0;
		fifo_wr_addr = 0;
		fifo_we = 0;
		posedge_cnt = 0;
		delay_start = 0;
		mic_we = 0;
		reading = 0;
	end
	
	
	always @ (clk) begin
		if (~rst)
			BCLK <= 1;
		else
			BCLK <= clk;
	end
	
	
	//output LRCLK to mic
	always @ (negedge BCLK, negedge rst) 
	begin
		if (~rst) 
		begin
			LRCLK <= 1;
			negedge_cnt <= 0;
		end
		else if (negedge_cnt < 31) 
		begin
			LRCLK <= LRCLK;
			negedge_cnt <= negedge_cnt + 1;
		end
		else 
		begin
			LRCLK <= ~LRCLK;
			negedge_cnt <= 0;
		end
	end
	
	
	//reading mic data and writing to FIFO
	always @ (posedge BCLK, negedge rst)
	begin
		if (~rst)
		begin
			LR <= 1;
			begin_transfer <= 0;
			fifo_wr_addr <= 0;
			fifo_we <= 0;
			posedge_cnt <= 0;
		end
		else if (posedge_cnt == MIC_BITS)
		begin
			LR <= LR;
			begin_transfer <= 0;
			fifo_wr_addr <= fifo_wr_addr;
			fifo_we <= (~LR);
			posedge_cnt <= posedge_cnt+1;
		end
		else if (posedge_cnt == 31)
		begin
			LR <= ~LR;
			begin_transfer <= ((~LR) && (fifo_wr_addr == (2**(ADDR_WIDTH)-1)))? 1 : 0;
			fifo_wr_addr <= (~LR)? fifo_wr_addr + 1 : fifo_wr_addr;
			fifo_we <= 0;
			posedge_cnt <= 0;
		end
		else 
		begin
			LR <= LR;
			begin_transfer <= 0;
			fifo_wr_addr <= fifo_wr_addr;
			fifo_we <= 0;
			posedge_cnt <= posedge_cnt+1;
		end
	end
	
	always @ (posedge clk)
	begin	
		fifo_wr_data <= data_buffer + `_CALIBRATION;
		
		if ((posedge_cnt < MIC_BITS) && (~LR))
		begin
			data_buffer[0] <= DOUT;
			data_buffer[(MIC_BITS-1):1] <= data_buffer[(MIC_BITS-2):0];
		end
		else
			data_buffer <= data_buffer;
	end

	
	//reading FIFO data and writing to FFT processor
	always @ (posedge clk)
	begin
		mic_addr <= fifo_rd_addr;
	
		if (~rst)
		begin
			delay_start <= 0;
			mic_we <= 0;
			reading <= 0;
		end
		else 
		begin
			delay_start[(DELAY_START_BITS-1):1] <= delay_start[(DELAY_START_BITS-2):0];
			mic_we <= reading;
			
			if (begin_transfer)
			begin
				reading <= 1;
				delay_start[0] <= 0;
			end
			else if (fifo_rd_addr == (2**ADDR_WIDTH-1))
			begin
				reading <= 0;
				delay_start[0] <= 1;
			end
			else
			begin
				reading <= reading;
				delay_start[0] <= 0;
			end
		end
		
		if (reading)
			fifo_rd_addr <= fifo_rd_addr + 1;
		else
			fifo_rd_addr <= 0;
			
	end
	
endmodule
