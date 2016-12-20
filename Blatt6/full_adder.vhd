library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is
	Port (
		A 	: in  std_logic;
    B 	: in  std_logic;
    Cin 	: in  std_logic;
		S 	: out  std_logic;
    C 	: out  std_logic;
	);
end entity ArmRegisterBitAdder;

architecture structure of full_adder is

begin

  S <= Cin xor A xor B;
  C <= (A and B) or (A and Cin) or (B and Cin);

end architecture structure;
