library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fib_ctrl is
  port(
    clk : in std_logic;
    rst : in std_logic;
    go  : in std_logic;
    
    i_le_n : in std_logic;
    
    i_sel : out std_logic;
    x_sel : out std_logic;
    y_sel : out std_logic;
    i_ld  : out std_logic;
    x_ld  : out std_logic;
    y_ld  : out std_logic;
    n_ld  : out std_logic;
    result_ld  : out std_logic;
    
    done: out std_logic
    
    
  );
end entity fib_ctrl;

architecture FSM_RTL of fib_ctrl is
  type t_state is (init, loop_cond, loop_body, loop_done);
  signal state, next_state : t_state;
begin
  
  process(clk, rst)
  begin
    if (rst = '1') then
      state <= init;                
    elsif(rising_edge(clk)) then
      state <= next_state;
    end if;
  end process;
  
  process(state, go, i_le_n) -- @suppress "Incomplete sensitivity list. Missing signals: state"
  begin
    next_state <= state;
    done <= '0';
    n_ld <= '0';
    x_ld <= '1';
    y_ld <= '1';
    i_ld <= '1';
    result_ld <= '1';
    x_sel <= '1';
    y_sel <= '1';
    i_sel <= '1';
    
    case state is
    when init =>
      if (go = '1') then
        next_state <= loop_body;
      end if;
      n_ld <= '1';
      x_sel <= '0';
      y_sel <= '0';
      i_sel <= '0';
    
    when loop_cond =>
      if (i_le_n = '1') then
        next_state <= loop_body;
      else
        next_state <= loop_done;
      end if;
      
    when loop_body =>
      if (i_le_n = '0') then
        next_state <= loop_done;
      end if;
      n_ld <= '0';
    when loop_done =>
      if (go = '0') then
        next_state <= init;
      end if;
      result_ld <= '0';
      i_ld <= '0';
      x_ld <= '0';
      done <= '1';
    end case;
  end process;

end architecture FSM_RTL;
