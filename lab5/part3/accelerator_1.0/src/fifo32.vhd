library ieee;
use ieee.std_logic_1164.all;

entity fifo32 is
    port (
        clk_src     : in  std_logic;
        clk_dest    : in  std_logic;
        rst         : in  std_logic; 
        empty       : out std_logic;
        full        : out std_logic;
        almost_full : out std_logic;
        rd          : in  std_logic;
        wr          : in  std_logic;
        data_in     : in  std_logic_vector(31 downto 0);
        data_out    : out std_logic_vector(31 downto 0));
end fifo32;

architecture STR of fifo32 is
 

begin  -- STR

    
end STR;
