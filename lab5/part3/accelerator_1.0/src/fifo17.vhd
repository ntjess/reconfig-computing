library ieee;
use ieee.std_logic_1164.all;

entity fifo17 is
    port (
        clk_src  : in  std_logic;
        clk_dest : in  std_logic;
        rst      : in  std_logic;
        empty    : out std_logic;
        full     : out std_logic;
        rd       : in  std_logic;
        wr       : in  std_logic;
        data_in  : in  std_logic_vector(16 downto 0);
        data_out : out std_logic_vector(16 downto 0));
end fifo17;

architecture STR of fifo17 is

  

begin  -- STR

    

end STR;
