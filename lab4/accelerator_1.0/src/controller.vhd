library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
  port(
    clk : in std_logic;
    rst : in std_logic;
    
    go : in std_logic;
    done : in std_logic;
    
    go_buffer : out std_logic;
    done_buffer : out std_logic;
    flush_pipeline_valid : out std_logic;
    in_addr_en : out std_logic
  );
end entity controller;

architecture RTL of controller is
  type t_state is (s_init, s_wait_go_1, s_exec, s_done);
  signal state, next_state : t_state;
begin

  process(clk, rst) is
  begin
    if rst = '1' then
      state <= s_init;
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process;
  
  process (state, go, done)
  begin
    in_addr_en <= '0';
    go_buffer <= '0';
    flush_pipeline_valid <= '0';
    
    case state is
      when s_init =>
        next_state <=  s_wait_go_1;
        done_buffer <= '0';
        if go = '1' then
          next_state <= s_exec;
        end if;
      when s_wait_go_1 =>
        go_buffer <= go;
        if go = '1' then
          in_addr_en <= '1';
          next_state <= s_exec;
        end if;
      when s_exec =>
        in_addr_en <= '1';
        done_buffer <= '0';
        if done = '1' then
          next_state <= s_done;
          done_buffer <= '1';
        end if;
      when s_done =>
        flush_pipeline_valid <= '1';
        if go = '0' then
          next_state <= s_wait_go_1;
        end if;
    end case;
  end process;
  

end architecture RTL;
