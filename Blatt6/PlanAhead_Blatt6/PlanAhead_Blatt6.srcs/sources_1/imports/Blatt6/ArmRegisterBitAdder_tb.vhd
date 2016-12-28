--------------------------------------------------------------------------------
--	Testbench-Vorlage des HWPR-Bitaddierers.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
--	In TB_TOOLS kann, wenn gewuenscht die Funktion SLV_TO_STRING() zur
--	Ermittlung der Stringrepraesentation eines std_logic_vektor verwendet
--	werden und SEPARATOR_LINE fuer eine horizontale Trennlinie in Ausgaben.
--------------------------------------------------------------------------------
library work;
use work.TB_TOOLS.all;

entity ArmRegisterBitAdder_TB is
end ArmRegisterBitAdder_TB;

architecture testbench of ArmRegisterBitAdder_tb is

	component ArmRegisterBitAdder
	port(
		RBA_REGLIST	: in std_logic_vector(15 downto 0);
		RBA_NR_OF_REGS	: out std_logic_vector(4 downto 0)
		);
	end component ArmRegisterBitAdder;

type test_array is array (natural range <>) of std_logic_vector(15 downto 0);
signal stimuli : test_array (0 to 15);

signal REGLIST : std_logic_vector(15 downto 0);
signal NR_OF_REGS : std_logic_vector(4 downto 0);

begin
--	Unit Under Test
	UUT: ArmRegisterBitAdder port map(
		RBA_REGLIST	=> REGLIST,
		RBA_NR_OF_REGS	=> NR_OF_REGS
	);

stimuli(0) <= "0000000000000010";
stimuli(1) <= "0000000000000001";
stimuli(2) <= "0000000000000010";
stimuli(3) <= "0000000000010000";
stimuli(4) <= "1110111011100111";
stimuli(5) <= "0100100100100100";
stimuli(6) <= "0000001110000000";
stimuli(7) <= "1000000000000000";
stimuli(8) <= "0000000011000000";
stimuli(9) <= "0001100000000000";
stimuli(10) <= "1100001000011111";
stimuli(11) <= "1011111010110110";
stimuli(12) <= "0101010101010101";
stimuli(13) <= "0000001111110000";
stimuli(14) <= "0000000000001111";
stimuli(15) <= "1111111111111111";


--	Testprozess
	tb : process is
		variable test_success : boolean := true;
		variable ones_counter : integer := 0;
	begin
--		...

		wait for 10 ns;
		REGLIST <= "0000000000000000";
		wait for 100 ns;

			test_loop : for i in 0 to 15 loop
				ones_counter := 0;
				REGLIST <= stimuli(i);
				wait for 14 ns;

						counter_loop : for j in 0 to 15 loop
							if stimuli(i)(j) = '1' then
								ones_counter := ones_counter + 1;
							end if;
						end loop;

					if (ones_counter /= to_integer(unsigned(NR_OF_REGS))) then
						test_success := false;
						report "fail, not expected ones" & slv_to_string(stimuli(i));
					end if;

				wait for 10 ns;

					if (not(NR_OF_REGS'stable(10ns))) then
						test_success := false;
						report "fail, wasnt stable";
					end if;
			end loop;

			if (test_success = true) then
				report "test was successfull";
			else
				report "test failed";
			end if;


		report SEPARATOR_LINE;
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure;
--	Unbegrenztes Anhalten des Testbench Prozess
		wait;
	end process tb;
end architecture testbench;
