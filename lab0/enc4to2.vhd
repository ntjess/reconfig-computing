library ieee;
use ieee.std_logic_1164.all;

entity enc4to2 is
  port(
    input  : in  std_logic_vector(3 downto 0);
    output : out std_logic_vector(1 downto 0);
    valid  : out std_logic);
end enc4to2;

-- TODO: implement the priority encoder using an if statement

architecture IF_STATEMENT of enc4to2 is
begin
  process(input)
  begin
    valid <= '1';
    if (input(3) = '1') then
      output <= "11";
    elsif (input(2) = '1') then
      output <= "10";
    elsif (input(1) = '1') then
      output <= "01";
    elsif (input(0) = '1') then
      output <= "00";
    else
      output <= "00";
      valid  <= '0';
    end if;
  end process;
end IF_STATEMENT;

-- TODO: Implement the priority encoder using a case statement. Note that this
-- architecture will be slightly trickier because a case statement has no
-- notion of priority.

architecture CASE_STATEMENT of enc4to2 is
begin
  process(input)
  begin
    -- Looking at a K-Map solution to each output bit produced the following combinations:

    -- Handle output MSB
    case input(3 downto 2) is
      when "10"   => output(1) <= '1';
      when "01"   => output(1) <= '1';
      when "11"   => output(1) <= '1';
      when others => output(1) <= '0';
    end case;

    -- Handle output LSB
    case input is
      when "0000" => output(0) <= '0';
      when "0001" => output(0) <= '0';
      when "0100" => output(0) <= '0';
      when "0101" => output(0) <= '0';
      when "0110" => output(0) <= '0';
      when "0111" => output(0) <= '0';
      when others => output(0) <= '1';
    end case;

    -- Handle valid
    case input is
      when "0000" => valid <= '0';
      when others => valid <= '1';
    end case;
  end process;
end CASE_STATEMENT;

