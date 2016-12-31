use std.textio.all;
library ieee;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.TB_Tools.all;

entity ArmBarrelShifter_4bit_tb is
	generic(
		OPERAND_WIDTH	: integer := 4;
		AMOUNT_WIDTH	: integer := 2
--------------------------------------------------------------------------------
--	Die Testbench bricht bei Ueberschreiten folgender Fehlergrenze ab.
--	Bei Fehlergrenze 0 werden alle Tests durchgefuehrt und alle Fehler
--	ausgegeben.
--------------------------------------------------------------------------------
		--BREAK_ON_NUMBER_OF_ERRORS : natural := 100;
--------------------------------------------------------------------------------
--	Bei Bedarf: Test aller Operationen auf allen Operanden von 0 bis n
--	(mit n = (2^32)-1)
--------------------------------------------------------------------------------
		--CHECK_ALL	: boolean := TRUE;
--------------------------------------------------------------------------------
--	Statt aller 2^32 Operanden werden nur die ersten (2^32)/(2^TEST_DIVIDER)
--	Operanden getestet, TEST_DEVIDER ist zwingend eine Zweierpotenz
--------------------------------------------------------------------------------
		--TEST_DIVIDER	: integer := 4
--------------------------------------------------------------------------------
	 );
end entity ArmBarrelShifter_4bit_tb;

architecture behave of ArmBarrelShifter_4bit_tb is

--	component ArmBarrelShifter_HILEVEL
--	generic(
--		OPERAND_WIDTH : integer;
--		SHIFTER_DEPTH : integer
--	);
--	port(
--		OPERAND		: in std_logic_vector(OPERAND_WIDTH-1 downto 0);
--		MUX_CTRL	: in std_logic_vector(1 downto 0);
--		AMOUNT		: in std_logic_vector(AMOUNT_WIDTH-1 downto 0);
--		ARITH_SHIFT : in std_logic;
--		C_IN		: in std_logic;
--		DATA_OUT	: out std_logic_vector(OPERAND_WIDTH-1 downto 0);
--		C_OUT		: out std_logic
--	);
--	end component;

	component ArmBarrelShifter
	generic(
		OPERAND_WIDTH : integer;
		SHIFTER_DEPTH : integer
	);
	port(
		    OPERAND		: in std_logic_vector(3 downto 0);
		    MUX_CTRL	: in std_logic_vector(1 downto 0);
		    AMOUNT		: in std_logic_vector(1 downto 0);
		    ARITH_SHIFT : in std_logic;
		    C_IN		: in std_logic;
		    DATA_OUT	: out std_logic_vector(3 downto 0);
		    C_OUT		: out std_logic
	    );
	end component ArmBarrelShifter;

  signal WORKING_DELAY_10 	: time 		:= 10 ns;
--  signal WORKING_DELAY_20 	: time 		:= 20 ns;
  signal WORKING_DELAY_40 	: time 		:= 40 ns;
  signal test : std_logic := '0';
	signal	OPERAND		: std_logic_vector(OPERAND_WIDTH-1 downto 0) := (others => '0');
	signal	MUX_CTRL	: std_logic_vector(1 downto 0)	:= "00";
	signal	AMOUNT		: std_logic_vector(AMOUNT_WIDTH-1 downto 0) := (others => '0');
	signal	ARITH_SHIFT	: std_logic_vector(0 downto 0) := "0";
	signal	C_IN		: std_logic := '0';
	signal	DATA_OUT_BEHAVE	: std_logic_vector(OPERAND_WIDTH-1 downto 0);
	signal	C_OUT_BEHAVE	: std_logic;
	signal	DATA_OUT_STRUCT	: std_logic_vector(OPERAND_WIDTH-1 downto 0);
	signal	C_OUT_STRUCT	: std_logic;

  begin
  	INST_STRUCTURE: ArmBarrelShifter
  	generic map(
  			   OPERAND_WIDTH => 4,
  			   SHIFTER_DEPTH => 2
  		   )
  	port map(
  			OPERAND		=> OPERAND,
  			MUX_CTRL	=> MUX_CTRL,
  			AMOUNT		=> AMOUNT,
  			ARITH_SHIFT	=> ARITH_SHIFT(0),
  			C_IN		=> C_IN,
  			DATA_OUT	=> DATA_OUT_STRUCT,
  			C_OUT		=> C_OUT_STRUCT
  		);

      OPERAND <= "1001", "0111" after 210 ns, "0000" after 230 ns;
      ARITH_SHIFT <= "0", "1" after 120 ns, "0" after 160 ns;
      MUX_CTRL <= "00", "01" after 40 ns, "10" after 80 ns, "11" after 160 ns, "00" after 200 ns;
      C_IN <= '0', '1' after 20 ns, '0' after 30 ns, '1' after 40 ns, '0' after 50 ns,
              '1' after 100 ns, '0' after 110 ns, '1' after 160 ns, '0' after 170 ns,
              '1' after 190 ns, '0' after 230 ns;


      tb : process
        begin

          test_1 : for i in 0 to 4 loop

           test_2 : for j in 0 to 3 loop

              AMOUNT <= std_logic_vector(to_unsigned(j, AMOUNT'length));
              wait for WORKING_DELAY_10;

           end loop;

         end loop;

         AMOUNT <= std_logic_vector(to_unsigned(0, AMOUNT'length));
         wait for WORKING_DELAY_10;
         AMOUNT <= std_logic_vector(to_unsigned(2, AMOUNT'length));
         wait for 2*WORKING_DELAY_10;
         AMOUNT <= std_logic_vector(to_unsigned(3, AMOUNT'length));
         wait for WORKING_DELAY_10;
         AMOUNT <= std_logic_vector(to_unsigned(0, AMOUNT'length));
         wait for WORKING_DELAY_10;

  report "end of test" severity failure;

      end process;

  end architecture;
