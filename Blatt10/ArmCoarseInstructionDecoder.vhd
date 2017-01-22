--------------------------------------------------------------------------------
--	Decoder zur Ermittlung der Instruktionsgruppe der aktuellen
--	Instruktion im der ID-Stufe im Kontrollpfad des HWPR-Prozessors.
--------------------------------------------------------------------------------
--	Datum:		??.??.2014
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmTypes.all;

--------------------------------------------------------------------------------
--	17 Instruktionsgruppen:
--	CD_UNDEFINED
--	CD_SWI
--	CD_COPROCESSOR
--	CD_BRANCH
--	CD_LOAD_STORE_MULTIPLE
--	CD_LOAD_STORE_UNSIGNED_IMMEDIATE
--	CD_LOAD_STORE_UNSIGNED_REGISTER
--	CD_LOAD_STORE_SIGNED_IMMEDIATE
--	CD_LOAD_STORE_UNSIGNED_REGISTER
--	CD_ARITH_IMMEDIATE
--	CD_ARITH_REGISTER
--	CD_ARITH_REGISTER_REGISTER
--	CD_MSR_IMMEDIATE
--	CD_MSR_REGISTER
--	CD_MRS
--	CD_MULTIPLY
--	CD_SWAP

-- 	UNDEFINED wird durch den Nullvektor angezeigt, die anderen
--	Befehlsgruppen durch einen 1-aus-16-Code.
--------------------------------------------------------------------------------

entity ArmCoarseInstructionDecoder is
	port(
		CID_INSTRUCTION		: in std_logic_vector(31 downto 0);
		CID_DECODED_VECTOR	: out std_logic_vector(15 downto 0)
	    );
end entity ArmCoarseInstructionDecoder;

architecture behave of ArmCoarseInstructionDecoder is
	signal DECV	: COARSE_DECODE_TYPE;
--	...
	signal inst_27_to_25 : std_logic_vector(2 downto 0);
	signal inst_24 : std_logic;
	signal inst_4 : std_logic;
	signal inst_24_to_23 : std_logic_vector(1 downto 0);
	signal inst_20 : std_logic;
	signal inst_21 : std_logic;
	signal inst_7 : std_logic;
	signal inst_7_and_4 : std_logic_vector(1 downto 0);
	signal inst_6_to_5 : std_logic_vector(1 downto 0);
	signal inst_24_to_23_and_inst_21_to_20 : std_logic_vector(3 downto 0);
	signal inst_20_and_6 : std_logic_vector(1 downto 0);
	signal inst_22 : std_logic;

begin
	CID_DECODED_VECTOR	<= DECV;
	inst_27_to_25 <= CID_INSTRUCTION(27 downto 25);
	inst_24 <= CID_INSTRUCTION(24);
	inst_4 <= CID_INSTRUCTION(4);
	inst_24_to_23 <= CID_INSTRUCTION(24 downto 23);
	inst_20 <= CID_INSTRUCTION(20);
	inst_21 <= CID_INSTRUCTION(21);
	inst_7 <= CID_INSTRUCTION(7);
	inst_7_and_4(1) <= CID_INSTRUCTION(7);
	inst_7_and_4(0) <= CID_INSTRUCTION(4);
	inst_6_to_5 <= CID_INSTRUCTION(6 downto 5);
	inst_24_to_23_and_inst_21_to_20(3 downto 2) <= CID_INSTRUCTION(24 downto 23);
	inst_24_to_23_and_inst_21_to_20(1 downto 0) <= CID_INSTRUCTION(21 downto 20);
	inst_20_and_6(1) <= CID_INSTRUCTION(20);
	inst_20_and_6(0) <= CID_INSTRUCTION(6);
	inst_22 <= CID_INSTRUCTION(22);
