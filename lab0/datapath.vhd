library ieee;
use ieee.std_logic_1164.all;

entity datapath is
  generic (
    width     :     positive := 16);
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    en        : in  std_logic;
    valid_in  : in  std_logic;
    valid_out : out std_logic;
    in1       : in  std_logic_vector(width-1 downto 0);
    in2       : in  std_logic_vector(width-1 downto 0);
    in3       : in  std_logic_vector(width-1 downto 0);
    in4       : in  std_logic_vector(width-1 downto 0);
    output    : out std_logic_vector(width*2 downto 0));
end datapath;

-- TODO: Implement the structural description of the datapath shown in
-- datapath.pdf by instantiating your add_pipe and mult_pipe entities. You may
-- also use the provided reg entity, or you can create your own.

architecture STR of datapath is
  signal mul_left_out: std_logic_vector(width*2-1 downto 0);
  signal mul_right_out: std_logic_vector(width*2-1 downto 0);
  
  signal reg_top_out: std_logic;
begin
  mul_left: entity work.mult_pipe
    generic map(
      width => width
    )
    port map(
      clk    => clk,
      rst    => rst,
      en     => en,
      in1    => in1,
      in2    => in2,
      output => mul_left_out
    );
  
  mul_right: entity work.mult_pipe
    generic map(
      width => width
    )
    port map(
      clk    => clk,
      rst    => rst,
      en     => en,
      in1    => in3,
      in2    => in4,
      output => mul_right_out
    );
    
  adder: entity work.add_pipe
    generic map(
      width => width*2
    )
    port map(
      clk    => clk,
      rst    => rst,
      en     => en,
      in1    => mul_right_out,
      in2    => mul_left_out,
      output => output
    );
    
  reg_top: entity work.reg
    generic map(
      width => 1
    )
    port map(
      clk    => clk,
      rst    => rst,
      en     => en,
      input(0)  => valid_in,
      output(0) => reg_top_out
    );
    
  reg_bot : entity work.reg
    generic map(
      width => 1
    )
    port map(
      clk    => clk,
      rst    => rst,
      en     => en,
      input(0)  => reg_top_out,
      output(0) => valid_out
    );
  
end STR;
