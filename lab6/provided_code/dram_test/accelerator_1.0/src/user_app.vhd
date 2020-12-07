-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.config_pkg.all;
use work.user_pkg.all;
use work.math_custom.all;

entity user_app is
generic (buffer_size: positive  := 128;
         reg_size :positive := 16  );
    port (
        clks   : in  std_logic_vector(NUM_CLKS_RANGE);
        rst    : in  std_logic;
        sw_rst : out std_logic;

        -- memory-map interface
        mmap_wr_en   : in  std_logic;
        mmap_wr_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_wr_data : in  std_logic_vector(MMAP_DATA_RANGE);
        mmap_rd_en   : in  std_logic;
        mmap_rd_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_rd_data : out std_logic_vector(MMAP_DATA_RANGE);

        -- DMA interface for RAM 0
        -- read interface
        ram0_rd_rd_en : out std_logic;
        ram0_rd_clear : out std_logic;
        ram0_rd_go    : out std_logic;
        ram0_rd_valid : in  std_logic;
        ram0_rd_data  : in  std_logic_vector(RAM0_RD_DATA_RANGE);
        ram0_rd_addr  : out std_logic_vector(RAM0_ADDR_RANGE);
        ram0_rd_size  : out std_logic_vector(RAM0_RD_SIZE_RANGE);
        ram0_rd_done  : in  std_logic;
        -- write interface
        ram0_wr_ready : in  std_logic;
        ram0_wr_clear : out std_logic;
        ram0_wr_go    : out std_logic;
        ram0_wr_valid : out std_logic;
        ram0_wr_data  : out std_logic_vector(RAM0_WR_DATA_RANGE);
        ram0_wr_addr  : out std_logic_vector(RAM0_ADDR_RANGE);
        ram0_wr_size  : out std_logic_vector(RAM0_WR_SIZE_RANGE);
        ram0_wr_done  : in  std_logic;

        -- DMA interface for RAM 1
        -- read interface
        ram1_rd_rd_en : out std_logic;
        ram1_rd_clear : out std_logic;
        ram1_rd_go    : out std_logic;
        ram1_rd_valid : in  std_logic;
        ram1_rd_data  : in  std_logic_vector(RAM1_RD_DATA_RANGE);
        ram1_rd_addr  : out std_logic_vector(RAM1_ADDR_RANGE);
        ram1_rd_size  : out std_logic_vector(RAM1_RD_SIZE_RANGE);
        ram1_rd_done  : in  std_logic;
        -- write interface
        ram1_wr_ready : in  std_logic;
        ram1_wr_clear : out std_logic;
        ram1_wr_go    : out std_logic;
        ram1_wr_valid : out std_logic;
        ram1_wr_data  : out std_logic_vector(RAM1_WR_DATA_RANGE);
        ram1_wr_addr  : out std_logic_vector(RAM1_ADDR_RANGE);
        ram1_wr_size  : out std_logic_vector(RAM1_WR_SIZE_RANGE);
        ram1_wr_done  : in  std_logic
        );
end user_app;

architecture default of user_app is

    signal go        : std_logic;
    signal sw_rst_s  : std_logic;
    signal rst_s     : std_logic;
    signal size      : std_logic_vector(RAM0_RD_SIZE_RANGE);
    signal done      : std_logic;
	
	signal sig_data_output: std_logic_vector ((buffer_size*reg_size) - 1 downto 0);
	signal sig_rd_en : std_logic;
	signal sig_wr_en : std_logic;	
	signal sig_empty : std_logic;
	signal sig_full   : std_logic;
	
	signal ker_data_output : std_logic_vector ((buffer_size*reg_size) - 1 downto 0);
	signal ker_rd_en   : std_logic;
	signal ker_wr_en   : std_logic;
	signal ker_output_data : std_logic_vector(15 downto 0);
	signal ker_empty   : std_logic;
	signal ker_full    : std_logic;
	
	signal mult_add_tree_en	    : std_logic;
	signal mult_add_tree_output : std_logic_vector(38 downto 0);
	signal mult_add_tree_clipped : std_logic_vector(15 downto 0);
	signal mult_add_tree_valid_in : std_logic;
	signal mult_add_tree_valid_out : std_logic;

