	axi_dma u0 (
		.clk                    (<connected-to-clk>),                    //       clock_reset.clk
		.reset                  (<connected-to-reset>),                  // clock_reset_reset.reset
		.master_address         (<connected-to-master_address>),         //     avalon_master.address
		.master_write           (<connected-to-master_write>),           //                  .write
		.master_byteenable      (<connected-to-master_byteenable>),      //                  .byteenable
		.master_writedata       (<connected-to-master_writedata>),       //                  .writedata
		.master_burstcount      (<connected-to-master_burstcount>),      //                  .burstcount
		.master_waitrequest     (<connected-to-master_waitrequest>),     //                  .waitrequest
		.control_fixed_location (<connected-to-control_fixed_location>), //           control.fixed_location
		.control_write_base     (<connected-to-control_write_base>),     //                  .write_base
		.control_write_length   (<connected-to-control_write_length>),   //                  .write_length
		.control_go             (<connected-to-control_go>),             //                  .go
		.control_done           (<connected-to-control_done>),           //                  .done
		.user_write_buffer      (<connected-to-user_write_buffer>),      //              user.write_buffer
		.user_buffer_input_data (<connected-to-user_buffer_input_data>), //                  .buffer_input_data
		.user_buffer_full       (<connected-to-user_buffer_full>)        //                  .buffer_full
	);

