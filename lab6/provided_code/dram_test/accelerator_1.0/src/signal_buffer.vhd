

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_custom.all;

entity signal_buffer is
generic (
		signal_size : positive := 128;
		element_size : positive  := 16
           );

port (
	clk 	: in std_logic;
	rst 	: in std_logic;
	sig_input : in std_logic_vector (element_size-1 downto 0);
	sig_output	: out std_logic_vector ((element_size * signal_size) - 1 downto 0);
	sig_wr_en 	: in std_logic;
	sig_rd_en 	: in std_logic; 
	sig_empty 	: out std_logic;
	sig_full 	: out std_logic);
end signal_buffer;

architecture default of signal_buffer is
    type reg_array is array(0 to signal_size-1) of std_logic_vector(element_size-1 downto 0);
	signal reg  : reg_array;
	signal count : std_logic_vector(clog2(signal_size) downto 0);   
begin

	U_COUNTER : entity work.count_buf
	generic map(
		buffer_size => signal_size)
		
	port map( user_clk => clk,
			  rst => rst,
			  rd_en => sig_rd_en,
			  wr_en => sig_wr_en,
			  output => count
			  );
			  
	process(clk, rst)
	begin
		if(rst = '1') then
			reg <= (others => (others => '0'));
		elsif(rising_edge(clk)) then
			if(sig_wr_en = '1') then
				reg(0) <= sig_input;
				for i in 0 to signal_size-2 loop
					reg(i + 1) <= reg(i);
				end loop;
			end if;
		end if;
	end process;
	
	process(rst, sig_rd_en, reg)
	begin
		if(rst = '1') then
			sig_output <= (others => '0');
		elsif(sig_rd_en = '1') then
			for j in 0 to signal_size-1 loop
				sig_output((signal_size-j)*element_size - 1 downto (signal_size-1-j)*element_size) <= reg(j);
			end loop;
		else 
			sig_output <= (others => '0');
		end if;
	end process;
	
	process(rst, count, sig_rd_en)
	variable temp_count : positive := signal_size;
	begin
	
		if(count =  std_logic_vector(to_unsigned(temp_count, clog2(signal_size)+1)) and sig_rd_en = '0') then
			sig_full <= '1';
		else
			sig_full <= '0';
		end if;
		
		if(count < std_logic_vector(to_unsigned(temp_count, clog2(signal_size)+1))) then
			sig_empty <= '1';
		else
			sig_empty <= '0';
		end if;
		
	end process;
	
end default;




