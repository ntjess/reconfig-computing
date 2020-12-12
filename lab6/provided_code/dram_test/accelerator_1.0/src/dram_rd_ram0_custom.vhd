library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.user_pkg.all;
use work.math_custom.all;

entity dram_rd_ram0_custom is
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
end entity dram_rd_ram0_custom;

architecture RTL of dram_rd_ram0_custom is

  component fifo_32_custom
      port (
        rst : in std_logic;
        wr_clk : in std_logic;
        rd_clk : in std_logic;
        din : in std_logic_vector(31 downto 0);
        wr_en : in std_logic;
        rd_en : in std_logic;
        dout : out std_logic_vector(15 downto 0);
        full : out std_logic;
        empty : out std_logic;
        prog_full : out std_logic;
        wr_rst_busy : out std_logic;
        rd_rst_busy : out std_logic
      );
  end component;

  signal size_reg : std_logic_vector(size'range);
  signal start_addr_reg : std_logic_vector(start_addr'range);
  
  signal go_addr_gen : std_logic;
  signal en_addr_gen : std_logic;
  signal dram_rd_en_s     : std_logic;
  
  signal fifo_empty : std_logic;
  signal fifo_prog_full : std_logic;
  signal fifo_empty_history, block_first_rd : std_logic;
  signal fifo_din : std_logic_vector(dram_rd_data'range);
  
  -- Just to make sure the code is recompiling
  constant CODE_VER : integer := 11;
  
  signal valid_s:  std_logic;
  
  constant max_count_val : integer := 2**16;
  signal count_val : std_logic_vector(bitsNeeded(max_count_val) - 1 downto 0);
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
    
    
    U_FIFO_EMPTY_HISTORY : entity work.reg
    generic map(
      width => 1,
      init  => '0'
    )
    port map(
      clk    => user_clk,
      rst    => rst,
      en     => '1',
      input(0)  => fifo_empty,
      output(0) => fifo_empty_history
    );
    block_first_rd <= (not fifo_empty) and fifo_empty_history;
    
    
    fifo_din <= dram_rd_data(dram_rd_data'length/2-1 downto 0) & dram_rd_data(dram_rd_data'length-1 downto dram_rd_data'length/2);
    U_FIFO : fifo_32_custom
      port map(
        rst         => rst,
        wr_clk      => dram_clk,
        rd_clk      => user_clk,
        din         => fifo_din,
        wr_en       => dram_rd_valid,
        rd_en       => rd_en or block_first_rd,
        dout        => data,
        full        => open,
        empty       => fifo_empty,
        prog_full   => fifo_prog_full,
        wr_rst_busy => open,
        rd_rst_busy => open
      );
          
  -- DRAM Clock
  
  en_addr_gen <= dram_ready and (not fifo_prog_full);
  
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
      rd_en => dram_rd_en_s,
      rd_addr => dram_rd_addr
    );
    dram_rd_en <= dram_rd_en_s;
    
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
      max_value => max_count_val
    )
    port map(
      clk    => dram_rd_en_s,
      rst    => rst,
      up     => '1',
      en     => '1',
      output => count_val
    );

  done_s <= '1' when (to_integer(unsigned(count_val)) = to_integer(unsigned(size_reg))) else '0';
  valid_s <= (not fifo_empty) and (not block_first_rd);
  done <= done_s;
  valid <= valid_s;

end architecture RTL;
