library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_custom.all;


entity kernel_buffer is
generic (
	kernel_size  : positive := 128;
	element_size : positive  := 16
           );
port (	clk 	: in std_logic;
		rst 	: in std_logic;
		kernel_input : in std_logic_vector (element_size-1 downto 0);
		kernel_output	: out std_logic_vector ((element_size * kernel_size) - 1 downto 0);
		ker_wr_en	: in std_logic;			
		ker_rd_en	: in std_logic; 
		ker_empty	: out std_logic;		
		ker_full	: out std_logic);		
end kernel_buffer;

architecture default of kernel_buffer is
    type reg_array is array(0 to kernel_size-1) of std_logic_vector(element_size-1 downto 0);
	signal reg  : reg_array;
	signal count : std_logic_vector(clog2(kernel_size) downto 0);  
begin

	U_COUNTER : entity work.count_buf
	generic map(
		buffer_size => kernel_size)
	port map( user_clk => clk,
			  rst => rst,
			  rd_en => std_logic'('0'),
			  wr_en => ker_wr_en,
			  output => count
			  );
			  
	process(rst, clk)
	begin
		if(rst = '1') then
			reg <= (others => (others => '0'));
		elsif(rising_edge(clk)) then
			if(ker_wr_en = '1') then
				reg(0) <= kernel_input;
				for i in 0 to kernel_size-2 loop
					reg(i + 1) <= reg(i);
				end loop;
			end if;
		end if;
	end process;
	
	process(rst, ker_rd_en, reg)
	begin
		if(rst = '1') then
			kernel_output <= (others => '0');
		else 
			if(ker_rd_en = '1') then
				for j in 0 to kernel_size-1 loop
					kernel_output((j+1)*element_size - 1 downto (j*element_size)) <= reg(j);
				end loop;
			else
				kernel_output <= (others => '0');
			end if;
		end if;
	end process;

	process(count, rst )
	variable temp_count : positive := kernel_size;
	begin
		if(rst = '1') then
			ker_full <= '0';
		else
			if(count =  std_logic_vector(to_unsigned(temp_count, clog2(kernel_size)+1) )) then
				ker_full <= '1';
			else 
				ker_full <= '0';
			end if;
		end if;
		
		if(rst = '1') then
			ker_empty  <= '1';
		elsif(count < std_logic_vector(to_unsigned(temp_count, clog2(kernel_size)+1))) then
			ker_empty <= '1';
		else
			ker_empty <= '0';
		end if;
	end process;
	

end default;







