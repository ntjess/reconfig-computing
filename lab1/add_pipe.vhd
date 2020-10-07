library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_pipe is
  generic (
    width  :     positive := 16);
  port (
    in1    : in  std_logic_vector(width-1 downto 0);
    in2    : in  std_logic_vector(width-1 downto 0);
    output : out std_logic_vector(width downto 0));
end add_pipe;

-- TODO: Implement a behavioral description of a pipelined adder (i.e., an
-- adder with a register on the output). The output should be one bit larger
-- than the input, and should use the "width" generic as opposed to being
-- hardcoded to a specific value.

architecture BHV of add_pipe is
begin
process(in1, in2)
  variable tmp_add : std_logic_vector(width downto 0);
  
begin
    tmp_add :=  std_logic_vector(resize(unsigned(in1), width+1) + resize(unsigned(in2), width+1));
    output <= tmp_add;
    
end process;


end BHV;

