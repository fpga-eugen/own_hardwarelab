--------------------------------------------------------------------------------
--	Schnittstelle zur Anbindung des RAM an die Busse des HWPR-Prozessors
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmConfiguration.all;
use work.ArmTypes.all;

entity ArmMemInterface is
	generic(
--------------------------------------------------------------------------------
--	Beide Generics sind fuer das HWPR nicht relevant und koennen von
--	Ihnen ignoriert werden.
--------------------------------------------------------------------------------
		SELECT_LINES				: natural range 0 to 2 := 1;
		EXTERNAL_ADDRESS_DECODING_INSTRUCTION : boolean := false);
	port (  RAM_CLK	:  in  std_logic;
		--	Instruction-Interface
       		IDE		:  in std_logic;
			IA		:  in std_logic_vector(31 downto 2);
			ID		: out std_logic_vector(31 downto 0);
			IABORT	: out std_logic;
		--	Data-Interface
			DDE		:  in std_logic;
			DnRW	:  in std_logic;
			DMAS	:  in std_logic_vector(1 downto 0);
			DA 		:  in std_logic_vector(31 downto 0);
			DDIN	:  in std_logic_vector(31 downto 0);
			DDOUT	: out std_logic_vector(31 downto 0);
			DABORT	: out std_logic);
end entity ArmMemInterface;

architecture behave of ArmMemInterface is

	component ArmRAMB_4kx32
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
		end component;


signal WEB_buffer : std_logic_vector(3 downto 0);
signal DDOUT_buffer : std_logic_vector(31 downto 0);
signal ID_buffer : std_logic_vector(31 downto 0);
signal ssl : std_logic_vector(31 downto 0);

begin

	ram : ArmRAMB_4kx32
	port map(
	RAM_CLK	=> RAM_CLK,
			ENA	=> IDE,
	ADDRA	=> IA(13 downto 2),
			WEB	=> WEB_buffer,
			ENB	=> DDE,
	ADDRB	=> DA(13 downto 2),
			DIB	=> DDIN,
			DOA	=> ID_buffer,
			DOB	=> DDOUT_buffer
	);

  DDOUT <= DDOUT_buffer when ((DDE = '1') and (DnRW = '0')) else (others => 'Z');
	ID <= ID_buffer when (IDE = '1') else (others => 'Z');

	WEB_buffer <= "0000" when DnRW = '0' else
					 "1111" when DMAS = DMAS_WORD else
					 "0011" when DMAS = DMAS_HWORD and (DA(1 downto 0) = "00") else
					 "1100" when DMAS = DMAS_HWORD and (DA(1 downto 0) = "10") else
					 "0001" when DMAS = DMAS_BYTE and (DA(1 downto 0) = "00") else
					 "0010" when DMAS = DMAS_BYTE and (DA(1 downto 0) = "01") else
					 "0100" when DMAS = DMAS_BYTE and (DA(1 downto 0) = "10")	else
					 "1000" when DMAS = DMAS_BYTE and (DA(1 downto 0) = "11")	else "0000";



	IABORT <= 'Z' when IDE = '0' else
		   '1' when  (unsigned(IA) > unsigned(INST_HIGH_ADDR(31 downto 2))) and (IDE = '1') else
		   '0';

	DABORT <= '1' when DMAS = DMAS_RESERVED else
				'1' when DMAS = DMAS_WORD and (DA(1 downto 0) > "00") else
				'1' when DMAS = DMAS_HWORD and ((DA(1 downto 0) = "01") or (DA(1 downto 0) = "11")) else
				'Z' when DDE = '0' else
				'0';

end architecture behave;
