--------------------------------------------------------------------------------
--	16-Bit-Register zur Steuerung der Auswahl des naechsten Registers
--	bei der Ausfuehrung von STM/LDM-Instruktionen. Das Register wird
--	mit der Bitmaske der Instruktion geladen. Ein Prioritaetsencoder
--	(Modul ArmPriorityVectorFilter) bestimmt das Bit mit der hochsten
--	Prioritaet. Zu diesem Bit wird eine 4-Bit-Registeradresse erzeugt und
--	das Bit im Register geloescht. Bis zum Laden eines neuen Datums wird
--	mit jedem Takt ein Bit geloescht bis das Register leer ist.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ArmLdmStmNextAddress is
	port(
		SYS_RST			: in std_logic;
		SYS_CLK			: in std_logic;
		LNA_LOAD_REGLIST 	: in std_logic;
		LNA_HOLD_VALUE 		: in std_logic;
		LNA_REGLIST 		: in std_logic_vector(15 downto 0);
		LNA_ADDRESS 		: out std_logic_vector(3 downto 0);
		LNA_CURRENT_REGLIST_REG : out std_logic_vector(15 downto 0)
	    );
end entity ArmLdmStmNextAddress;

architecture behave of ArmLdmStmNextAddress is

	component ArmPriorityVectorFilter
		port(
			PVF_VECTOR_UNFILTERED	: in std_logic_vector(15 downto 0);
			PVF_VECTOR_FILTERED	: out std_logic_vector(15 downto 0)
		);
	end component ArmPriorityVectorFilter;

signal intern_register : std_logic_vector(15 downto 0); --:= "0000000000000000";
signal intern_register_buffer : std_logic_vector(15 downto 0);-- := "0000000000000000";
signal filter_input : std_logic_vector(15 downto 0);--  := "0000000000000000";
signal filter_output : std_logic_vector(15 downto 0);-- := "0000000000000000";
signal needed_output : std_logic_vector(15 downto 0);-- := "0000000000000000";

begin
	CURRENT_REGLIST_FILTER : ArmPriorityVectorFilter
		port map(
			PVF_VECTOR_UNFILTERED	=> filter_input,
			PVF_VECTOR_FILTERED	=> filter_output
		);

		internal_register: entity work.reg
		generic map (WIDTH => 16)
		port map (
			CLOCK => SYS_CLK,
			RESET => SYS_RST,
			DATA => intern_register,
			OUTPUT => intern_register_buffer
		);

		--process(SYS_CLK)
		--begin

			--if rising_edge(SYS_CLK) then

			--	if SYS_RST = '1' then
				--	intern_register <= (others => '0');
			--	else

							--intern_register_buffer <= intern_register;

						  --filter_input <= intern_register_buffer;

			--	end if;

			--end if;

		--end process;

		filter_input <= intern_register_buffer;

		needed_output <= not(filter_output) and intern_register_buffer;

		intern_register <= LNA_REGLIST when LNA_LOAD_REGLIST = '1' else
											 needed_output when LNA_HOLD_VALUE = '0' else
											 intern_register;

		LNA_CURRENT_REGLIST_REG <= intern_register_buffer;

--filter_input <= LNA_REGLIST;


--intern_register_buffer <= intern_register_buffer and not(filter_output);


--LNA_CURRENT_REGLIST_REG <= intern_register_buffer when LNA_LOAD_REGLIST = '0' and LNA_HOLD_VALUE = '0' else
													 --intern_register when LNA_LOAD_REGLIST = '0' and LNA_HOLD_VALUE = '1';



			LNA_ADDRESS <=
				"0000" when filter_output = "0000000000000001" else
				"0001" when filter_output = "0000000000000010" else
				"0010" when filter_output = "0000000000000100" else
				"0011" when filter_output = "0000000000001000" else
				"0100" when filter_output = "0000000000010000" else
				"0101" when filter_output = "0000000000100000" else
				"0110" when filter_output = "0000000001000000" else
				"0111" when filter_output = "0000000010000000" else
				"1000" when filter_output = "0000000100000000" else
				"1001" when filter_output = "0000001000000000" else
				"1010" when filter_output = "0000010000000000" else
				"1011" when filter_output = "0000100000000000" else
				"1100" when filter_output = "0001000000000000" else
				"1101" when filter_output = "0010000000000000" else
				"1110" when filter_output = "0100000000000000" else
				"1111" when filter_output = "1000000000000000" else
				(others => '0');


end architecture behave;
