library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.config_pkg.all;
use work.user_pkg.all;

entity controller is
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		go : in std_logic;
		start_in_addr  : in std_logic_vector(MMAP_ADDR_RANGE);
		start_out_addr : in std_logic_vector(MMAP_ADDR_RANGE);
		end_in_addr : in std_logic_vector(MMAP_ADDR_RANGE);
		
    done : out std_logic
	);
end entity controller;

architecture RTL of controller is
	signal en : std_logic;
	signal cur_in_addr : std_logic_vector(MMAP_ADDR_RANGE);
	signal cur_out_addr : std_logic_vector(MMAP_ADDR_RANGE);
	signal end_in_addr_reg : std_logic_vector(MMAP_ADDR_RANGE);
	
	type t_state is (s_reset, s_wait_go_1, s_populate_datapath, s_populate_datapah_and_outputs, s_wait_go_0);
	signal state, next_state : t_state;
begin
  process (clk, rst)
  begin
    if (rst = '1') then
      next_state <= s_reset;
    elsif (rising_edge(clk)) then
      state <= next_state;
      
      case state is 
        when s_reset =>
          done <= '0';
          next_state <= s_wait_go_1;
        when s_wait_go_1 =>
          cur_in_addr <= start_in_addr;
          cur_out_addr <= start_out_addr;
          end_in_addr_reg <= end_in_addr;
          if (go = '1') then
            next_state <= s_populate_datapath;
          end if;        
        when s_populate_datapath =>
          
          null;
        when s_populate_datapah_and_outputs =>
          null;
        when s_wait_go_0 =>
          null;
      end case;
    end if;
  end process;

end architecture RTL;
