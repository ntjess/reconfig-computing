library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
  port(
    clk : in std_logic;
    en : in std_logic;
    rst : in std_logic;
    
    in1: in std_logic_vector(7 downto 0);
    in2: in std_logic_vector(7 downto 0);
    in3: in std_logic_vector(7 downto 0);
    in4: in std_logic_vector(7 downto 0);
    
    output: out std_logic_vector(16 downto 0);
    out_valid : out std_logic
  );
end entity datapath;

architecture RTL of datapath is
  signal mul1in : std_logic_vector(15 downto 0);
  signal mul2in : std_logic_vector(15 downto 0);
  signal addin  : std_logic_vector(16 downto 0);
  
  signal mul1out : std_logic_vector(15 downto 0);
  signal mul2out : std_logic_vector(15 downto 0);
  
  signal reg1out : std_logic_vector(7 downto 0);
  signal reg2out : std_logic_vector(7 downto 0);
  signal reg3out : std_logic_vector(7 downto 0);
  signal reg4out : std_logic_vector(7 downto 0);
  
  signal pipeline_valid : std_logic_vector(2 downto 0);
  
begin

  reg1 : entity work.reg
    generic map(
      width => 8
    )
    port map(
      clk => clk,
      rst => rst,
      en => en,
      input => in1,
      output => reg1out
    );
  
  reg2 : entity work.reg
    generic map(
      width => 8
    )
    port map(
      clk => clk,
      rst => rst,
      en => en,
      input => in2,
      output => reg2out
    );
    
  reg3 : entity work.reg
    generic map(
      width => 8
    )
    port map(
      clk => clk,
      rst => rst,
      en => en,
      input => in3,
      output => reg3out
    );
    
  reg4 : entity work.reg
    generic map(
      width => 8
    )
    port map(
      clk => clk,
      rst => rst,
      en => en,
      input => in4,
      output => reg4out
    );
    
  mul1in <= std_logic_vector(unsigned(reg1out) * unsigned(reg2out));
  mul2in <= std_logic_vector(unsigned(reg3out) * unsigned(reg4out));
    
  mul1 : entity work.reg
    generic map(
      width => 16
    )
    port map(
      clk => clk,
      rst => rst,
      en => en,
      input => mul1in,
      output => mul1out
    );
    
  mul2 : entity work.reg
    generic map(
      width => 16
    )
    port map(
      clk => clk,
      rst => rst,
      en => en,
      input => mul2in,
      output => mul2out
    );
  
  addin <= std_logic_vector(resize(unsigned(mul1out), 17) + resize(unsigned(mul2out), 17));
  
  add : entity work.reg
    generic map(
      width => 17
    )
    port map(
      clk => clk,
      rst => rst,
      en => en,
      input => addin,
      output => output
    );
    
    -- Pipeline valid bit
    u_valid_regs : for ii in 0 to 1 generate
      u_reg : entity work.reg
        generic map(
          width => 1
        )
        port map(
          clk       => clk,
          rst       => rst,
          en        => en,
          input(0)  => pipeline_valid(ii),
          output(0) => pipeline_valid(ii+1)
        );
    end generate;

end architecture RTL;
