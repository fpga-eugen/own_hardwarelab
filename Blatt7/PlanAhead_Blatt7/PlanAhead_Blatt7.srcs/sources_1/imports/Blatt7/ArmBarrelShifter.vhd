--------------------------------------------------------------------------------
-- 	Barrelshifter fuer LSL, LSR, ASR, ROR mit Shiftweiten von 0 bis 3 (oder
--	generisch n-1) Bit.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity ArmBarrelShifter is
--------------------------------------------------------------------------------
--	Breite der Operanden (n) und die Zahl der notwendigen
--	Multiplexerstufen (m) um Shifts von 0 bis n-1 Stellen realisieren zu
--	koennen. Es muss gelten: ???
--------------------------------------------------------------------------------
	generic (OPERAND_WIDTH : integer := 4;
			 SHIFTER_DEPTH : integer := 2
	 );
	port ( 	OPERAND 	: in std_logic_vector(OPERAND_WIDTH-1 downto 0);
    		MUX_CTRL 	: in std_logic_vector(1 downto 0);
    		AMOUNT 		: in std_logic_vector(SHIFTER_DEPTH-1 downto 0);
    		ARITH_SHIFT : in std_logic;
    		C_IN 		: in std_logic;
           	DATA_OUT 	: out std_logic_vector(OPERAND_WIDTH-1 downto 0);
    		C_OUT 		: out std_logic
	);
end entity ArmBarrelShifter;

architecture structure of ArmBarrelShifter is

signal depth_stage_first_option_mux : std_logic_vector(OPERAND_WIDTH-1 downto 0); -- b
signal depth_stage_second_option_mux : std_logic_vector(OPERAND_WIDTH-1 downto 0); -- b
signal depth_stage_second_mux : std_logic_vector(OPERAND_WIDTH-1 downto 0); -- y an a
signal mux4_ctrl_option : std_logic_vector(1 downto 0);
signal mux2_ctrl_option : std_logic;
signal amount_buffer : std_logic_vector(SHIFTER_DEPTH-1 downto 0);


begin

			 mux2_first_row0 : entity work.mux2
			 port map(
			 s => amount_buffer(0),
			 a => OPERAND(OPERAND_WIDTH-1),
			 b => depth_stage_first_option_mux(OPERAND_WIDTH-1),
			 y => depth_stage_second_mux(OPERAND_WIDTH-1)
			 );

			 mux2_first_row1 : entity work.mux2
			 port map(
			 s => amount_buffer(0),
			 a => OPERAND(OPERAND_WIDTH-2),
			 b => depth_stage_first_option_mux(OPERAND_WIDTH-2),
			 y => depth_stage_second_mux(OPERAND_WIDTH-2)
			 );

			 mux2_first_row2 : entity work.mux2
			 port map(
			 s => amount_buffer(0),
			 a => OPERAND(OPERAND_WIDTH-3),
			 b => depth_stage_first_option_mux(OPERAND_WIDTH-3),
			 y => depth_stage_second_mux(OPERAND_WIDTH-3)
			 );

			 mux2_first_row3 : entity work.mux2
			 port map(
			 s => amount_buffer(0),
			 a => OPERAND(OPERAND_WIDTH-4),
			 b => depth_stage_first_option_mux(OPERAND_WIDTH-4),
			 y => depth_stage_second_mux(OPERAND_WIDTH-4)
			 );
------------------------------------------------
			 mux4_first_row_option0 : entity work.mux4
			 port map(
			 SEL => mux4_ctrl_option,
			 IN0 => '0', -- right shift
			 IN1 => '1', -- arithm. right shift
			 IN2 => OPERAND(OPERAND_WIDTH-2), -- left shift
			 IN3 => OPERAND(OPERAND_WIDTH-4),    -- rotate
			 OUTPUT => depth_stage_first_option_mux(OPERAND_WIDTH-1)
			 );

			 mux2_first_row_option1 : entity work.mux2
			 port map(
			 s => mux2_ctrl_option,
			 a => OPERAND(OPERAND_WIDTH-1), -- right shift or rotate
			 b => OPERAND(OPERAND_WIDTH-3), -- left shift
			 y => depth_stage_first_option_mux(OPERAND_WIDTH-2)
			 );

			 mux2_first_row_option2 : entity work.mux2
			 port map(
			 s => mux2_ctrl_option,
			 a => OPERAND(OPERAND_WIDTH-2), -- right shift or rotate
			 b => OPERAND(OPERAND_WIDTH-4), -- left shift
			 y => depth_stage_first_option_mux(OPERAND_WIDTH-3)
			 );

			 mux2_first_row_option3 : entity work.mux2
			 port map(
			 s => mux2_ctrl_option,
			 a => OPERAND(OPERAND_WIDTH-3), -- right shift or rotate
			 b => '0',
			 y => depth_stage_first_option_mux(OPERAND_WIDTH-4)
			 );
