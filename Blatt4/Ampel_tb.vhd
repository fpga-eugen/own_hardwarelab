library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity Ampel_tb is
end Ampel_tb;

architecture behave of Ampel_tb is

  component Ampel
  port(
      CLK 	: in std_logic;
      RST 	: in std_logic;
      E_AKTIV : in std_logic;
      A_ROT 	: out std_logic;
      A_GELB 	: out std_logic;
      A_GRUEN : out std_logic
    );
  end component Ampel;

  signal CLK : std_logic := '0';
	signal RST : std_logic := '0';
  signal E_AKTIV : std_logic := '0';
  signal A_ROT : std_logic := '0';
  signal A_GELB : std_logic := '0';
  signal A_GRUEN : std_logic := '0';

  type AMPEL_STATE_TYPE is (S_ROT,S_GELB,S_GRUEN,S_GELBROT,S_AUS);
  signal AMPEL_STATE 	: AMPEL_STATE_TYPE := S_ROT;
  signal AMPEL_NEXT_STATE : AMPEL_STATE_TYPE := S_ROT;

  constant clk_period : time := 1 ns;

begin

  CLK <= not CLK after clk_period;
  RST <= '1', '0' after 10 ns;

  uut : Ampel
  port map(
    CLK => CLK,
    RST => RST,
    E_AKTIV => E_AKTIV,
    A_ROT => A_ROT,
    A_GELB => A_GELB,
    A_GRUEN => A_GRUEN
  );

  stimulus_process : process
  begin

    wait for 10 ns;
    E_AKTIV <= '1';

    wait for 20 ns;
    E_AKTIV <= '0';

    wait for 30 ns;
    E_AKTIV <= '-';

    wait for 40 ns;
    E_AKTIV <= '1';

    wait for 50 ns;
    E_AKTIV <= '-';

    wait for 60 ns;
    E_AKTIV <= '1';

    wait for 70 ns;
    E_AKTIV <= '0';

    report "end of test" severity failure;
  end process;


end architecture behave;
