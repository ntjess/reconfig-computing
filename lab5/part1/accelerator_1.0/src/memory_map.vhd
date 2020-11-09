-- Greg Stitt
-- University of Florida

-- Entity: memory_map
-- This entity establishes connections with user-defined addresses and
-- internal FPGA components (e.g. registers and blockRAMs).
--
-- Note: Make sure to add any new addresses to user_pkg. Also, in your C code,
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

        -- app-specific signals
        go         : out std_logic;
        iterations : out std_logic_vector(31 downto 0);
        count      : in  std_logic_vector(31 downto 0);
        done       : in  std_logic
        );
end memory_map;

architecture BHV of memory_map is

    signal reg_go         : std_logic;
    signal reg_iterations : std_logic_vector(31 downto 0);

begin

    process(clk, rst)
    begin
        if (rst = '1') then
            reg_go         <= '0';
            reg_iterations <= std_logic_vector(to_unsigned(0, 32));
            rd_data        <= (others => '0');

        elsif (rising_edge(clk)) then

            reg_go <= '0';

            if (wr_en = '1') then

                case wr_addr is
                    when C_GO_ADDR(MMAP_ADDR_RANGE) =>
                        reg_go <= wr_data(0);
                    when C_ITERATIONS_ADDR(MMAP_ADDR_RANGE) =>
                        reg_iterations <= wr_data(reg_iterations'range);

                    when others => null;
                end case;
            end if;

            if (rd_en = '1') then

                rd_data <= (others => '0');

                case rd_addr is
                    when C_GO_ADDR(MMAP_ADDR_RANGE) =>
                        rd_data(0) <= reg_go;
                    when C_ITERATIONS_ADDR(MMAP_ADDR_RANGE) =>
                        rd_data(reg_iterations'range) <= reg_iterations;
                    when C_COUNT_ADDR(MMAP_ADDR_RANGE) =>
                        rd_data(count'range) <= count;
                    when C_DONE_ADDR(MMAP_ADDR_RANGE) =>
                        rd_data(0) <= done;

                    when others => null;
                end case;
            end if;

        end if;
    end process;

    go         <= reg_go;
    iterations <= reg_iterations;

end BHV;
