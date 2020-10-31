library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.user_pkg.all;
use work.config_pkg.all;

entity addr_generator is
  port(
    clk : in std_logic;
    rst : in std_logic;
    en  : in std_logic;
    
    size : in std_logic_vector(C_MEM_ADDR_WIDTH downto 0);
    
    out_addr : out std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0);
    done : out std_logic
  );
end entity addr_generator;

architecture RTL of addr_generator is
  signal next_addr  : unsigned(C_MEM_ADDR_WIDTH-1 downto 0) := (others => '0');
begin

process (clk, rst)
begin
  if (rst = '1') then
    next_addr <= to_unsigned(0, C_MEM_ADDR_WIDTH);
    done <= '0';
  elsif (rising_edge(clk)) then
    done <= '0';
    if (en = '1') then
      out_addr  <= std_logic_vector(next_addr);
      if next_addr < unsigned(size) then
        next_addr <= next_addr + 1;
      else
        done <= '1';
      end if;
    end if;
  end if;
  
end process;

end architecture RTL;
