	component axi_dma is
		port (
			clk                    : in  std_logic                     := 'X';             -- clk
			reset                  : in  std_logic                     := 'X';             -- reset
			master_address         : out std_logic_vector(31 downto 0);                    -- address
			master_write           : out std_logic;                                        -- write
			master_byteenable      : out std_logic_vector(3 downto 0);                     -- byteenable
			master_writedata       : out std_logic_vector(31 downto 0);                    -- writedata
			master_burstcount      : out std_logic_vector(5 downto 0);                     -- burstcount
			master_waitrequest     : in  std_logic                     := 'X';             -- waitrequest
			control_fixed_location : in  std_logic                     := 'X';             -- fixed_location
			control_write_base     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- write_base
			control_write_length   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- write_length
			control_go             : in  std_logic                     := 'X';             -- go
			control_done           : out std_logic;                                        -- done
			user_write_buffer      : in  std_logic                     := 'X';             -- write_buffer
			user_buffer_input_data : in  std_logic_vector(31 downto 0) := (others => 'X'); -- buffer_input_data
			user_buffer_full       : out std_logic                                         -- buffer_full
		);
	end component axi_dma;

	u0 : component axi_dma
		port map (
			clk                    => CONNECTED_TO_clk,                    --       clock_reset.clk
			reset                  => CONNECTED_TO_reset,                  -- clock_reset_reset.reset
			master_address         => CONNECTED_TO_master_address,         --     avalon_master.address
			master_write           => CONNECTED_TO_master_write,           --                  .write
			master_byteenable      => CONNECTED_TO_master_byteenable,      --                  .byteenable
			master_writedata       => CONNECTED_TO_master_writedata,       --                  .writedata
			master_burstcount      => CONNECTED_TO_master_burstcount,      --                  .burstcount
			master_waitrequest     => CONNECTED_TO_master_waitrequest,     --                  .waitrequest
			control_fixed_location => CONNECTED_TO_control_fixed_location, --           control.fixed_location
			control_write_base     => CONNECTED_TO_control_write_base,     --                  .write_base
			control_write_length   => CONNECTED_TO_control_write_length,   --                  .write_length
			control_go             => CONNECTED_TO_control_go,             --                  .go
			control_done           => CONNECTED_TO_control_done,           --                  .done
			user_write_buffer      => CONNECTED_TO_user_write_buffer,      --              user.write_buffer
			user_buffer_input_data => CONNECTED_TO_user_buffer_input_data, --                  .buffer_input_data
			user_buffer_full       => CONNECTED_TO_user_buffer_full        --                  .buffer_full
		);

