------------------------------------------------------------------------------
--	Registerspeichers des ARM-SoC
------------------------------------------------------------------------------
--	Datum:		05.11.2013
--	Version:	0.1
------------------------------------------------------------------------------

library work;
use work.ArmTypes.all;
use work.ArmRegAddressTranslation.all;
use work.ArmGlobalProbes.all;
use work.ArmConfiguration.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ArmRegfile is
	Port ( REF_CLK 		: in std_logic;
	       REF_RST 		: in  std_logic;

	       REF_W_PORT_A_ENABLE	: in std_logic;
	       REF_W_PORT_B_ENABLE	: in std_logic;
	       REF_W_PORT_PC_ENABLE	: in std_logic;

	       REF_W_PORT_A_ADDR 	: in std_logic_vector(4 downto 0);
	       REF_W_PORT_B_ADDR 	: in std_logic_vector(4 downto 0);

	       REF_R_PORT_A_ADDR 	: in std_logic_vector(4 downto 0);
	       REF_R_PORT_B_ADDR 	: in std_logic_vector(4 downto 0);
	       REF_R_PORT_C_ADDR 	: in std_logic_vector(4 downto 0);

	       REF_W_PORT_A_DATA 	: in std_logic_vector(31 downto 0);
	       REF_W_PORT_B_DATA 	: in std_logic_vector(31 downto 0);
	       REF_W_PORT_PC_DATA 	: in std_logic_vector(31 downto 0);

	       REF_R_PORT_A_DATA 	: out std_logic_vector(31 downto 0);
	       REF_R_PORT_B_DATA 	: out std_logic_vector(31 downto 0);
	       REF_R_PORT_C_DATA 	: out std_logic_vector(31 downto 0)
       );
end entity ArmRegfile;


architecture behave of ArmRegfile is

	type speicher is array (0 to 30) of std_logic_vector(31 downto 0);

	signal ram : speicher;

begin

	REF_R_PORT_C_DATA <= ram(to_integer(unsigned(REF_R_PORT_C_ADDR)));
	REF_R_PORT_B_DATA <= ram(to_integer(unsigned(REF_R_PORT_B_ADDR)));
	REF_R_PORT_A_DATA <= ram(to_integer(unsigned(REF_R_PORT_A_ADDR)));

	process(REF_CLK)
		begin

			if (rising_edge(REF_CLK)) then

				if (REF_RST = '1') then
						for i in 0 to 30 loop
							ram(i) <= (others => '0');
						end loop;

			  else
				if (REF_W_PORT_PC_ENABLE = '1') then
					ram(15) <= REF_W_PORT_PC_DATA;
				end if;

				if (REF_W_PORT_B_ENABLE = '1') then
					ram(to_integer(unsigned(REF_W_PORT_B_ADDR))) <= REF_W_PORT_B_DATA;
				end if;

				if (REF_W_PORT_A_ENABLE = '1') then
					ram(to_integer(unsigned(REF_W_PORT_A_ADDR))) <= REF_W_PORT_A_DATA;
				end if;
			end if;
		end if;

	end process;


--------------------------------------------------------------------------------
--	Zuweisungen interner Signale an globale Signale zu Testzwecken
--	Weisen Sie dem Testsignal jeweils den Registerinhalt des Registers
--	mit der passenden physischen Adresse zu, also z.B.
--	AGP_PHY_R0 	<= Registerspeicher an Adresse/Index "00000"/0
--------------------------------------------------------------------------------

-- synthesis translate_off
	AGP_PHY_R0	<= ram(0);
	AGP_PHY_R1	<= ram(1);
	AGP_PHY_R2	<= ram(2);
	AGP_PHY_R3	<= ram(3);
	AGP_PHY_R4	<= ram(4);
	AGP_PHY_R5	<= ram(5);
	AGP_PHY_R6	<= ram(6);
	AGP_PHY_R7	<= ram(7);
	AGP_PHY_R8	<= ram(8);
	AGP_PHY_R9	<= ram(9);
	AGP_PHY_R10	<= ram(10);
	AGP_PHY_R11	<= ram(11);
	AGP_PHY_R12	<= ram(12);
	AGP_PHY_R13	<= ram(13);
	AGP_PHY_R14	<= ram(14);
	AGP_PHY_R15	<= ram(15);
	AGP_PHY_R16	<= ram(16);
	AGP_PHY_R17	<= ram(17);
	AGP_PHY_R18	<= ram(18);
	AGP_PHY_R19	<= ram(19);
	AGP_PHY_R20	<= ram(20);
	AGP_PHY_R21	<= ram(21);
	AGP_PHY_R22	<= ram(22);
	AGP_PHY_R23	<= ram(23);
	AGP_PHY_R24	<= ram(24);
	AGP_PHY_R25	<= ram(25);
	AGP_PHY_R26	<= ram(26);
	AGP_PHY_R27	<= ram(27);
	AGP_PHY_R28	<= ram(28);
	AGP_PHY_R29	<= ram(29);
	AGP_PHY_R30	<= ram(30);
-- synthesis translate_on

end architecture behave;