------------------------------------------------


			 	------------------------------------------------first shit end


				mux2_second_row0 : entity work.mux2
				port map(
				s => amount_buffer(1),
				a => depth_stage_second_mux(OPERAND_WIDTH-1),
				b => depth_stage_second_option_mux(OPERAND_WIDTH-1),
				y => DATA_OUT(OPERAND_WIDTH-1)
				);

				mux2_second_row1 : entity work.mux2
				port map(
				s => amount_buffer(1),
				a => depth_stage_second_mux(OPERAND_WIDTH-2),
				b => depth_stage_second_option_mux(OPERAND_WIDTH-2),
				y => DATA_OUT(OPERAND_WIDTH-2)
				);

				mux2_second_row2 : entity work.mux2
				port map(
				s => amount_buffer(1),
				a => depth_stage_second_mux(OPERAND_WIDTH-3),
				b => depth_stage_second_option_mux(OPERAND_WIDTH-3),
				y => DATA_OUT(OPERAND_WIDTH-3)
				);

				mux2_second_row3 : entity work.mux2
				port map(
				s => amount_buffer(1),
				a => depth_stage_second_mux(OPERAND_WIDTH-4),
				b => depth_stage_second_option_mux(OPERAND_WIDTH-4),
				y => DATA_OUT(OPERAND_WIDTH-4)
				);

------------------------------------------------
			 mux3_second_row_option0 : entity work.mux3
			 port map(
			 SEL => mux4_ctrl_option,
			 IN0 => '0', -- right shift
			 IN1 => '1', -- arithm. right shift
			 IN2 => depth_stage_second_mux(OPERAND_WIDTH-2), -- left shift or rotate
			 OUTPUT => depth_stage_second_option_mux(OPERAND_WIDTH-1)
			 );

			 mux3_second_row_option1 : entity work.mux3
			 port map(
			 SEL => mux4_ctrl_option,
			 IN0 => '0', -- right shift
			 IN1 => '1', -- arithm. right shift
			 IN2 => depth_stage_second_mux(OPERAND_WIDTH-4), -- left shift or rotate
			 OUTPUT => depth_stage_second_option_mux(OPERAND_WIDTH-1)
			 );

			 mux2_second_row_option2 : entity work.mux2
			 port map(
			 s => mux2_ctrl_option,
			 a => depth_stage_second_mux(OPERAND_WIDTH-1), -- right shift or rotate
			 b => '0', -- left shift
			 y => depth_stage_second_option_mux(OPERAND_WIDTH-3)
			 );

			 mux2_second_row_option3 : entity work.mux2
			 port map(
			 s => mux2_ctrl_option,
			 a => depth_stage_second_mux(OPERAND_WIDTH-2), -- right shift or rotate
			 b => '0', -- left shift
			 y => depth_stage_second_option_mux(OPERAND_WIDTH-4)
			 );
------------------------------------------------

amount_buffer <= "00" when MUX_CTRL = "00" else -- no shift
								 AMOUNT;

mux4_ctrl_option <= "00" when MUX_CTRL = "10" else -- right shift
 									  "01" when (MUX_CTRL = "10" and OPERAND(OPERAND_WIDTH-1) = '1') and ARITH_SHIFT = '1' else -- arith right shift
										"10" when MUX_CTRL = "01" else	-- left
										"11" when MUX_CTRL = "11";	-- rotate

mux2_ctrl_option <= '0' when MUX_CTRL = "10" or MUX_CTRL = "11" else
										'1';

end architecture structure;
