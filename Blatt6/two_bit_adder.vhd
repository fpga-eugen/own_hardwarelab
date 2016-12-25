library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity two_bit_adder is
	Port (
		A 	: in  std_logic_vector(1 downto 0);
    B 	: in  std_logic_vector(1 downto 0);
		S 	: out  std_logic_vector(1 downto 0);
    C 	: out  std_logic
	);
end entity two_bit_adder;

architecture structure of two_bit_adder is

begin

  S(0) <= A(0) xor B(0);
  S(1) <= (A(0) and B(0)) xor (A(1) xor B(1));
  C <= (A(1) and B(1)) or ((A(0) and B(0)) and (A(1) xor B(1)));

end architecture structure;
