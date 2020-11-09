-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;

package user_pkg is

    constant C_SRC_DEST_CLK_RATIO : integer                           := 2;
    constant C_GO_ADDR            : std_logic_vector(31 downto 0) := x"00000000";
    constant C_ITERATIONS_ADDR    : std_logic_vector(31 downto 0) := x"00000001";
    constant C_COUNT_ADDR         : std_logic_vector(31 downto 0) := x"00000002";
    constant C_DONE_ADDR          : std_logic_vector(31 downto 0) := x"00000003";

    constant C_1 : std_logic := '1';
    constant C_0 : std_logic := '0';

end user_pkg;
