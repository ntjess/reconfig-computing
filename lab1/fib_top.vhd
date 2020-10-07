library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fib_top is
  port(
    clk : in std_logic;
    rst : in std_logic;
    
    go: in std_logic;
    n : in std_logic_vector(7 downto 0);
    
    done : out std_logic;
    result: out std_logic_vector(7 downto 0)
  );
end entity fib_top;

architecture RTL of fib_top is
  signal i_le_n : std_logic;
  signal i_sel : std_logic;
  signal x_sel : std_logic;
  signal y_sel : std_logic;
  signal i_ld : std_logic;
  signal x_ld : std_logic;
  signal y_ld : std_logic;
  signal n_ld : std_logic;
  signal result_ld : std_logic;
begin

  controller : entity work.fib_ctrl
    port map(
      clk       => clk,
      rst       => rst,
      go        => go,
      i_le_n    => i_le_n,
      i_sel     => i_sel,
      x_sel     => x_sel,
      y_sel     => y_sel,
      i_ld      => i_ld,
      x_ld      => x_ld,
      y_ld      => y_ld,
      n_ld      => n_ld,
      result_ld => result_ld,
      done      => done
    );
    
    datapath : entity work.fib_datapath
      port map(
        clk       => clk,
        n         => n,
        i_sel     => i_sel,
        x_sel     => x_sel,
        y_sel     => y_sel,
        i_ld      => i_ld,
        x_ld      => x_ld,
        y_ld      => y_ld,
        n_ld      => n_ld,
        result_ld => result_ld,
        i_le_n    => i_le_n,
        result    => result
      );

end architecture RTL;
