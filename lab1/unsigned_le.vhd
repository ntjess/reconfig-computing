library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unsigned_le is
  generic (
    width: positive := 8
  );
  port(
    in1 : in std_logic_vector(width-1 downto 0);
    in2 : in std_logic_vector(width-1 downto 0);
    
    in1_le_in2 : out std_logic
  );
end entity unsigned_le;

architecture RTL of unsigned_le is
begin
  
  process (in2, in1)
  begin
    if unsigned(in1) <= unsigned(in2) then
      in1_le_in2 <= '1';
    else
      in1_le_in2 <= '0';
    end if;
  end process;

end architecture RTL;
