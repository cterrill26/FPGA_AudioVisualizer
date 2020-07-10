module mic_fifo 
#(parameter ADDR_WIDTH = 6, parameter DATA_WIDTH = 18)
(
	input clk, fifo_we,
	input [(ADDR_WIDTH-1):0] fifo_wr_addr, fifo_rd_addr,
	input [(DATA_WIDTH-1):0] fifo_wr_data,
	output reg [(DATA_WIDTH-1):0] fifo_rd_data
);

	reg [DATA_WIDTH-1:0] fifo [2**ADDR_WIDTH-1:0];
	
	// FIFO write Port 
	always @ (posedge clk)
	begin
		if (fifo_we)
			fifo[fifo_wr_addr] <= fifo_wr_data;
	end 

	// FIFO read Port 
	always @ (posedge clk)
	begin
		fifo_rd_data <= fifo[fifo_rd_addr];
	end
	
endmodule
	