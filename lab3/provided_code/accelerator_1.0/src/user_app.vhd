library ieee;
use ieee.std_logic_1164.all;

use work.config_pkg.all;

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

    signal go     : std_logic;
    signal n      : std_logic_vector(31 downto 0);
    signal result : std_logic_vector(31 downto 0);
    signal done   : std_logic;
begin

	-- connect memory map and fib entity


end default;
