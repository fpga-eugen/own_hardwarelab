--------------------------------------------------------------------------------
-- 	Teilsteuerung Arithmetisch-logischer Instruktionen im Kontrollpfad
--	des HWPR-Prozessors.
--------------------------------------------------------------------------------
--	Datum:		??.??.2014
--	Version:	?.?
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmTypes.all;

entity ArmArithInstructionCtrl is
	port(
		AIC_DECODED_VECTOR	: in std_logic_vector(15 downto 0);
		AIC_INSTRUCTION		: in std_logic_vector(31 downto 0);
		AIC_IF_IAR_INC		: out std_logic;
		AIC_ID_R_PORT_A_ADDR	: out std_logic_vector(3 downto 0);
		AIC_ID_R_PORT_B_ADDR	: out std_logic_vector(3 downto 0);
		AIC_ID_R_PORT_C_ADDR	: out std_logic_vector(3 downto 0);
		AIC_ID_REGS_USED	: out std_logic_vector(2 downto 0);
		AIC_ID_IMMEDIATE	: out std_logic_vector(31 downto 0);	
		AIC_ID_OPB_MUX_CTRL	: out std_logic;
		AIC_EX_ALU_CTRL		: out std_logic_vector(3 downto 0);
		AIC_MEM_RES_REG_EN	: out std_logic;
		AIC_MEM_CC_REG_EN	: out std_logic;
		AIC_WB_RES_REG_EN	: out std_logic;
		AIC_WB_CC_REG_EN	: out std_logic;	
		AIC_WB_W_PORT_A_ADDR	: out std_logic_vector(3 downto 0);
		AIC_WB_W_PORT_A_EN	: out std_logic;	
		AIC_WB_IAR_MUX_CTRL	: out std_logic;
		AIC_WB_IAR_LOAD		: out std_logic;
		AIC_WB_PSR_EN		: out std_logic;
		AIC_WB_PSR_SET_CC	: out std_logic;
		AIC_WB_PSR_ER		: out std_logic;
		AIC_DELAY		: out std_logic_vector(1 downto 0);
--------------------------------------------------------------------------------
--	Verwendung eines Typs aus ArmTypes weil die Codierung der Zustaende 
--	nicht vorgegeben ist.
--------------------------------------------------------------------------------
		AIC_ARM_NEXT_STATE	: out ARM_STATE_TYPE
	    );
end entity ArmArithInstructionCtrl;

architecture behave of ArmArithInstructionCtrl is

begin

end architecture behave;
