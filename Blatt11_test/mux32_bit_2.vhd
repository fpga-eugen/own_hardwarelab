library IEEE;
use IEEE.std_logic_1164.all;

entity mux2_32_bit is
port (s : in std_logic;
      a,b : in std_logic_vector (31 downto 2);
      y   : out std_logic_vector (31 downto 2)
      );
end entity mux2_32_bit;

architecture behavioral of mux2_32_bit is
  begin
    y <= 	a  when s = '0' else
        b  when s = '1';
  end behavioral;
