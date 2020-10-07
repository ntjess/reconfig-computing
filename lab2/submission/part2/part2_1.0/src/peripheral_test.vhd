library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity peripheral_test is
    generic (width : positive);
    port (
        in0  : in  std_logic_vector(width-1 downto 0);
        in1  : in  std_logic_vector(width-1 downto 0);
        in2  : in  std_logic_vector(width-1 downto 0);
        in3  : in  std_logic_vector(width-1 downto 0);
        out0 : out std_logic_vector(width-1 downto 0);
        out1 : out std_logic_vector(width-1 downto 0);
        out2 : out std_logic_vector(width-1 downto 0);
        out3 : out std_logic_vector(width-1 downto 0));
end peripheral_test;

architecture default of peripheral_test is
begin
  process(in0, in1, in2, in3)
    variable tmp : unsigned(width*2-1 downto 0);
  begin
    tmp := unsigned(in0) * unsigned(in1);
    
    out0 <= std_logic_vector(tmp(width-1 downto 0));
    out1 <= std_logic_vector(unsigned(in0) + unsigned(in1));
    out2 <= std_logic_vector(unsigned(in2) - unsigned(in3));
    out3 <= in2 xor in3;
  end process;
  
    
end default;
