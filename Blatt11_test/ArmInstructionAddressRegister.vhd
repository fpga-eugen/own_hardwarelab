--------------------------------------------------------------------------------
--	Instruktionsadressregister-Modul fuer den HWPR-Prozessor
--------------------------------------------------------------------------------
--	Datum:		29.10.2013
--	Version:	0.1
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.armtypes.all;
use work.ArmTypes.INSTRUCTION_ID_WIDTH;
use work.ArmTypes.VCR_RESET;

entity ArmInstructionAddressRegister is
	port(
		IAR_CLK 	: in std_logic;
		IAR_RST 	: in std_logic;
		IAR_INC		: in std_logic;
		IAR_LOAD 	: in std_logic;
		IAR_REVOKE	: in std_logic;
		IAR_UPDATE_HB	: in std_logic;
--------------------------------------------------------------------------------
--	INSTRUCTION_ID_WIDTH  ist ein globaler Konfigurationsparameter
--	zur Einstellung der Breite der Instruktions-IDs und damit der Tiefe
--	der verteilten Puffer. Eine Breite von 3 Bit genuegt fuer die
--	fuenfstufige Pipeline definitiv.
--------------------------------------------------------------------------------
		IAR_HISTORY_ID	: in std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
		IAR_ADDR_IN 	: in std_logic_vector(31 downto 2);
		IAR_ADDR_OUT 	: out std_logic_vector(31 downto 2);
		IAR_NEXT_ADDR_OUT : out std_logic_vector(31 downto 2)
	    );

end entity ArmInstructionAddressRegister;

architecture behave of ArmInstructionAddressRegister is

	component ArmRamBuffer
	generic(
		ARB_ADDR_WIDTH : natural range 1 to 4 := 3;
		ARB_DATA_WIDTH : natural range 1 to 64 := 32
	       );
	port(
		ARB_CLK 	: in std_logic;
		ARB_WRITE_EN	: in std_logic;
		ARB_ADDR	: in std_logic_vector(ARB_ADDR_WIDTH-1 downto 0);
		ARB_DATA_IN	: in std_logic_vector(ARB_DATA_WIDTH-1 downto 0);
		ARB_DATA_OUT	: out std_logic_vector(ARB_DATA_WIDTH-1 downto 0)
		);
	end component ArmRamBuffer;

	component mux2_32_bit
	port(s : in std_logic;
	     a,b : in std_logic_vector (31 downto 2);
	     y   : out std_logic_vector (31 downto 2)
	);
end component mux2_32_bit;

signal Instruktionsadresse : std_logic_vector (31 downto 2);
signal Instruktionsadresse_plus_one : std_logic_vector (31 downto 2);
signal ARB_DATA_OUT_BUFFER : std_logic_vector (31 downto 2);
signal IAR_LOAD_OUT : std_logic_vector (31 downto 2);
signal IAR_INC_OUT : std_logic_vector (31 downto 2);


begin

IAR_LOAD_MUX : mux2_32_bit
port map(
	s => IAR_LOAD,
	a => IAR_INC_OUT,
	b => IAR_ADDR_IN,
	y => IAR_LOAD_OUT
);

IAR_INC_MUX : mux2_32_bit
port map
(

	s => IAR_INC,
	a => Instruktionsadresse,
	b => Instruktionsadresse_plus_one,
	y => IAR_INC_OUT

);

IAR_REVOKE_MUX : mux2_32_bit
port map
(

	s => IAR_REVOKE,
	a => Instruktionsadresse_plus_one,
	b => ARB_DATA_OUT_BUFFER,
	y => IAR_NEXT_ADDR_OUT

);

	IAR_HISTORY_BUFFER: ArmRamBuffer
	generic map
	(
			ARB_ADDR_WIDTH => INSTRUCTION_ID_WIDTH,
			ARB_DATA_WIDTH => 30
		)
	port map
	(
		ARB_CLK		=> IAR_CLK,
		ARB_WRITE_EN	=> IAR_UPDATE_HB,
		ARB_ADDR	=> IAR_HISTORY_ID,
		ARB_DATA_IN	=> Instruktionsadresse,
		ARB_DATA_OUT	=> ARB_DATA_OUT_BUFFER
	);

	Instruktionsadresse_plus_one <= std_logic_vector(unsigned(Instruktionsadresse) + 1);
	IAR_ADDR_OUT <= Instruktionsadresse;

process(IAR_CLK)
begin

	if ( rising_edge(IAR_CLK)) then
		if IAR_RST = '1' then
			Instruktionsadresse <= (others => '0');
	else
			Instruktionsadresse <= IAR_LOAD_OUT;
		end if;
	end if;

end process;

end architecture behave;
