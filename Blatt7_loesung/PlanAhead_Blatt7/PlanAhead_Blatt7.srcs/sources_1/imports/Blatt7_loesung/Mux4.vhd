library ieee;
use ieee.std_logic_1164.all;


entity Mux4 is
	port (	IN0:	in std_logic;	
			IN1:	in std_logic;
			IN2:	in std_logic;
			IN3:	in std_logic;
			SEL:	in std_logic_vector(1 downto 0);
			OUTPUT:	out std_logic
    	);
end entity;


architecture structure of Mux4 is
begin
	OUTPUT <=	IN0 when SEL = "00" else
				IN1 when SEL = "01" else
				IN2 when SEL = "10" else
				IN3;
end architecture;

