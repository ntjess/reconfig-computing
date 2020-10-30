-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity user_app is
    port (
        clk : in std_logic;
        rst : in std_logic;

        -- memory-map interface
        mmap_wr_en   : in  std_logic;
        mmap_wr_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_wr_data : in  std_logic_vector(MMAP_DATA_RANGE);
        mmap_rd_en   : in  std_logic;
        mmap_rd_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_rd_data : out std_logic_vector(MMAP_DATA_RANGE)
        );
end user_app;

architecture default of user_app is

    signal go   : std_logic;
    signal size : std_logic_vector(C_MEM_ADDR_WIDTH downto 0);
    signal done : std_logic;

    signal mem_in_wr_data       : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
    signal mem_in_wr_addr       : std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0);
    signal mem_in_rd_data       : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
    signal mem_in_rd_addr       : std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0);
    signal mem_in_wr_en         : std_logic;
    signal mem_in_rd_addr_valid : std_logic;

    signal mem_out_wr_data       : std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0);
    signal mem_out_wr_addr       : std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0);
    signal mem_out_rd_data       : std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0);
    signal mem_out_rd_addr       : std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0);
    signal mem_out_wr_en         : std_logic;
    signal mem_out_wr_data_valid : std_logic;
    signal mem_out_done          : std_logic;
    
    signal mem_in_valid_delay    : std_logic;
    
begin
  
------------------------------------------------------------------------------
    U_MMAP : entity work.memory_map
        port map (
            clk     => clk,
            rst     => rst,
            wr_en   => mmap_wr_en,
            wr_addr => mmap_wr_addr,
            wr_data => mmap_wr_data,
            rd_en   => mmap_rd_en,
            rd_addr => mmap_rd_addr,
            rd_data => mmap_rd_data,
		
			-- TODO: connect to appropriate logic
            go              => go,         
            size            => size,       
            done            => done,       
			
			-- already connected to block RAMs
			-- the memory map functionality writes to the input ram
			-- and reads from the output ram
            mem_in_wr_data  => mem_in_wr_data,
            mem_in_wr_addr  => mem_in_wr_addr,
            mem_in_wr_en    => mem_in_wr_en,
            mem_out_rd_data => mem_out_rd_data,
            mem_out_rd_addr => mem_out_rd_addr
            );
	------------------------------------------------------------------------------

	
	------------------------------------------------------------------------------
    -- input memory
    -- written to by memory map
    -- read from by controller+datapath
    U_MEM_IN : entity work.ram(SYNC_READ)
        generic map (
            num_words  => 2**C_MEM_ADDR_WIDTH,
            word_width => C_MEM_IN_WIDTH,
            addr_width => C_MEM_ADDR_WIDTH)
        port map (
            clk   => clk,
            wen   => mem_in_wr_en,
            waddr => mem_in_wr_addr,
            wdata => mem_in_wr_data,
            raddr => mem_in_rd_addr,  -- TODO: connect to input address generator (COMPLETE)
            rdata => mem_in_rd_data); -- TODO: connect to pipeline input (COMPLETE)
	------------------------------------------------------------------------------

	
	------------------------------------------------------------------------------
    -- output memory
    -- written to by controller+datapath
    -- read from by memory map
    U_MEM_OUT : entity work.ram(SYNC_READ)
        generic map (
            num_words  => 2**C_MEM_ADDR_WIDTH,
            word_width => C_MEM_OUT_WIDTH,
            addr_width => C_MEM_ADDR_WIDTH)
        port map (
            clk   => clk,
            wen   => mem_out_wr_en,
            waddr => mem_out_wr_addr,  -- TODO: connect to output address generator (COMPLETE)
            wdata => mem_out_wr_data,  -- TODO: connect to pipeline output
            raddr => mem_out_rd_addr,
            rdata => mem_out_rd_data);
	------------------------------------------------------------------------------
	
	
	-- TODO: instatiate controllerm datapath/pipeline, address generators, (COMPLETE)
	-- and any other necessary logic
	
	U_DP : entity work.datapath
	  port map(
	    clk       => clk,
	    en        => mem_in_valid_delay,
	    rst       => rst,
	    in1       => mem_in_rd_data(31 downto 24),
	    in2       => mem_in_rd_data(23 downto 16),
	    in3       => mem_in_rd_data(15 downto 8),
	    in4       => mem_in_rd_data(7 downto 0),
	    output    => mem_out_wr_data,
	    out_valid => mem_out_wr_en
	  );
	  
  U_CTRL : entity work.controller
    port map(
      clk                  => clk,
      rst                  => rst,
      go                   => go,
      done                 => mem_out_done,
      go_buffer            => open,
      done_buffer          => done,
      flush_pipeline_valid => open,
      in_addr_en           => mem_in_rd_addr_valid
    );
    
  U_IN_ADDR_GEN : entity work.addr_generator
    port map(
      clk      => clk,
      rst      => rst,
      en       => mem_in_rd_addr_valid,
      size     => size,
      out_addr => mem_in_rd_addr,
      done     => open
    );
    
  U_OUT_ADDR_GEN : entity work.addr_generator
    port map(
      clk      => clk,
      rst      => rst,
      en       => mem_out_wr_en,
      size     => size,
      out_addr => mem_out_wr_addr,
      done     => mem_out_done
    );
    
  U_IN_DELAY : entity work.reg
    generic map (
        width => 1
    )
    port map(
      clk => clk,
      rst => rst,
      en => '1',
      input(0) => mem_in_rd_addr_valid,
      output(0) => mem_in_valid_delay
    );
    
  -- U_OUT_DELAY : entity work.reg
    -- generic map (
        -- width => 1
    -- )
    -- port map(
      -- clk => clk,
      -- rst => rst,
      -- en => '1',
      -- input(0) => mem_in_rd_addr_valid,
      -- output(0) => mem_in_valid_delay
    -- );
end default;
