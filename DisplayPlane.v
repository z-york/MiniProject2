`timescale 1ns / 1ps

module DisplayPlane(clk, rst, full, addr);
	input clk, rst, full;
	output reg [12:0] addr;
	
	reg [6:0] Counter_80; //count pixel in one line
	reg [2:0] Counter_col, Counter_row;

	always @(negedge clk, posedge rst)
		if ( rst ) 
			addr <= 0;
		else if ( full )
			addr <= addr;
		else if (Counter_col == 3'h7) begin
			if (Counter_80 == 79 && Counter_row != 3'h7)
				addr <= addr - 79;
			else if ( addr == 13'h12bf)
				addr <= 0;
			else
				addr <= addr + 1;
		end
		else
			addr <= addr;

	always @(negedge clk, posedge rst)
		if ( rst )
			Counter_80 <= 0;
		else if ( full )
			Counter_80 <= Counter_80;
		else if (Counter_col == 3'h7) begin
			if (Counter_80 == 79)
				Counter_80 <= 0;
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
