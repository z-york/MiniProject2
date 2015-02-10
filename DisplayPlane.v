`timescale 1ns / 1ps

module DisplayPlane(clk, rst, full, addr);
	input clk, rst, full;
	output reg [12:0] addr;
	
	reg [6:0] Counter_80; //count pixel in one line
	reg [2:0] Counter_col, Counter_row;

	/**
	* Generates address at the negative edge of clock
	* If full signal set, stop increasing the address and wait
	* wr_en always set to 1 and databus is connected directly from ROM to FIFO
	* 
	* Each line contains 80 pixels, using Counter_80 to count this
	* Each pixel repeats 8 times in one line, using Counter_col to count this
	* Each line repeats 8 times, using Counter_row to count this
	*/

	always @(negedge clk, posedge rst)
		if ( rst ) 
			addr <= 0;
		// Stop increasing the address
		else if ( full )
			addr <= addr;
		else if (Counter_col == 3'h7) begin
			// it is the end of this line, and this line has not repeated for
			// 8 times, decrease address
			if (Counter_80 == 79 && Counter_row != 3'h7)
				addr <= addr - 79;
			// it is the end of this graph, set the address to 0
			else if ( addr == 13'h12bf)
				addr <= 0;
			else
				addr <= addr + 1;
		end
		// Repeat this address for 8 times
		else
			addr <= addr;

	always @(negedge clk, posedge rst)
		if ( rst )
			Counter_80 <= 0;
		else if ( full )
			Counter_80 <= Counter_80;
		// Finish repeating this pixel
		else if (Counter_col == 3'h7) begin
			// It is the end of this line, set counter to 0
			if (Counter_80 == 79)
				Counter_80 <= 0;
			// Increase counter by 1
			else
				Counter_80 <= Counter_80 + 1;
		end
		else
			Counter_80 <= Counter_80;

	always @(negedge clk, posedge rst)
		if ( rst )
			Counter_col <= 0;
		else if ( full )
			Counter_col <= Counter_col;
		else
			Counter_col <= Counter_col + 1;
	
	always @(negedge clk, posedge rst)
		if ( rst )
			Counter_row <= 0;
		else if ( full )
			Counter_row <= Counter_row;
		else if ( Counter_80 == 79 && Counter_col == 7)
			Counter_row <= Counter_row + 1;
		else
			Counter_row <= Counter_row;

endmodule
