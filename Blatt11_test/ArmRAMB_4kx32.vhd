--------------------------------------------------------------------------------
--	Wrapper um Spartan3E-Blockram fuer den RAM des HWPR-Prozessors.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_std.all;

entity ArmRAMB_4kx32 is
	generic(
--------------------------------------------------------------------------------
--	SELECT_LINES ist fuer das HWPR irrelevant, wird aber in einer
--	komplexeren Variante dieses Speichers zur Groessenauswahl
--	benoetigt. Im Hardwarepraktikum bitte ignorieren und nicht aendern.
--------------------------------------------------------------------------------
		SELECT_LINES : natural range 0 to 2 := 1);
    port(
		RAM_CLK	: in  std_logic;
        ENA		: in  std_logic;
		ADDRA	: in  std_logic_vector(11 downto 0);
        WEB		: in  std_logic_vector(3 downto 0);
        ENB		: in  std_logic;
		ADDRB	: in  std_logic_vector(11 downto 0);
        DIB		: in  std_logic_vector(31 downto 0);
        DOA		: out  std_logic_vector(31 downto 0);
        DOB		: out  std_logic_vector(31 downto 0));
end entity ArmRAMB_4kx32;

architecture behavioral of ArmRAMB_4kx32 is

		component ArmRAMB_4kx8
		generic (WIDTH : positive := 8;
				 SIZE  : positive := 4096);
		port (RAM_CLK : in std_logic;
			ADDRA : in  std_logic_vector(integer(ceil(log2(real(SIZE))))-1 downto 0);
			DOA   : out std_logic_vector(WIDTH-1 downto 0);
			ENA	  : in  std_logic;
			ADDRB : in  std_logic_vector(integer(ceil(log2(real(SIZE))))-1 downto 0);
			DIB   : in  std_logic_vector(WIDTH-1 downto 0);
			DOB   : out std_logic_vector(WIDTH-1 downto 0);
			ENB	  : in  std_logic;
			WEB   : in  std_logic);
		end component;

begin

byte_0 : ArmRAMB_4kx8
	port map(
		RAM_CLK => RAM_CLK,
		ADDRA => ADDRA,
		DOA => DOA(7 downto 0),
		ENA => ENA,
		ADDRB => ADDRB,
		DIB => DIB(7 downto 0),
		DOB => DOB(7 downto 0),
		ENB => ENB,
		WEB => WEB(0)
	);

	byte_1 : ArmRAMB_4kx8
		port map(
		RAM_CLK => RAM_CLK,
		ADDRA => ADDRA,
		DOA => DOA(15 downto 8),
		ENA => ENA,
		ADDRB => ADDRB,
		DIB => DIB(15 downto 8),
		DOB => DOB(15 downto 8),
		ENB => ENB,
		WEB => WEB(1)
		);

	byte_2 : ArmRAMB_4kx8
		port map(
		RAM_CLK => RAM_CLK,
		ADDRA => ADDRA,
		DOA => DOA(23 downto 16),
		ENA => ENA,
		ADDRB => ADDRB,
		DIB => DIB(23 downto 16),
		DOB => DOB(23 downto 16),
		ENB => ENB,
		WEB => WEB(2)
		);

		byte_3 : ArmRAMB_4kx8
			port map(
			RAM_CLK => RAM_CLK,
			ADDRA => ADDRA,
			DOA => DOA(31 downto 24),
			ENA => ENA,
			ADDRB => ADDRB,
			DIB => DIB(31 downto 24),
			DOB => DOB(31 downto 24),
			ENB => ENB,
			WEB => WEB(3)
			);

end architecture behavioral;
