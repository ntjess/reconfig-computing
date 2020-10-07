library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_2x1 is
  generic (
    width: positive := 8
  );
  port(
    in1 : in std_logic_vector(width-1 downto 0);
    in2 : in std_logic_vector(width-1 downto 0);
    sel : in std_logic;
    
    result : out std_logic_vector(width-1 downto 0)
  );
end entity mux_2x1;

architecture RTL of mux_2x1 is
  
begin

  process (in2, in1, sel)
  begin
    case sel is
    when '0' => result <= in1;
    when '1' => result <= in2;
    when others => null;
    end case;
  end process;

end architecture RTL;
