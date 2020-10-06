library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fib_fsmd is
  generic
  (
    width: natural := 8
  );
  port(
    clk : in std_logic;
    rst : in std_logic;
    
    go : in std_logic;
    n : in std_logic_vector(width-1 downto 0);
    
    done : out std_logic;
    result : out std_logic_vector(width-1 downto 0)
    
  );
end entity fib_fsmd;

architecture RTL of fib_fsmd is
  type t_state is (init, prep_incr, incr_xyi, found_fib, wait_go_clear);
  signal state: t_state := init;
  signal next_state: t_state;
  
  signal i, next_i, x, next_x, y, next_y, n_reg : unsigned(width-1 downto 0);
begin
  
  process(clk, rst)
  begin
    if (rst = '1') then
      state <= init;
    elsif(rising_edge(clk)) then
      state <= next_state;
      y <= next_y;
      x <= next_x;
      i <= next_i;
    end if;
  end process;
  
  process(state, go, n_reg, i)
  begin
    next_state <= state;
    done <= '0';
    result <= std_logic_vector(y);
    
    case state is
    when init =>
      if (go = '1') then
        next_state <= prep_incr;
      end if;
    when prep_incr =>
      n_reg <= unsigned(n);
      next_i <= to_unsigned(2, i'length);
      next_x <= to_unsigned(0, i'length);
      next_y <= to_unsigned(1, i'length);
      next_state <= incr_xyi;
    when incr_xyi =>
      if (i >= n_reg) then
        next_state <= found_fib;
      end if;
      next_i <= i + to_unsigned(1, i'length);
      next_x <= y;
      next_y <= y + x;
    when found_fib =>
      done <= '1';
      next_state <= wait_go_clear;
    when wait_go_clear =>
      done <= '1';
      if (go = '0') then
        next_state <= init;
      end if;
    end case;
  end process;


end architecture RTL;
