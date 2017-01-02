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

entity ArmBarrelShifter_4bit is
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
end entity ArmBarrelShifter_4bit;

architecture structure of ArmBarrelShifter_4bit is

type dept_stage_option_mux is array(natural range <>) of std_logic_vector(OPERAND_WIDTH-1 downto 0);
type dept_stage_mux is array(natural range <>) of std_logic_vector(OPERAND_WIDTH-1 downto 0);

--signal depth_stage_first_option_mux : std_logic_vector(OPERAND_WIDTH-1 downto 0); -- b
--signal depth_stage_second_option_mux : std_logic_vector(OPERAND_WIDTH-1 downto 0); -- b
--signal depth_stage_second_mux : std_logic_vector(OPERAND_WIDTH-1 downto 0); -- y an a

signal dept_stage_mux_in : dept_stage_mux(0 to SHIFTER_DEPTH-1);
signal dept_stage_option_mux_out : dept_stage_option_mux(0 to SHIFTER_DEPTH-1);
signal dept_stage_mux_out : dept_stage_mux(0 to SHIFTER_DEPTH-1);


signal mux4_ctrl_option : std_logic_vector(1 downto 0);
signal mux2_ctrl_option : std_logic;
signal amount_buffer : std_logic_vector(SHIFTER_DEPTH-1 downto 0);


begin

dept_stage_mux_out(SHIFTER_DEPTH-1) <= DATA_OUT;
dept_stage_mux_in(0) <= OPERAND;

  mux2_depth: for depth in 0 to SHIFTER_DEPTH-1 generate
  begin
    mux2_width: for operand_width in OPERAND_WIDTH-1 downto 0 generate
    begin
      mux2: entity work.mux2
      port map(
        SEL => amount_buffer(depth),
        IN0 => dept_stage_mux_in(depth)(OPERAND_WIDTH-1-operand_width),
        IN1 => depth_stage_option_mux_out(depth)(OPERAND_WIDTH-1-operand_width),
        OUTPUT => depth_stage_mux_out(depth)(OPERAND_WIDTH-1)
      );

      mux2option_depth: for operand_width in 0 to OPERAND_WIDTH/2-1  generate
      begin
        mux2option_width: for depth in 0 downto SHIFTER_DEPTH generate
        begin
          mux2: entity work.mux2
          port map(
            SEL => mux2_ctrl_option,
            IN0 => dept_stage_mux_in(depth)(operand_width),
            IN1 => depth_stage_option_mux_out(depth)(operand_width),
            OUTPUT => depth_stage_mux_out(depth)(operand_width)
          );


      ------------------------------------------------
      			 mux4_first_row_option0 : entity work.mux4
      			 port map(
      			 SEL => mux4_ctrl_option,
      			 IN0 => '0', -- right shift
      			 IN1 => '1', -- arithm. right shift
      			 IN2 => OPERAND(OPERAND_WIDTH-2), -- left shift
      			 IN3 => OPERAND(0),    -- rotate
      			 OUTPUT => dept_stage_option_mux_out(OPERAND_WIDTH-1)
      			 );

      			 mux2_first_row_option1 : entity work.mux2
      			 port map(
      			 SEL => mux2_ctrl_option,
      			 IN0 => OPERAND(OPERAND_WIDTH-1), -- right shift or rotate
      			 IN1 => OPERAND(OPERAND_WIDTH-3), -- left shift
      			 OUTPUT => depth_stage_first_option_mux(OPERAND_WIDTH-2)
      			 );

      			 mux2_first_row_option2 : entity work.mux2
      			 port map(
      			 SEL => mux2_ctrl_option,
      			 IN0 => OPERAND(OPERAND_WIDTH-2), -- right shift or rotate
      			 IN1 => OPERAND(OPERAND_WIDTH-4), -- left shift
      			 OUTPUT => depth_stage_first_option_mux(OPERAND_WIDTH-3)
      			 );

      			 mux2_first_row_option3 : entity work.mux2
      			 port map(
      			 SEL => mux2_ctrl_option,
      			 IN0 => OPERAND(OPERAND_WIDTH-3), -- right shift or rotate
      			 IN1 => '0',
      			 OUTPUT => depth_stage_first_option_mux(OPERAND_WIDTH-4)
      			 );

      mux3_second_row_option0 : entity work.mux3
      port map(
      SEL => mux4_ctrl_option,
      IN0 => '0', -- right shift
      IN1 => '1', -- arithm. right shift
      IN2 => depth_stage_second_mux(OPERAND_WIDTH-3), -- left shift or rotate
      OUTPUT => depth_stage_second_option_mux(OPERAND_WIDTH-1)
      );

      mux3_second_row_option1 : entity work.mux3
      port map(
      SEL => mux4_ctrl_option,
      IN0 => '0', -- right shift
      IN1 => '1', -- arithm. right shift
      IN2 => depth_stage_second_mux(OPERAND_WIDTH-4), -- left shift or rotate
      OUTPUT => depth_stage_second_option_mux(OPERAND_WIDTH-2)
      );

      mux2_second_row_option2 : entity work.mux2
      port map(
      SEL => mux2_ctrl_option,
      IN0 => depth_stage_second_mux(OPERAND_WIDTH-1), -- right shift or rotate
      IN1 => '0', -- left shift
      OUTPUT => depth_stage_second_option_mux(OPERAND_WIDTH-3)
      );

      mux2_second_row_option3 : entity work.mux2
      port map(
      SEL => mux2_ctrl_option,
      IN0 => depth_stage_second_mux(OPERAND_WIDTH-2), -- right shift or rotate
      IN1 => '0', -- left shift
      OUTPUT => depth_stage_second_option_mux(OPERAND_WIDTH-4)
      );




------------------------------------------------


			 	------------------------------------------------first shit end



------------------------------------------------

amount_buffer <= (others => '0') when MUX_CTRL = "00" else -- no shift
								 AMOUNT;

mux4_ctrl_option <= "01" when (MUX_CTRL = "10" and OPERAND(OPERAND_WIDTH-1) = '1' and ARITH_SHIFT = '1') else -- arith right shift
 									  "00" when MUX_CTRL = "10" else -- right shift
										"10" when MUX_CTRL = "01" else	-- left
										"11" when MUX_CTRL = "11";	-- rotate

mux2_ctrl_option <= '0' when MUX_CTRL = "10" or MUX_CTRL = "11" else
										'1';

C_OUT <= C_IN when MUX_CTRL = "00" else
				 C_IN when AMOUNT = "00" else
				 OPERAND(to_integer(unsigned(AMOUNT))-1) when MUX_CTRL = "10" or MUX_CTRL = "11" else
				 OPERAND(OPERAND_WIDTH - 1 - to_integer(unsigned(AMOUNT)));

end architecture structure;
