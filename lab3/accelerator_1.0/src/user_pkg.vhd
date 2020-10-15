-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;

package user_pkg is

    subtype addr_type is integer range 0 to 2**C_MMAP_ADDR_WIDTH-1;
    constant C_GO_ADDR     : addr_type := 0;
    constant C_N_ADDR      : addr_type := 1;
    constant C_RESULT_ADDR : addr_type := 2;
    constant C_DONE_ADDR   : addr_type := 3;

end user_pkg;
