-- Entity: memory_map
-- This entity establishes connections with user-defined addresses and
-- internal FPGA components (e.g. registers and blockRAMs).
--
-- Note: Make sure to use the addresses in user_pkg. Also, in your C code,
-- make sure to use the same constants.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity memory_map is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        wr_en   : in  std_logic;
        wr_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        wr_data : in  std_logic_vector(MMAP_DATA_RANGE);
        rd_en   : in  std_logic;
        rd_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        rd_data : out std_logic_vector(MMAP_DATA_RANGE);

        -- application-specific I/O
        go     : out std_logic;
        n      : out std_logic_vector(31 downto 0);
        result : in  std_logic_vector(31 downto 0);
        done   : in  std_logic
        );
end memory_map;

architecture BHV of memory_map is
  signal next_done_vector : std_logic_vector(31 downto 0);
  signal next_result : std_logic_vector(31 downto 0);
  signal next_go : std_logic;
  signal readable_go : std_logic;
begin
  go <= readable_go;
  
  process(clk, rst)
  begin
    -- Handle write access
    if (rst = '1') then
      readable_go <= '0';
      next_go <= '0';
      next_done_vector <= std_logic_vector(to_unsigned(0, next_done_vector'length));
      next_result <= std_logic_vector(to_unsigned(0, next_done_vector'length));
      n <= std_logic_vector(to_unsigned(0, 32));
    elsif (rising_edge(clk)) then
      next_result <= result;
      next_done_vector(0) <= done;
      next_go <= readable_go;
      readable_go <= '0';
      
      if (wr_en = '1') then
        case addr_type(to_integer(unsigned(wr_addr))) is
        when C_N_ADDR => n <= wr_data;
        when C_GO_ADDR => readable_go <= wr_data(0);
        when others => null;
        end case;
      end if;
    
    -- Handle read access  
      if (rd_en = '1') then
        case addr_type(to_integer(unsigned(rd_addr))) is
        when C_RESULT_ADDR =>
          rd_data <= next_result;
        when C_DONE_ADDR =>
          rd_data <= next_done_vector;
        when C_GO_ADDR =>
          rd_data(0) <= next_go;
        when others => null;
        end case;
      end if;      
    end if;
    
  end process;

end BHV;
