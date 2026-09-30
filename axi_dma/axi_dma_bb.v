
module axi_dma (
	clk,
	reset,
	master_address,
	master_write,
	master_byteenable,
	master_writedata,
	master_burstcount,
	master_waitrequest,
	control_fixed_location,
	control_write_base,
	control_write_length,
	control_go,
	control_done,
	user_write_buffer,
	user_buffer_input_data,
	user_buffer_full);	

	input		clk;
	input		reset;
	output	[31:0]	master_address;
	output		master_write;
	output	[3:0]	master_byteenable;
	output	[31:0]	master_writedata;
	output	[5:0]	master_burstcount;
	input		master_waitrequest;
	input		control_fixed_location;
	input	[31:0]	control_write_base;
	input	[31:0]	control_write_length;
	input		control_go;
	output		control_done;
	input		user_write_buffer;
	input	[31:0]	user_buffer_input_data;
	output		user_buffer_full;
endmodule
