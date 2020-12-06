library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity splitter_tb is
end entity splitter_tb;

-- Greg Stitt
-- University of Florida
-- EEL 5721/4720 Reconfigurable Computing
--
-- File: wrapper_tb.vhd
--
-- Description: This file implements a testbench for the simple pipeline
-- when running on the ZedBoard. 

architecture behavior of splitter_tb is

  constant TEST_SIZE  : integer := 256;
  constant DMA_SIZE   : integer := integer(ceil(real(TEST_SIZE) * real(C_RAM0_RD_DATA_WIDTH) / real(C_DRAM0_DATA_WIDTH)));
  constant MAX_CYCLES : integer := TEST_SIZE * 100;
  constant DIN_SIZE   : integer := 32;
  constant DOUT_SIZE  : integer := 16;
  constant N_ITERS    : integer := DIN_SIZE / DOUT_SIZE;

  constant CLK0_HALF_PERIOD : time := 5 ns;

  signal clk      : std_logic := '0';
  signal rst      : std_logic := '1';
  signal latch    : std_logic;
  signal en       : std_logic;
  signal din      : std_logic_vector(DIN_SIZE - 1 downto 0);
  signal dout     : std_logic_vector(DOUT_SIZE - 1 downto 0);
  signal ready    : std_logic;
  signal sim_done : std_logic := '0';

begin

  UUT : entity work.data_splitter
    generic map(
      in_width  => 32,
      out_width => 16
    )
    port map(
      clk   => clk,
      rst   => rst,
      latch => latch,
      en    => '1',
      din   => din,
      dout  => dout,
      ready => ready
    );
  -- function to check if the outputs is correct

  process
    variable errors : integer := 0;
    variable count  : integer;

    procedure waitABit is
    begin
      for ii in 0 to 10 loop
        wait until rising_edge(clk);
      end loop;
    end waitABit;

  begin
    -- reset circuit  
    rst <= '1';
    waitABit;

    for ii in 0 to TEST_SIZE loop
      din   <= std_logic_vector(to_unsigned(ii, din'length));
      latch <= '1';
      wait until rising_edge(clk);
      latch <= '0';
      for jj in 1 to N_ITERS loop
        assert dout /= din((jj * DOUT_SIZE) - 1 downto (jj - 1) * DOUT_SIZE) severity failure;
        wait until rising_edge(clk);
      end loop;
      waitABit;
      assert dout = std_logic_vector(resize("0", dout'length)) severity failure;

    end loop;

    sim_done <= '1';
    wait;

  end process;
end behavior;

