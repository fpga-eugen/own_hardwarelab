--------------------------------------------------------------------------------
-- 	Barrelshifter fuer LSL, LSR, ASR, ROR mit Shiftweiten von 0 bis 3 (oder 
--	generisch n-1) Bit. 
--------------------------------------------------------------------------------
--	Datum:		03.06.2014
--	Version:	0.KEEP.SMILE
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity ArmBarrelShifter is
--------------------------------------------------------------------------------
--	Breite der Operanden (n) und die Zahl der notwendigen
--	Multiplexerstufen (m) um Shifts von 0 bis n-1 Stellen realisieren zu
--	koennen. Es muss gelten: m = aufgerundet(log2(n))
--------------------------------------------------------------------------------
	generic (OPERAND_WIDTH : integer := 4;
			 SHIFTER_DEPTH : integer := 2 --ceil(log(2, OPERAND_WIDTH))
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


type bitvector2dOPERAND_WIDTH is array(natural range <>) of std_logic_vector(OPERAND_WIDTH-1 downto 0);
signal depth_stage_out: bitvector2dOPERAND_WIDTH(0 to SHIFTER_DEPTH);
signal depth_stage_right_shift_out, depth_stage_right_shift_no_arith, depth_stage_right_shift_arith: bitvector2dOPERAND_WIDTH(1 to SHIFTER_DEPTH);
signal depth_stage_left_shift_out: bitvector2dOPERAND_WIDTH(1 to SHIFTER_DEPTH);
signal depth_stage_right_rot_out: bitvector2dOPERAND_WIDTH(1 to SHIFTER_DEPTH);

signal depth_stage_carry_out_left_shift, depth_stage_carry_out_right_shift: std_logic_vector(0 to SHIFTER_DEPTH);


begin
		muxers_depth: for depth in 1 to SHIFTER_DEPTH generate
		begin
			muxers_width: for width in OPERAND_WIDTH-1 downto 0 generate
			begin
				stage_bit_select_op: entity work.Mux4
				port map (
					IN0 => depth_stage_out(depth-1)(width),
					IN1 => depth_stage_left_shift_out(depth)(width),
					IN2 => depth_stage_right_shift_out(depth)(width),
					IN3 => depth_stage_right_rot_out(depth)(width),
					SEL => MUX_CTRL,
					OUTPUT => depth_stage_out(depth)(width)
				);
				
				stage_bit_right_rot_out: entity work.Mux2
				port map (
					IN0 => depth_stage_out(depth-1)(width),
					IN1 => depth_stage_out(depth-1)( (width + (2 ** (SHIFTER_DEPTH - depth))) mod OPERAND_WIDTH),
					SEL => AMOUNT(SHIFTER_DEPTH - depth),
					OUTPUT => depth_stage_right_rot_out(depth)(width)
				);
				
				-- stage_bit_left_sift
				stage_bit_left_shift1_gen: if (width - (2 ** (SHIFTER_DEPTH - depth))) >= 0 generate
				begin
					stage_bit_left_shift1: entity work.Mux2
					port map (
						IN0 => depth_stage_out(depth-1)(width),
						IN1 => depth_stage_out(depth-1)(width - (2 ** (SHIFTER_DEPTH - depth))),
						SEL => AMOUNT(SHIFTER_DEPTH - depth),
						OUTPUT => depth_stage_left_shift_out(depth)(width) 
					);
				end generate;
				
				stage_bit_left_shift2_gen: if (width - (2 ** (SHIFTER_DEPTH - depth))) < 0 generate
				begin
					stage_bit_left_shift2: entity work.Mux2
					port map (
						IN0 => depth_stage_out(depth-1)(width),
						IN1 => '0',
						SEL => AMOUNT(SHIFTER_DEPTH - depth),
						OUTPUT => depth_stage_left_shift_out(depth)(width) 
					);
				end generate;
				
				--if ((width - (1 sll (SHIFTER_DEPTH - depth))) < 0) and () generate
				--begin
				--	stage_bit_left_shift2: entity work.Mux2
				--	port map (
				--		IN0 => depth_stage_out(depth-1)(width),
				--		IN1 => ,
				--		SEL => AMOUNT(SHIFTER_DEPTH - depth),
				--		OUTPUT => depth_stage_left_shift_out(depth)(width) 
				--	);
				--end generate;
				
				-- stage_bit_right_shift
				stage_bit_right_shift1_gen: if (width + (2 ** (SHIFTER_DEPTH - depth))) < OPERAND_WIDTH generate
				begin
					stage_bit_right_shift1: entity work.Mux2
					port map (
						IN0 => depth_stage_out(depth-1)(width),
						IN1 => depth_stage_out(depth-1)(width + (2 ** (SHIFTER_DEPTH - depth))),
						SEL => AMOUNT(SHIFTER_DEPTH - depth),
						OUTPUT => depth_stage_right_shift_out(depth)(width)
					);
				end generate;
				
				stage_bit_right_shift2_gen: if (width + (2 ** (SHIFTER_DEPTH - depth))) >= OPERAND_WIDTH generate
				begin
					stage_bit_right_shift2_select_arith: entity work.Mux2
					port map (
						IN0 => depth_stage_right_shift_no_arith(depth)(width),
						IN1 => depth_stage_right_shift_arith(depth)(width),
						SEL => ARITH_SHIFT,
						OUTPUT => depth_stage_right_shift_out(depth)(width)
					);
					
					stage_bit_right_shift2: entity work.Mux2
					port map (
						IN0 => depth_stage_out(depth-1)(width),
						IN1 => '0',
						SEL => AMOUNT(SHIFTER_DEPTH - depth),
						OUTPUT => depth_stage_right_shift_no_arith(depth)(width)
					);
					
					stage_bit_right_shift2_arith: entity work.Mux2
					port map (
						IN0 => depth_stage_out(depth-1)(width),
						IN1 => OPERAND(OPERAND_WIDTH-1),
						SEL => AMOUNT(SHIFTER_DEPTH - depth),
						OUTPUT => depth_stage_right_shift_arith(depth)(width)
					);
				end generate;
			end generate;
			
			------- CARRY STAGE -----------
			-- Laut HIGHLVL Shifter muss sich das C_OUT wie folgt verhalten:
			-- 1. when AMOUNT = 0 => C_OUT <= C_IN
			-- 2.  when AMOUNT != 0 then
			--           if (MUX_CTRL = "00") then
			--             C_OUT <= C_IN;
			--
			--           if (MUX_CTRL = "01" (Linksshift)) then
			--             C_OUT <= letztes rausgeshiftete Bit
			--
			--           if (MUX_CTRL = "10" (Rechtsshift)) then
			--             C_OUT <= letztes rausgeshiftete Bit
			--
			--           if (MUX_CTRL = "11" (Rechtsrotation)) then
			--             C_OUT <= Carry ist das letzte hereinrotierte
      --					                 Bit, also das ganz links, sofern um wenigstens 
      --					                 eine Stelle geschoben wurde
			
			
			stage_carry_out_right_shift: entity work.Mux2
			port map (
				IN0 => depth_stage_carry_out_right_shift(depth-1),
				IN1 => depth_stage_out(depth-1)( ( 2**(SHIFTER_DEPTH-depth)) - 1 ),
				SEL => AMOUNT(SHIFTER_DEPTH - depth),
				OUTPUT => depth_stage_carry_out_right_shift(depth)
			);
			
			stage_carry_out_left_shift: entity work.Mux2
			port map (
				IN0 => depth_stage_carry_out_left_shift(depth-1),
				IN1 => depth_stage_out(depth-1)( (OPERAND_WIDTH-1) - (( 2**(SHIFTER_DEPTH-depth)) - 1) ),
				SEL => AMOUNT(SHIFTER_DEPTH - depth),
				OUTPUT => depth_stage_carry_out_left_shift(depth)
			);
		end generate;
		
		C_OUT <=	 C_IN when (unsigned(AMOUNT) = 0) else
		          C_IN when ((unsigned(AMOUNT) /= 0) and (MUX_CTRL = "00")) else
					    depth_stage_carry_out_left_shift(SHIFTER_DEPTH) when ((unsigned(AMOUNT) /= 0) and (MUX_CTRL = "01")) else
					    depth_stage_carry_out_right_shift(SHIFTER_DEPTH) when ((unsigned(AMOUNT) /= 0) and (MUX_CTRL = "10"))else
					    depth_stage_out(SHIFTER_DEPTH)(OPERAND_WIDTH-1); --when ((unsigned(AMOUNT) /= 0) and (MUX_CTRL = "11"));
		
		depth_stage_carry_out_left_shift(0) <= C_IN;
		depth_stage_carry_out_right_shift(0) <= C_IN;
		
		depth_stage_out(0) <= OPERAND;
		DATA_OUT <= depth_stage_out(SHIFTER_DEPTH);
		

end architecture structure;

