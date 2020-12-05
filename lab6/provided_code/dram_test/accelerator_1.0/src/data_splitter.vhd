library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_splitter is
  generic (
    in_width : positive;
    out_width : positive
  );
  port(
    clk : in std_logic;
    rst : in std_logic;
    latch : in std_logic;
    en : in std_logic;
    
    din : in std_logic_vector(in_width-1 downto 0);
    
    dout : out std_logic_vector(out_width-1 downto 0);
    ready : out std_logic
    
  );
end entity data_splitter;

architecture RTL of data_splitter is
  constant n_iters : integer := in_width/out_width;
  
  signal valids : unsigned(n_iters downto 0);
  signal din_iter : unsigned(din'range);
begin
  
  
  process (clk, rst) is
    
  begin
    if rst = '1' then
      valids <= (others => '0');
      dout <= (others => '0');
    elsif rising_edge(clk) then
      if en = '1' then
        dout <= std_logic_vector(din_iter(out_width-1 downto 0));
        -- Ready when all the valid bits are gone
        ready <= not valids(0);
        
        -- keep maing out_width sized chunks available until '0' is shifted
        -- into the last bit of valids. At that point, all valid data has been
        -- retrieved and 'ready' will be set to '1'
        valids <= shift_right(valids, 1);
        din_iter <= shift_right(din_iter, out_width);
        
        if latch = '1' then
          valids <= (others => '1');
          din_iter <= unsigned(din);
        end if;
      end if;
    end if;
  end process ;
  

end architecture RTL;
