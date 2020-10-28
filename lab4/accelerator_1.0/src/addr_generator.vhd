library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.user_pkg.all;

entity addr_generator is
  port(
    clk : in std_logic;
    rst : in std_logic;
    en  : in std_logic;
    
    out_addr : out std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0);
    done : out std_logic
  );
end entity addr_generator;

architecture RTL of addr_generator is
  signal next_addr  : unsigned(C_MEM_ADDR_WIDTH-1 downto 0);
begin

process (clk, rst)
begin
  if (rst = '1') then
    next_addr <= to_unsigned(0, C_MEM_ADDR_WIDTH);
  elsif (rising_edge(clk)) then
    out_addr  <= std_logic_vector(next_addr);
    if (en = '1') then
      next_addr <= next_addr + 4;
    end if;
  end if;
  
end process;

end architecture RTL;
