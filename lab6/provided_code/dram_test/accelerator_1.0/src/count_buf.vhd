
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use  work.math_custom.all;
use work.config_pkg.all;
use work.user_pkg.all;

entity count_buf is 
generic(
		buffer_size : positive := 128);
	
port(
	user_clk, rst, rd_en, wr_en :in std_logic;
	output : out std_logic_vector(clog2(buffer_size) downto 0)
);

end count_buf;

architecture BHV of count_buf is

--signal count_s : unsigned(16 downto 0);
signal count : std_logic_vector(clog2(buffer_size) downto 0);

begin

process(user_clk, rst)

--variable count_s : unsigned(16 downto 0);
	variable count_s : std_logic_vector(clog2(buffer_size) downto 0);
	begin
		if (rst = '1') then
			count<= (others => '0');
			elsif(rising_edge(user_clk)) then
				count_s := count;					
					
			if(rd_en= '1' and unsigned(count_s) /= 0) then
				count_s := std_logic_vector(unsigned(count_s) - 1);
			end if;
			
			if(wr_en= '1' and unsigned(count_s) < buffer_size) then
				count_s := std_logic_vector(unsigned(count_s) + 1);
			end if;
			count <= count_s;
		end if;
end process;
	output <= count;
	
end BHV;