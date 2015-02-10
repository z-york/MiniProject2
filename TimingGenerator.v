`timescale 1ns / 1ps

module TimingGenerator (clk, rst, empty, pixelData, rd_en, blank, hsync, vsync, pixel_r, pixel_g, pixel_b);
	input clk, rst, empty;
	input [23:0] pixelData;
	output blank, hsync, vsync, rd_en;
	output reg [7:0] pixel_r, pixel_g, pixel_b;

	reg [9:0] pixel_x, pixel_y;
	reg rd_en;
	wire [9:0] next_pixel_x, next_pixel_y;
	assign next_pixel_x = (pixel_x == 10'd799)? 0: pixel_x + 1;
	assign next_pixel_y = (pixel_x == 10'd799)? ((pixel_y == 10'd520)? 0: pixel_y + 1): pixel_y;

	always @(posedge clk, posedge rst)
		if ( rst ) begin
			pixel_x <= 10'h0;
			pixel_y <= 10'h0;
		end
		// This can only happen immediately after reset
		// Since write clock is faster than read clock
		else if ( empty ) begin
			pixel_x <= 10'h0;
			pixel_y <= 10'h0;
		end
		else begin
			pixel_x <= next_pixel_x;
			pixel_y <= next_pixel_y;
		end

	always @(negedge clk, posedge rst)
		if ( rst )
			rd_en <= 0;
		// Read data from FIFO when blank is 1
		else 
			rd_en <= blank;

	// Set pixels	
	always @(posedge clk, posedge rst)
		if ( rst ) begin
			pixel_r <= 8'h0;
			pixel_g <= 8'h0;
			pixel_b <= 8'h0;
		end
		else if ( blank == 0 ) begin
			pixel_r <= 8'h0;
			pixel_g <= 8'h0;
			pixel_b <= 8'h0;
		end
		else begin
			pixel_r <= pixelData[23:16];
			pixel_g <= pixelData[15:8];
			pixel_b <= pixelData[7:0];
		end
	
	assign hsync = (pixel_x < 10'd656) || (pixel_x > 10'd751);
	assign vsync = (pixel_y < 10'd490) || (pixel_y > 10'd491);
	assign blank = ~((pixel_x > 10'd639) | (pixel_y > 10'd479));
	
endmodule
