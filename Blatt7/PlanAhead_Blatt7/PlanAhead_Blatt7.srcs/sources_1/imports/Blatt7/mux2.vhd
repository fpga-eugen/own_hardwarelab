library IEEE;
use IEEE.std_logic_1164.all;

entity mux2 is
port (s : in std_logic;
      a,b : in std_logic;
      y   : out std_logic
      );
end entity mux2;

architecture behavioral of mux2 is
  begin
    y <= 	a  when s = '0' else
        b  when s = '1';
  end behavioral;
