
module soc_system (
	clk_clk,
	frame_sdram_dma_0_frame_input_input_array_flat,
	hps_0_f2h_cold_reset_req_reset_n,
	hps_0_h2f_loan_io_in,
	hps_0_h2f_loan_io_out,
	hps_0_h2f_loan_io_oe,
	hps_0_h2f_reset_reset_n,
	hps_0_hps_io_hps_io_sdio_inst_CMD,
	hps_0_hps_io_hps_io_sdio_inst_D0,
	hps_0_hps_io_hps_io_sdio_inst_D1,
	hps_0_hps_io_hps_io_sdio_inst_CLK,
	hps_0_hps_io_hps_io_sdio_inst_D2,
	hps_0_hps_io_hps_io_sdio_inst_D3,
	hps_0_hps_io_hps_io_usb1_inst_D0,
	hps_0_hps_io_hps_io_usb1_inst_D1,
	hps_0_hps_io_hps_io_usb1_inst_D2,
	hps_0_hps_io_hps_io_usb1_inst_D3,
	hps_0_hps_io_hps_io_usb1_inst_D4,
	hps_0_hps_io_hps_io_usb1_inst_D5,
	hps_0_hps_io_hps_io_usb1_inst_D6,
	hps_0_hps_io_hps_io_usb1_inst_D7,
	hps_0_hps_io_hps_io_usb1_inst_CLK,
	hps_0_hps_io_hps_io_usb1_inst_STP,
	hps_0_hps_io_hps_io_usb1_inst_DIR,
	hps_0_hps_io_hps_io_usb1_inst_NXT,
	hps_0_hps_io_hps_io_uart0_inst_RX,
	hps_0_hps_io_hps_io_uart0_inst_TX,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO00,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO14,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO15,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO16,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO17,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO18,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO19,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO22,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO23,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO24,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO25,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO26,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO27,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO29,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO30,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO31,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO32,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO34,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO48,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO49,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO50,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO51,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO52,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO53,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO54,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO55,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO56,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO57,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO58,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO59,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO60,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO63,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO64,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO65,
	hps_0_hps_io_hps_io_gpio_inst_LOANIO66,
	memory_mem_a,
	memory_mem_ba,
	memory_mem_ck,
	memory_mem_ck_n,
	memory_mem_cke,
	memory_mem_cs_n,
	memory_mem_ras_n,
	memory_mem_cas_n,
	memory_mem_we_n,
	memory_mem_reset_n,
	memory_mem_dq,
	memory_mem_dqs,
	memory_mem_dqs_n,
	memory_mem_odt,
	memory_mem_dm,
	memory_oct_rzqin,
	motor_lut_avalon_slave_0_lut_active_bank,
	motor_lut_avalon_slave_0_lut_commit_ack,
	motor_lut_avalon_slave_0_lut_commit_req,
	motor_lut_avalon_slave_0_lut_wr_addr,
	motor_lut_avalon_slave_0_lut_wr_bank,
	motor_lut_avalon_slave_0_lut_wr_data,
	motor_lut_avalon_slave_0_lut_wr_en,
	motor_lut_avalon_slave_0_lut_verify_addr,
	motor_lut_avalon_slave_0_lut_verify_bank,
	motor_lut_avalon_slave_0_lut_verify_data,
	motor_lut_avalon_slave_0_lut_verify_en,
	motor_lut_avalon_slave_0_lut_verify_lock,
	motor_lut_avalon_slave_0_lut_verify_valid,
	register_file_run_name,
	reset_reset_n);	

	input		clk_clk;
	input	[863:0]	frame_sdram_dma_0_frame_input_input_array_flat;
	input		hps_0_f2h_cold_reset_req_reset_n;
	output	[66:0]	hps_0_h2f_loan_io_in;
	input	[66:0]	hps_0_h2f_loan_io_out;
	input	[66:0]	hps_0_h2f_loan_io_oe;
	output		hps_0_h2f_reset_reset_n;
	inout		hps_0_hps_io_hps_io_sdio_inst_CMD;
	inout		hps_0_hps_io_hps_io_sdio_inst_D0;
	inout		hps_0_hps_io_hps_io_sdio_inst_D1;
	output		hps_0_hps_io_hps_io_sdio_inst_CLK;
	inout		hps_0_hps_io_hps_io_sdio_inst_D2;
	inout		hps_0_hps_io_hps_io_sdio_inst_D3;
	inout		hps_0_hps_io_hps_io_usb1_inst_D0;
	inout		hps_0_hps_io_hps_io_usb1_inst_D1;
	inout		hps_0_hps_io_hps_io_usb1_inst_D2;
	inout		hps_0_hps_io_hps_io_usb1_inst_D3;
	inout		hps_0_hps_io_hps_io_usb1_inst_D4;
	inout		hps_0_hps_io_hps_io_usb1_inst_D5;
	inout		hps_0_hps_io_hps_io_usb1_inst_D6;
	inout		hps_0_hps_io_hps_io_usb1_inst_D7;
	input		hps_0_hps_io_hps_io_usb1_inst_CLK;
	output		hps_0_hps_io_hps_io_usb1_inst_STP;
	input		hps_0_hps_io_hps_io_usb1_inst_DIR;
	input		hps_0_hps_io_hps_io_usb1_inst_NXT;
	input		hps_0_hps_io_hps_io_uart0_inst_RX;
	output		hps_0_hps_io_hps_io_uart0_inst_TX;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO00;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO14;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO15;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO16;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO17;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO18;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO19;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO22;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO23;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO24;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO25;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO26;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO27;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO29;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO30;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO31;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO32;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO34;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO48;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO49;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO50;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO51;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO52;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO53;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO54;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO55;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO56;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO57;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO58;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO59;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO60;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO63;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO64;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO65;
	inout		hps_0_hps_io_hps_io_gpio_inst_LOANIO66;
	output	[14:0]	memory_mem_a;
	output	[2:0]	memory_mem_ba;
	output		memory_mem_ck;
	output		memory_mem_ck_n;
	output		memory_mem_cke;
	output		memory_mem_cs_n;
	output		memory_mem_ras_n;
	output		memory_mem_cas_n;
	output		memory_mem_we_n;
	output		memory_mem_reset_n;
	inout	[31:0]	memory_mem_dq;
	inout	[3:0]	memory_mem_dqs;
	inout	[3:0]	memory_mem_dqs_n;
	output		memory_mem_odt;
	output	[3:0]	memory_mem_dm;
	input		memory_oct_rzqin;
	input		motor_lut_avalon_slave_0_lut_active_bank;
	input		motor_lut_avalon_slave_0_lut_commit_ack;
	output		motor_lut_avalon_slave_0_lut_commit_req;
	output	[11:0]	motor_lut_avalon_slave_0_lut_wr_addr;
	output		motor_lut_avalon_slave_0_lut_wr_bank;
	output	[12:0]	motor_lut_avalon_slave_0_lut_wr_data;
	output		motor_lut_avalon_slave_0_lut_wr_en;
	output	[11:0]	motor_lut_avalon_slave_0_lut_verify_addr;
	output		motor_lut_avalon_slave_0_lut_verify_bank;
	input	[12:0]	motor_lut_avalon_slave_0_lut_verify_data;
	output		motor_lut_avalon_slave_0_lut_verify_en;
	output		motor_lut_avalon_slave_0_lut_verify_lock;
	input		motor_lut_avalon_slave_0_lut_verify_valid;
	output		register_file_run_name;
	input		reset_reset_n;
endmodule
