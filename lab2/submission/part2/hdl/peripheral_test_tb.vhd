library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity peripheral_test_tb is
end entity peripheral_test_tb;

architecture UUT of peripheral_test_tb is
signal in0, in1, in2, in3, out0, out1, out2, out3 : std_logic_vector(31 downto 0);
signal tmp_xor: unsigned(31 downto 0);

signal clk : std_logic := '0';
begin
  periph : entity work.peripheral_test
      generic map(
        width => 32
      )
      port map(
        in0  => in0,
        in1  => in1,
        in2  => in2,
        in3  => in3,
        out0 => out0,
        out1 => out1,
        out2 => out2,
        out3 => out3
      );
      
clk <= not clk after 5 ns;

process
begin
  for ii in 0 to 16 loop
    for jj in 0 to 16 loop
      in0 <= std_logic_vector(to_unsigned(ii, 32));
      in1 <= std_logic_vector(to_unsigned(jj, 32));
      in2 <= std_logic_vector(to_unsigned(ii, 32));
      in3 <= std_logic_vector(to_unsigned(jj, 32));
      
      tmp_xor <= to_unsigned(ii, 32) xor to_unsigned(jj, 32);
      wait until rising_edge(clk);
      
      assert out0 = std_logic_vector(to_unsigned(ii*jj, 32)) report "out0 error wrong output" severity failure;
      assert out1 = std_logic_vector(to_unsigned(ii+jj, 32)) report "out1 error wrong output" severity failure;
      assert out2 = std_logic_vector(to_unsigned(ii, 32)- to_unsigned(jj, 32)) report "out2 error wrong output" severity failure;
      assert out3 = std_logic_vector(tmp_xor) report "out3 error wrong output" severity failure;
      
    end loop;
  end loop;
  assert false report "Simulation successfully completed!" severity failure;
end process;
      
      
end architecture UUT;
