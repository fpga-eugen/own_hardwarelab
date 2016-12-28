--------------------------------------------------------------------------------
--	Schaltung fuer das Zaehlen von Einsen in einem 16-Bit-Vektor, realisiert
-- 	als Baum von Addierern.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ArmRegisterBitAdder is
	Port (
		RBA_REGLIST 	: in  std_logic_vector(15 downto 0);
		RBA_NR_OF_REGS 	: out  std_logic_vector(4 downto 0)
	);
end entity ArmRegisterBitAdder;

architecture structure of ArmRegisterBitAdder is

signal half_adder_vector : std_logic_vector(15 downto 0);
signal two_bit_adder_vector : std_logic_vector(15 downto 0);
signal three_bit_adder_vector : std_logic_vector(11 downto 0);
signal four_bit_adder_vector : std_logic_vector(7 downto 0);

begin

	generate_half_adders : for genCounter in 0 to 7 generate
		begin
			half_adder : entity work.half_adder
			port map(
			A => RBA_REGLIST(2*genCounter),
			B => RBA_REGLIST((2*genCounter)+1),
			S => half_adder_vector(2*genCounter),
			C => half_adder_vector((2*genCounter) + 1)
			);
		end generate;

		generate_two_bit_adders : for genCounter in 0 to 3 generate
			begin
				two_bit_adder : entity work.two_bit_adder
				port map(
				A(0) => half_adder_vector(4*genCounter),
				A(1) => half_adder_vector((4*genCounter) + 1),
				B(0) => half_adder_vector((4*genCounter) + 2),
				B(1) => half_adder_vector((4*genCounter) + 3),
				S(0) => three_bit_adder_vector(3*genCounter),
				S(1) => three_bit_adder_vector((3*genCounter) + 1),
				C => three_bit_adder_vector((3*genCounter) + 2)
				);
			end generate;

		generate_three_bit_adders : for genCounter in 0 to 1 generate
			begin
				three_bit_adder : entity work.three_bit_adder
				port map(
				A(0) => three_bit_adder_vector(6*genCounter),
				A(1) => three_bit_adder_vector((6*genCounter) + 1),
				A(2) => three_bit_adder_vector((6*genCounter) + 2),
				B(0) => three_bit_adder_vector((6*genCounter) + 3),
				B(1) => three_bit_adder_vector((6*genCounter) + 4),
				B(2) => three_bit_adder_vector((6*genCounter) + 5),
				S(0) => four_bit_adder_vector(4*genCounter),
				S(1) => four_bit_adder_vector((4*genCounter) + 1),
				S(2) => four_bit_adder_vector((4*genCounter) + 2),
				C => four_bit_adder_vector((4*genCounter) + 3)
				);
			end generate;

			four_bit_adder : entity work.four_bit_adder
			port map(
			A(0) => four_bit_adder_vector(0),
			A(1) => four_bit_adder_vector(1),
			A(2) => four_bit_adder_vector(2),
			A(3) => four_bit_adder_vector(3),
			B(0) => four_bit_adder_vector(4),
			B(1) => four_bit_adder_vector(5),
			B(2) => four_bit_adder_vector(6),
			B(3) => four_bit_adder_vector(7),
			S(0) => RBA_NR_OF_REGS(0),
			S(1) => RBA_NR_OF_REGS(1),
			S(2) => RBA_NR_OF_REGS(2),
			S(3) => RBA_NR_OF_REGS(3),
			C => RBA_NR_OF_REGS(4)
			);

end architecture structure;
