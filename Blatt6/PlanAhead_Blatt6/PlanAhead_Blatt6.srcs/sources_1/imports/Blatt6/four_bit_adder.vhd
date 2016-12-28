library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity four_bit_adder is
	Port (
		A 	: in  std_logic_vector(3 downto 0);
    B 	: in  std_logic_vector(3 downto 0);
		S 	: out  std_logic_vector(3 downto 0);
    C 	: out  std_logic
	);
end entity four_bit_adder;

architecture structure of four_bit_adder is

signal cout_buffer : std_logic_vector(2 downto 0);
signal cin_0 : std_logic := '0';

begin

  full_adder_1 : entity work.full_adder
  port map (
  A => A(0),
  B => B(0),
  Cin => cin_0,
  S => S(0),
  C => cout_buffer(0)
  );

  full_adder_2 : entity work.full_adder
  port map (
  A => A(1),
  B => B(1),
  Cin => cout_buffer(0),
  S => S(1),
  C => cout_buffer(1)
  );

  full_adder_3 : entity work.full_adder
  port map (
  A => A(2),
  B => B(2),
  Cin => cout_buffer(1),
  S => S(2),
  C => cout_buffer(2)
  );

  full_adder_4 : entity work.full_adder
  port map (
  A => A(3),
  B => B(3),
  Cin => cout_buffer(2),
  S => S(3),
  C => C
  );

end architecture structure;
