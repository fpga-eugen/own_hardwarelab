library ieee;
use ieee.std_logic_1164.all;


entity Mux2 is
	port (	IN0:	in std_logic;
			IN1:	in std_logic;
			SEL:	in std_logic;
			OUTPUT:	out std_logic
    	);
end entity;


architecture structure of Mux2 is
begin
	OUTPUT <=	IN0 when SEL = '0' else
				IN1;
end architecture;
