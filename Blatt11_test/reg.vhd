library ieee;
use ieee.std_logic_1164.all ;

entity reg is
	generic (WIDTH: integer := 32);
  port( DATA: in std_logic_vector((WIDTH - 1) downto 0);
        CLOCK: in std_logic;
        RESET: in std_logic;
        OUTPUT: out std_logic_vector((WIDTH - 1) downto 0));
end entity;


architecture behave of reg is
  begin
    process(CLOCK)
      begin
        if rising_edge(CLOCK) then
            if RESET = '1' then
              OUTPUT <= (others => '0');
            else OUTPUT <= DATA;
            end if;
        end if;
    end process;
end architecture;