--	...

	process(CID_INSTRUCTION, inst_27_to_25, inst_24, inst_4, inst_24_to_23, inst_20, inst_21, inst_7, inst_7_and_4, inst_6_to_5, inst_24_to_23_and_inst_21_to_20, inst_20_and_6, inst_22)
		begin -- warum process und wieso so viele variablen reinballern?

			case inst_27_to_25 is
				when "111" => case inst_24 is
												when '1' => DECV <= CD_SWI;
												when others => DECV <= CD_COPROCESSOR;
											end case;

				when "110" => DECV <= CD_COPROCESSOR;
				when "101" => DECV <= CD_BRANCH;
				when "100" => DECV <= CD_LOAD_STORE_MULTIPLE;

				when "011" => case inst_4 is
												when '0' => DECV <= CD_LOAD_STORE_UNSIGNED_REGISTER;
												when others => DECV <= CD_UNDEFINED;
											end case;

				when "010" => DECV <= CD_LOAD_STORE_UNSIGNED_IMMEDIATE;

				when "001" => case inst_24_to_23 is
												when "10" => case inst_20 is
														when '1' => DECV <= CD_ARITH_IMMEDIATE;
														when others => case inst_21 is
																							when '1' => DECV <= CD_MSR_IMMEDIATE;
																							when others => DECV <= CD_UNDEFINED;
																					 end case;
																		 end case;
												when others => DECV <= CD_ARITH_IMMEDIATE;
											end case;

				when others => case inst_7_and_4	is
												when "11" => case inst_6_to_5 is
																			when "00" => case inst_24_to_23_and_inst_21_to_20 is
																											when "1000" => DECV <= CD_SWAP;
																											when others => case inst_24 is
																																				when '0' => DECV <= CD_MULTIPLY;
																																				when others => DECV <= CD_UNDEFINED;
																																		 end case;
																									 end case;
																			when others => case inst_20_and_6 is
																												when "01" => DECV <= CD_UNDEFINED;
																												when others => case inst_22 is
																																					when '1' => DECV <= CD_LOAD_STORE_SIGNED_IMMEDIATE;
																																					when others => DECV <= CD_LOAD_STORE_SIGNED_REGISTER;
																																			 end case;
																										 end case;
																		end case;
												when "10" => case inst_24_to_23 is
																					when "10" => case inst_20 is
																												when '1' => DECV <= CD_ARITH_REGISTER;
																												when others => DECV <= CD_UNDEFINED;
																										end case;
																					when others => DECV <= CD_ARITH_REGISTER;
																		 end case;
											 when "01" => case inst_24_to_23 is
												  						 	when "10" => case inst_20 is
																				 								when '1' => DECV <= CD_ARITH_REGISTER_REGISTER;
																												when others => DECV <= CD_UNDEFINED;
																									  end case;
																				when others => DECV <= CD_ARITH_REGISTER_REGISTER;
																		end case;
											when others => case inst_24_to_23 is
																			when "10" => case inst_20 is
																											when '1' => DECV <= CD_ARITH_REGISTER;
																											when others => case inst_21 is
																																				when '0' => DECV <= CD_MRS;
																																				when others => case inst_6_to_5 is
																																													when "00" => DECV <= CD_MSR_REGISTER;
																																													when others => DECV <= CD_UNDEFINED;
																																												end case;
																												 end case;
																										end case;
																		 when others => DECV <= CD_ARITH_REGISTER;
																	end case;
											end case;
		end case;

	end process;






--------------------------------------------------------------------------------
--	Test fuer die Verhaltenssimulation.
--------------------------------------------------------------------------------
-- synthesis translate_off
 	CHECK_NR_OF_SIGNALS : process(CID_INSTRUCTION,DECV)IS
 		variable NR : integer range 0 to 16 := 0;
 	begin
 		NR := 0;
 		for i in DECV'range loop
 			if DECV(i) = '1' then
 				NR := NR + 1;
 			end if;
 		end loop;
  		assert NR <= 1 report "Fehler in ArmCoarseInstructionDecoder: Instruktion nicht eindeutig erkannt." severity error;
 	end process CHECK_NR_OF_SIGNALS;
-- synthesis translate_on
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end architecture behave;
