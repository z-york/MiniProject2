`timescale 1ns / 1ps

module top_level(clk_100mhz, rst, pixel_r, pixel_g, pixel_b, hsync, vsync, blank, clk, clk_n, D, dvi_rst, scl_tri, sda_tri);
	input clk_100mhz, rst;
	
	output hsync, vsync, blank, dvi_rst;

	output [7:0] pixel_r, pixel_g, pixel_b;

	output [11:0] D;
	output clk, clk_n;

	inout scl_tri, sda_tri;

	wire clkin_ibufg_out, clk_100mhz_buf, locked_dcm, clk_25mhz, clkn_25mhz, comp_sync;

	assign clk = clk_25mhz;
	assign clk_n = ~clk_25mhz;

	wire sda, scl;

	assign dvi_rst = ~(rst|~locked_dcm);
	assign D = (clk)? {pixel_g[3:0], pixel_b} : {pixel_r, pixel_g[7:4]};
	assign sda_tri = (sda)? 1'bz: 1'b0;
	assign scl_tri = (scl)? 1'bz: 1'b0;

	dvi_ifc dvi1(.Clk(clk_25mhz), .Reset_n(dvi_rst), .SDA(sda), .SCL(scl), .Done(done), .IIC_xfer_done(iic_tx_done), .init_IIC_xfer(1'b0));
	
	vga_clk vga_clk_gen1(.CLKIN_IN(clk_100mhz), .RST_IN(rst), .CLKDV_OUT(clk_25mhz), .CLKIN_IBUFG_OUT(clkin_ibufg_out), .CLK0_OUT(clk_100mhz_buf), .LOCKED_OUT(locked_dcm));

	wire [12:0] addra;
	wire [23:0] fifo_in, fifo_out;
	wire full, empty, rd_en;
	ROM rom1(.clka(clk_100mhz_buf), .addra(addra), .douta(fifo_in));
	DisplayPlane plane1(.clk(clk_100mhz_buf), .rst (rst|~locked_dcm), .full(full), .addr(addra));
	FIFO fifo1(.rst(rst|~locked_dcm), .wr_clk(clk_100mhz_buf), .rd_clk(clk_25mhz), .din(fifo_in), .wr_en(1), .rd_en(rd_en), .dout(fifo_out), .full(full), .empty(empty));  
	TimingGenerator gen1(.clk(clk_25mhz), .rst(rst|~locked_dcm), .empty(empty), .pixelData(fifo_out), .rd_en(rd_en), .blank(blank), .hsync(hsync), .vsync(vsync), .pixel_r(pixel_r), .pixel_g(pixel_g), .pixel_b(pixel_b));

endmodule
