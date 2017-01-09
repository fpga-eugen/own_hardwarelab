--------------------------------------------------------------------------------
--	ALU des ARM-Datenpfades
--------------------------------------------------------------------------------
--	Datum:		??.??.14
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmTypes.all;

entity ArmALU is
    Port ( ALU_OP1 		: in	std_logic_vector(31 downto 0);
           ALU_OP2 		: in 	std_logic_vector(31 downto 0);
    	   ALU_CTRL 	: in	std_logic_vector(3 downto 0);
    	   ALU_CC_IN 	: in	std_logic_vector(1 downto 0);
		   ALU_RES 		: out	std_logic_vector(31 downto 0);
		   ALU_CC_OUT	: out	std_logic_vector(3 downto 0)
   	);
end entity ArmALU;

architecture behave of ArmALU is

  signal result : std_logic_vector(31 downto 0);
  signal carry_overflow_buffer : std_logic_vector(32 downto 0);
  signal op1_buffer : std_logic_vector(32 downto 0);
  signal op2_buffer : std_logic_vector(32 downto 0);
  signal carry_bit : std_logic_vector(31 downto 0);

  signal result_add : std_logic_vector(32 downto 0);
  signal result_sub : std_logic_vector(32 downto  0);
  signal result_rsb : std_logic_vector(32 downto  0);
  signal result_adc : std_logic_vector(32 downto  0);
  signal result_sbc : std_logic_vector(32 downto  0);
  signal result_rsc : std_logic_vector(32 downto  0);

begin




carry_bit <= (0 => ALU_CC_IN(1), others => '0');

op1_buffer <= '0' & ALU_OP1;
op2_buffer <= '0' & ALU_OP2;
carry_overflow_buffer <= std_logic_vector(signed(op1_buffer) + signed(op2_buffer));

result_add <= std_logic_vector(signed(op1_buffer) + signed(op2_buffer));
result_sub <= std_logic_vector(signed(op1_buffer) - signed(op2_buffer));
result_rsb <= std_logic_vector(signed(op2_buffer) - signed(op1_buffer));
result_adc <= std_logic_vector(signed(op1_buffer) + signed(op2_buffer) + signed(carry_bit));
result_sbc <= std_logic_vector(signed(op1_buffer) - signed(op2_buffer) + signed(carry_bit) - to_signed(1, 33));
result_rsc <= std_logic_vector(signed(ALU_OP2) - signed(op1_buffer) + signed(carry_bit) - to_signed(1, 33));


result <=  ALU_OP1 and ALU_OP2 when ALU_CTRL = OP_AND or ALU_CTRL = OP_TST else
           ALU_OP1 xor ALU_OP2 when ALU_CTRL = OP_EOR or ALU_CTRL = OP_TEQ else
           ALU_OP1 or ALU_OP2 when ALU_CTRL = OP_ORR else
           ALU_OP1 and not(ALU_OP2) when ALU_CTRL = OP_BIC else
           ALU_OP2 when ALU_CTRL = OP_MOV else
           not(ALU_OP2) when ALU_CTRL = OP_MVN else
           result_add(31 downto 0) when ALU_CTRL = OP_ADD or ALU_CTRL = OP_CMN else
           result_sub(31 downto 0) when ALU_CTRL = OP_SUB or ALU_CTRL = OP_CMP else
           result_rsb(31 downto 0) when ALU_CTRL = OP_RSB else
           result_adc(31 downto 0) when ALU_CTRL = OP_ADC else
           result_sbc(31 downto 0) when ALU_CTRL = OP_SBC else
           result_rsc(31 downto 0); --when ALU_CTRL = OP_RSC; --else
           --(others => '0');
ALU_RES <= result;

ALU_CC_OUT(3) <= result(31);

ALU_CC_OUT(2) <= '1' when result = std_logic_vector(to_unsigned(0, result'length)) else
                 '0';

ALU_CC_OUT(1) <= result_add(32) when ALU_CTRL = OP_ADD or ALU_CTRL = OP_CMN else
                 result_adc(32) when ALU_CTRL = OP_ADC else
                 not(result_sub(32)) when ALU_CTRL = OP_SUB or ALU_CTRL = OP_CMP else
                 not(result_sbc(32)) when ALU_CTRL = OP_SBC else
                 not(result_rsc(32)) when ALU_CTRL = OP_RSC else
                 ALU_CC_IN(1);

ALU_CC_OUT(0) <= ((not(ALU_OP1(31)) and not(ALU_OP2(31))) and result_add(31)) or ((ALU_OP1(31) and ALU_OP2(31)) and not(result_add(31))) when ALU_CTRL = OP_ADD or ALU_CTRL = OP_CMN else
                 ((not(ALU_OP1(31)) and not(ALU_OP2(31))) and result_adc(31)) or ((ALU_OP1(31) and ALU_OP2(31)) and not(result_adc(31))) when ALU_CTRL = OP_ADC else
                 ((not(ALU_OP1(31)) and ALU_OP2(31)) and result_sub(31)) or ((ALU_OP1(31) and not(ALU_OP2(31))) and not(result_sub(31))) when ALU_CTRL = OP_SUB or ALU_CTRL = OP_CMP else
                 ((not(ALU_OP1(31)) and ALU_OP2(31)) and result_sbc(31)) or ((ALU_OP1(31) and not(ALU_OP2(31))) and not(result_sbc(31))) when ALU_CTRL = OP_SBC else
                 ((not(ALU_OP1(31)) and not(ALU_OP2(31))) and result_adc(31)) or ((ALU_OP1(31) and ALU_OP2(31)) and not(result_adc(31))) when ALU_CTRL = OP_RSB else
                 ((ALU_OP1(31) and not(ALU_OP2(31))) and result_sbc(31)) or ((not(ALU_OP1(31)) and ALU_OP2(31)) and not(result_sbc(31))) when ALU_CTRL = OP_RSC else
                 ALU_CC_IN(0);

end architecture behave;
