library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fib_datapath is
  port(
    clk   : in std_logic;
    
    n     : in std_logic_vector(7 downto 0);
    i_sel : in std_logic;
    x_sel : in std_logic;
    y_sel : in std_logic;
    i_ld  : in std_logic;
    x_ld  : in std_logic;
    y_ld  : in std_logic;
    n_ld  : in std_logic;
    result_ld  : in std_logic;
    
    i_le_n: out std_logic;
    result: out std_logic_vector(7 downto 0)
  );
end entity fib_datapath;

architecture RTL of fib_datapath is
  signal i_in : std_logic_vector(7 downto 0);
  signal x_in : std_logic_vector(7 downto 0);
  signal y_in : std_logic_vector(7 downto 0);
  signal i_out : std_logic_vector(7 downto 0);
  signal x_out : std_logic_vector(7 downto 0);
  signal y_out : std_logic_vector(7 downto 0);
  signal n_out : std_logic_vector(7 downto 0);
  
  signal xy_add_out : std_logic_vector(7 downto 0);
  signal i_accum_out : std_logic_vector(7 downto 0);
  
  -- Just to silence vivado warnings
  signal unused_add_1 : std_logic; -- @suppress "signal unused_add_1 is never read"
  signal unused_add_2 : std_logic; -- @suppress "signal unused_add_2 is never read"
  
begin
  
  imux : entity work.mux_2x1
    generic map(
      width => 8
    )
    port map(
      in1    => std_logic_vector(to_unsigned(2, i_out'length)),
      in2    => i_accum_out,
      sel    => i_sel,
      result => i_in
    );
    
  xmux : entity work.mux_2x1
    generic map(
      width => 8
    )
    port map(
      in1    => std_logic_vector(to_unsigned(0, x_out'length)),
      in2    => y_out,
      sel    => x_sel,
      result => x_in
    );
    
  ymux : entity work.mux_2x1
    generic map(
      width => 8
    )
    port map(
      in1    => std_logic_vector(to_unsigned(1, y_out'length)),
      in2    => xy_add_out,
      sel    => y_sel,
      result => y_in
    );
    
  ireg : entity work.reg
    generic map(
      width => 8
    )
    port map(
      clk    => clk,
      rst    => '0',
      en     => i_ld,
      input  => i_in,
      output => i_out
    );
    
  xreg : entity work.reg
  generic map(
    width => 8
  )
  port map(
    clk    => clk,
    rst    => '0',
    en     => x_ld,
    input  => x_in,
    output => x_out
  );
  
  yreg : entity work.reg
  generic map(
    width => 8
  )
  port map(
    clk    => clk,
    rst    => '0',
    en     => y_ld,
    input  => y_in,
    output => y_out
  );
  
  nreg : entity work.reg
  generic map(
    width => 8
  )
  port map(
    clk    => clk,
    rst    => '0',
    en     => n_ld,
    input  => n,
    output => n_out
  );
  
  
  resultreg : entity work.reg
    generic map(
      width => 8
    )
    port map(
      clk    => clk,
      rst    => '0',
      en     => result_ld,
      input  => y_out,
      output => result
    );
  
  le_cmp : entity work.unsigned_le
    generic map(
      width => 8
    )
    port map(
      in1         => i_out,
      in2         => n_out,
      in1_le_in2  => i_le_n
    );
    
  i_accum : entity work.add_pipe
    generic map(
      width => 8
    )
    port map(
      in1    => i_out,
      in2    => std_logic_vector(to_unsigned(1, i_out'length)),
      output(7 downto 0) => i_accum_out,
      output(8) => unused_add_2
    );
    
  xy_add : entity work.add_pipe
    generic map(
      width => 8
    )
    port map(
      in1    => x_out,
      in2    => y_out,
      output(7 downto 0) => xy_add_out,
      output(8) => unused_add_1
    );

end architecture RTL;
