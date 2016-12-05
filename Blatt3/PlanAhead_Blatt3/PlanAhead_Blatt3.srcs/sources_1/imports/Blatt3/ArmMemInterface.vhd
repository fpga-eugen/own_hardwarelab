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
	port (  	RAM_CLK		:  in  std_logic;
		--	Instruction-Interface
       			IDE		:  in std_logic;
			IA		:  in std_logic_vector(31 downto 2);
			ID		: out std_logic_vector(31 downto 0);
			IABORT		: out std_logic;
		--	Data-Interface
			DDE		:  in std_logic;
			DnRW		:  in std_logic;
			DMAS		:  in std_logic_vector(1 downto 0);
			DA 		:  in std_logic_vector(31 downto 0);
			DDIN		:  in std_logic_vector(31 downto 0);
			DDOUT		: out std_logic_vector(31 downto 0);
			DABORT		: out std_logic);
end entity ArmMemInterface;

architecture behave of ArmMemInterface is

component ArmRAMB_4kx32 is
	generic(
--------------------------------------------------------------------------------
--	SELECT_LINES ist fuer das HWPR irrelevant, wird aber in einer
--	komplexeren Variante dieses Speichers zur Groessenauswahl
--	benoetigt. Im Hardwarepraktikum bitte ignorieren und nicht aendern.
--------------------------------------------------------------------------------
		SELECT_LINES : natural range 0 to 2 := 1);
    port(
		RAM_CLK	: in  std_logic;
        	ENA	: in  std_logic;
		ADDRA	: in  std_logic_vector(11 downto 0);
        	WEB	: in  std_logic_vector(3 downto 0);
        	ENB	: in  std_logic;
		ADDRB	: in  std_logic_vector(11 downto 0);
        	DIB	: in  std_logic_vector(31 downto 0);
        	DOA	: out  std_logic_vector(31 downto 0);
        	DOB	: out  std_logic_vector(31 downto 0));
end component ArmRAMB_4kx32;


-- signals
signal ram_instr_out, ram_data_in, ram_data_out, ia_sll: std_logic_vector(31 downto 0);
signal ram_web: std_logic_vector(3 downto 0);

begin
	ram: ArmRAMB_4kx32
	port map
	(
		RAM_CLK => RAM_CLK,
		ENA 	=> IDE,
		ADDRA 	=> IA(13 downto 2),
		DOA	=> ram_instr_out,
        	WEB	=> ram_web,
        	ENB	=> DDE,
		ADDRB	=> DA(13 downto 2),
        	DIB	=> DDIN, --ram_data_in,
        	DOB	=> ram_data_out
	);


	DDOUT 	<= ram_data_out when ((DDE = '1') and (DnRW = '0')) else (others => 'Z');
	ID 	<= ram_instr_out when IDE = '1' else (others => 'Z');

	ram_web <=	"0000" when DnRW = '0' else
				"1111" when DMAS = DMAS_WORD else
				"0011" when ((DMAS = DMAS_HWORD) and (DA(1 downto 0) = "00")) else
				"1100" when ((DMAS = DMAS_HWORD) and (DA(1 downto 0) = "10")) else
				"1000" when DA(1 downto 0) = "11" else
				"0100" when DA(1 downto 0) = "10" else
				"0010" when DA(1 downto 0) = "01" else
				"0001" when DA(1 downto 0) = "00" else
				"0000";

	DABORT <=	'Z' when DDE = '0' else
				'1' when DMAS = DMAS_RESERVED else
				'1' when ((DMAS = DMAS_WORD) and (to_integer(unsigned(DA(1 downto 0))) > 0)) else
				'1' when ((DMAS = DMAS_HWORD) and ((DA(1 downto 0) = "01") or (DA(1 downto 0) = "11"))) else
				'0';
	ia_sll <= IA & "00"; --shiften �ber sll geht nicht, da nur 30 bit vektor

	IABORT <=	'Z' when IDE = '0' else
				'1' when (to_integer(unsigned(ia_sll)) > to_integer(unsigned(INST_HIGH_ADDR))) else
				'1' when (to_integer(unsigned(ia_sll)) < to_integer(unsigned(INST_LOW_ADDR))) else --shift left 2 weil untersten 2 Bits fehlen
				'0';



end architecture behave;
