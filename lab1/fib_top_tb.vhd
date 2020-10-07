-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fib_top_tb is
end fib_top_tb;

architecture TB of fib_top_tb is
  type t_memory is array(255 downto 0) of natural;
  
  function init_mem return t_memory is
    variable mem: t_memory;
  begin
    mem(2 downto 0) := (1,1,2);
    for i in 3 to mem'length-1 loop
      mem(i) := 300;
    end loop;
    return mem;
  end init_mem;
  
  function fib_func(n: natural) return natural is
    variable mem : t_memory := init_mem;
  begin
    if (mem(n) = 300) then -- uninitialized
      mem(n) := fib_func(n-2) + fib_func(n-1);
    end if;
    return mem(n);
  end fib_func;

  signal clk, rst : std_logic := '0';
  signal go, done : std_logic;
  signal n, result : std_logic_vector(7 downto 0);
  signal true_fib : natural;
  
  signal done_fsmd : std_logic;
  signal result_fsmd: std_logic_vector(7 downto 0);

begin

  U_FIB_TOP : entity work.fib_top(RTL)
    port map(
      clk    => clk,
      rst    => rst,
      go     => go,
      n      => n,
      done   => done,
      result => result
    );
    
  U_FIB_FSMD : entity work.fib_fsmd(RTL)
    port map(
      clk    => clk,
      rst    => rst,
      go     => go,
      n      => n,
      done   => done_fsmd,
      result => result_fsmd
    );

  clk <= not clk after 5 ns;
  
  process(n)
  begin
    true_fib <= fib_func(to_integer(unsigned(n)));
  end process;

  process
    variable fib_val : std_logic_vector(7 downto 0);
  begin

    rst <= '1';
    for i in 0 to 10 loop
      wait until rising_edge(clk);
      n <= std_logic_vector(to_unsigned(i, n'length));
      go <= '1';
    end loop;  -- i
    
    n <= std_logic_vector(to_unsigned(1, n'length));
    go <= '0';
    wait until rising_edge(clk);
    rst <= '0';

    for i in 1 to 256 loop
      wait until rising_edge(clk);
      n <= std_logic_vector(to_unsigned(i, n'length));
      go <= '1';
      wait until done = '1';
      fib_val := std_logic_vector(to_unsigned(fib_func(i), n'length));
      assert result = fib_val report "Wrong fib result" severity failure;
      assert result_fsmd = fib_val report "Wrong fib result" severity failure;
      
      wait until rising_edge(clk);
      go <= '0';
      
    end loop;  -- j
    
  end process;
end;