begin

    U_MMAP : entity work.memory_map
        port map (
            clk     => clks(C_CLK_USER),
            rst     => rst,
            wr_en   => mmap_wr_en,
            wr_addr => mmap_wr_addr,
            wr_data => mmap_wr_data,
            rd_en   => mmap_rd_en,
            rd_addr => mmap_rd_addr,
            rd_data => mmap_rd_data,

            -- dma interface for accessing DRAM from software
            ram0_wr_ready => ram0_wr_ready,
            ram0_wr_clear => ram0_wr_clear,
            ram0_wr_go    => ram0_wr_go,
            ram0_wr_valid => ram0_wr_valid,
            ram0_wr_data  => ram0_wr_data,
            ram0_wr_addr  => ram0_wr_addr,
            ram0_wr_size  => ram0_wr_size,
            ram0_wr_done  => ram0_wr_done,

            ram1_rd_rd_en => ram1_rd_rd_en,
            ram1_rd_clear => ram1_rd_clear,
            ram1_rd_go    => ram1_rd_go,
            ram1_rd_valid => ram1_rd_valid,
            ram1_rd_data  => ram1_rd_data,
            ram1_rd_addr  => ram1_rd_addr,
            ram1_rd_size  => ram1_rd_size,
            ram1_rd_done  => ram1_rd_done,

            -- circuit interface from software
            go        => go,
            sw_rst    => sw_rst_s,
			signal_size 	=> size,
            kernel_data 	=> ker_output_data,
			kernel_load 	=> ker_wr_en,
			kernel_loaded 	=> ker_full,
            done            => done
            );

    rst_s  <= rst or sw_rst_s;
    sw_rst <= sw_rst_s;

    U_CTRL : entity work.ctrl
        port map (
            clk           => clks(C_CLK_USER),
            rst           => rst_s,
            go            => go,
            mem_in_go     => ram0_rd_go,
            mem_out_go    => ram1_wr_go,
            mem_in_clear  => ram0_rd_clear,
            mem_out_clear => ram1_wr_clear,
            mem_out_done  => ram1_wr_done,
            done          => done);

    ram0_rd_rd_en <=ker_full and (not sig_full) and ram0_rd_valid ; -- ram0_rd_valid and (not sig_full) ;
    ram0_rd_size  <= std_logic_vector(2*(buffer_size -1)+unsigned(size));
    ram0_rd_addr  <= (others => '0');
    ram1_wr_size  <= std_logic_vector((buffer_size-1)+unsigned(size));
    ram1_wr_addr  <= (others => '0');
    ram1_wr_data  <= mult_add_tree_clipped;
	
	
	U_MULT_ADD_TREE : entity work.mult_add_tree(unsigned_arch)
		generic map(num_inputs   => 128,
					input1_width => reg_size,
					input2_width => reg_size)
		port map( clk 		=> clks(C_CLK_USER),
				  rst 		=> rst,
				  en 		=> mult_add_tree_en,
				  input1	=> sig_data_output,
				  input2	=> ker_data_output,
				  output	=> mult_add_tree_output,
				  valid_in_delay  => mult_add_tree_valid_in,
				  valid_out_delay => mult_add_tree_valid_out );
				  			  
				  
	
	U_SIGNAL_BUFFER: entity work.signal_buffer	
		generic map( signal_size => buffer_size,
					 element_size => reg_size)
		port map( clk 		=> clks(C_CLK_USER),
				  rst 		=> rst,
				  sig_input	=> ram0_rd_data,
				  sig_output 	=> sig_data_output,
				  sig_wr_en 	=> sig_wr_en,
				  sig_rd_en 	=> sig_rd_en,
				  sig_empty  	=> sig_empty,
				  sig_full 		=> sig_full);
				  
				  
				  
    sig_wr_en <= ram0_rd_valid;				  
	sig_rd_en <=  ker_full and ram1_wr_ready and (not sig_empty);
				

	U_KERNEL_BUFFER: entity work.kernel_buffer
		generic map( kernel_size => buffer_size,
					 element_size => reg_size)
		port map( clk 		=> clks(C_CLK_USER),
				  rst 		=> rst,
				  kernel_input 	=> ker_output_data,
				  kernel_output    => ker_data_output,
				  ker_wr_en	=> ker_wr_en,
				  ker_rd_en 	=> ker_rd_en,
				  ker_empty 	=> ker_empty,
				  ker_full      => ker_full );
	ker_rd_en <= ram1_wr_ready and ker_full;

		
		mult_add_tree_en <= ram1_wr_ready;
		mult_add_tree_valid_in <=  (ker_full and (not sig_empty) and (not sig_full) and ram1_wr_ready );		  
				  
		process(mult_add_tree_output)
	       variable temp  : positive := 65535;
	        begin
		         if(mult_add_tree_output > std_logic_vector(to_unsigned(temp, 39)) ) then
			      mult_add_tree_clipped  <= "1111111111111111";
		         else
			       mult_add_tree_clipped   <= mult_add_tree_output(15 downto 0);
		         end if;
		
	    end process;		  
       ram1_wr_valid <= mult_add_tree_valid_out;
end default;
