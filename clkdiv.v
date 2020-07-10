module clkdiv 
#(parameter THRESHOLD = 1)
(
	input clk_in, 
	output reg clk_out
);
	
	reg [31:0] clk_counter;
	
	
	initial begin
		clk_counter = 0;
		clk_out = 1;
	end
	
	always @ (posedge clk_in) begin
		if (clk_counter >= THRESHOLD) begin
			clk_counter <= 0;
			clk_out <= ~clk_out;
		end
		else begin
			clk_counter <= clk_counter + 1;
			clk_out <= clk_out;
		end
	end
	
endmodule
