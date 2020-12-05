library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.user_pkg.all;

entity dram_rd_ram0 is
  port(
    dram_clk   : in  std_logic;
    user_clk   : in  std_logic;
    rst        : in  std_logic;
    clear      : in  std_logic;
    go         : in  std_logic;
    rd_en      : in  std_logic;
    stall      : in  std_logic;
    start_addr : in  std_logic_vector(RAM0_ADDR_RANGE);
    size       : in  std_logic_vector(RAM0_RD_SIZE_RANGE);
    valid      : out std_logic;
    data       : out std_logic_vector(RAM0_RD_DATA_RANGE);
    done       : out std_logic;
    
    dram_ready    : in  std_logic;
    dram_rd_en    : out std_logic;
    dram_rd_addr  : out std_logic_vector(RAM0_ADDR_RANGE);
    dram_rd_data  : in  std_logic_vector(RAM0_WR_DATA_RANGE);
    dram_rd_valid : in  std_logic;
    dram_rd_flush : out std_logic
  );
end entity dram_rd_ram0;

--port map (
--  -- user dma control signals
--  dram_clk   => clks(C_CLK_DRAM),
--  user_clk   => clks(C_CLK_USER),
--  rst        => rst_s,
--  clear      => ram0_rd_clear,
--  go         => ram0_rd_go,
--  rd_en      => ram0_rd_rd_en,
--  stall      => C_0,
--  start_addr => ram0_rd_addr,
--  size       => ram0_rd_size,
--  valid      => ram0_rd_valid,
--  data       => ram0_rd_data,
--  done       => ram0_rd_done,
--
--  -- dram control signals
--  dram_ready    => dram0_ready,
--  dram_rd_en    => dram0_rd_en,
--  dram_rd_addr  => dram0_rd_addr,
--  dram_rd_data  => dram0_rd_data,
--  dram_rd_valid => dram0_rd_valid,
--  dram_rd_flush => dram0_rd_flush
--);

architecture RTL of dram_rd_ram0 is
  signal size_reg : std_logic_vector(size'range);
  signal start_addr_reg : std_logic_vector(start_addr'range);
  
  signal go_addr_gen : std_logic;
  signal en_addr_gen : std_logic;
  
  signal fifo_empty : std_logic;
  signal fifo_prog_full : std_logic;
  signal fifo_dout : std_logic_vector(C_RAM0_WR_DATA_WIDTH-1 downto 0);
  
  signal splitter_ready, splitter_en : std_logic;
  
  signal count_val : std_logic_vector(clog2(size'length) downto 0);
  signal done_s : std_logic;
begin
  
  -- Shared Clock
  
  U_HANDSHAKE: entity work.handshake
    port map(
      clk_src   => user_clk,
      clk_dest  => dram_clk,
      rst       => rst,
      go        => go,
      delay_ack => '0',
      rcv       => go_addr_gen,
      ack       => open
    );
        
    U_FIFO : entity work.fifo_32_prog_full
      port map(
        rst       => rst,
        wr_clk    => dram_clk,
        rd_clk    => user_clk,
        din       => dram_rd_data,
        wr_en     => dram_rd_valid,
        rd_en     => rd_en,
        dout      => fifo_dout,
        full      => open,
        empty     => fifo_empty,
        prog_full => fifo_prog_full
      );
      -- Splitter is ready when all valid data is gone. So,
      -- data is valid as long as the splitter can't accept new data
      valid <= not splitter_ready;
      
    splitter_en <= not fifo_empty;
    U_SPLITTER : entity work.data_splitter
      generic map(
        in_width  => C_RAM0_WR_DATA_WIDTH,
        out_width => C_RAM0_RD_DATA_WIDTH
      )
      port map(
        clk       => user_clk,
        rst       => rst,
        latch     => valid,
        en        => splitter_en,
        din       => fifo_dout,
        dout      => data,
        ready     => splitter_ready
      );
  
  -- DRAM Clock
  
  en_addr_gen <= dram_ready and (not fifo_prog_full) and (not done_s);
  U_ADDR_GEN : entity work.addr_gen
    generic map(
      width => C_RAM0_ADDR_WIDTH
    )
    port map(
      clk => dram_clk,
      rst => rst,
      size => size_reg(C_RAM0_ADDR_WIDTH downto 0),
      start_addr => start_addr_reg,
      go => go_addr_gen,
      en => en_addr_gen,
      rd_en => dram_rd_en,
      rd_addr => dram_rd_addr
    );
    
  -- User clock
  U_SIZE_DELAY_REG : entity work.reg
    generic map(
      width => size'length,
      init  => '0'
    )
    port map(
      clk    => user_clk,
      rst    => rst,
      en     => '1',
      input  => size,
      output => size_reg
    );
    
  U_START_ADDR_DELAY_REG : entity work.reg
    generic map(
      width => start_addr'length,
      init  => '0'
    )
    port map(
      clk    => user_clk,
      rst    => rst,
      en     => '1',
      input  => start_addr,
      output => start_addr_reg
    );
  
  U_COUNTER : entity work.counter
    generic map(
      max_value => to_integer(unsigned(size))
    )
    port map(
      clk    => user_clk,
      rst    => rst,
      up     => '1',
      en     => rd_en,
      output => count_val
    );

  done_s <= fifo_empty and std_logic(unsigned(count_val) = unsigned(size_reg));
  done <= done_s;

end architecture RTL;
