use std.textio.all;
library ieee;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.TB_Tools.all;

entity ArmMultiplier_tb is
end entity ArmMultiplier_tb;

architecture behave of ArmMultiplier_tb is


	component ArmMultiplier
	Port (
		MUL_OP1 	: in  STD_LOGIC_VECTOR (31 downto 0);	-- Rm
		MUL_OP2 	: in  STD_LOGIC_VECTOR (31 downto 0);	-- Rs
		MUL_RES 	: out  STD_LOGIC_VECTOR (31 downto 0)	-- Rd bzw. RdLo
	);
	end component ArmMultiplier;

constant TEST : natural := 10;

signal mult1 : std_logic_vector(31 downto 0);
signal mult2 : std_logic_vector(31 downto 0);

type test_vect is array (natural range <>) of std_logic_vector(31 downto 0);

--signal buffer_result : std_logic_vector(63 downto 0);
signal result_output : std_logic_vector(31 downto 0);

  begin

  	UUT: ArmMultiplier
  	port map(
  			MUL_OP1		=> mult1,
  			MUL_OP2	=> mult2,
  			MUL_RES		=> result_output
  		);


      tb : process
			variable status : boolean := true;
			variable buffer_result : std_logic_vector(63 downto 0);
        begin

					mult1 <= (others => '0');
					mult2 <= (others => '0');
					wait for 10 ns;

						loop_start : for i in 0 to TEST loop

							mult1 <= std_logic_vector(to_signed((i*(-1)**i), mult1'length));
							mult2 <= std_logic_vector(to_signed(343*((i*9000)+1), mult2'length));
							wait for 1 ns;
							buffer_result := std_logic_vector(signed(mult1)*signed(mult2));
							wait for 10 ns;

								if buffer_result(31 downto 0) /= result_output then
									report "multiplikation not correct, expected: " & slv_to_string(buffer_result);
									report "result: " & slv_to_string(result_output);
									status := false;
								end if;

						end loop;

					mult1 <= (others => '1');
					mult2 <= (others => '1');
					wait for 1 ns;
					buffer_result := std_logic_vector(signed(mult1)*signed(mult2));
					wait for 10 ns;

							if result_output /= buffer_result(31 downto 0) then
								report " both inputs are maximum";
								report "mistake max: " & slv_to_string(result_output);
								status := false;
							end if;

						mult1 <= (others => '0');
						mult2 <= (others => '1');
						wait for 1 ns;
						buffer_result := std_logic_vector(signed(mult1)*signed(mult2));
						wait for 10 ns;

							if result_output /= buffer_result(31 downto 0) then
								report "mistake min: " & slv_to_string(result_output);
									status := false;
							end if;

						if status = false then
							report "test has errors";
						else
							report "test was correct";
						end if;


				report "end of test" severity failure;

      end process;

  end architecture;
