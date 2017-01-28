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

signal opcode : std_logic_vector(3 downto 0);

signal sprung : std_logic;

signal arith_immediate : std_logic;

signal arith_register : std_logic;

signal arith_register_register : std_logic;

begin

opcode <= AIC_INSTRUCTION(24 downto 21); -- opcode

AIC_EX_ALU_CTRL <= opcode; -- alu opcode

-- steht im text
AIC_ID_R_PORT_A_ADDR <= AIC_INSTRUCTION(19 downto 16); -- Rn
AIC_ID_R_PORT_B_ADDR <= AIC_INSTRUCTION(3 downto 0); -- Rm
AIC_ID_R_PORT_C_ADDR <= AIC_INSTRUCTION(11 downto 8); --Rs
AIC_WB_W_PORT_A_ADDR <= AIC_INSTRUCTION(15 downto 12); -- Rd

-- welcher prozess cd_arith_zeugs
arith_immediate <= AIC_DECODED_VECTOR(8); -- 001
arith_register <= AIC_DECODED_VECTOR(9); -- 010
arith_register_register <= AIC_DECODED_VECTOR(10); -- 100


-- steht im text direktoperand über mux klatschen
AIC_ID_OPB_MUX_CTRL <= arith_immediate;
AIC_ID_IMMEDIATE(7 downto 0) <= AIC_INSTRUCTION(7 downto 0);
AIC_ID_IMMEDIATE(31 downto 8) <= (others => '0');

AIC_MEM_RES_REG_EN <= '1'; -- immer zu setzen, ALU Ergebnis wird geschrieben
AIC_WB_RES_REG_EN <= '1'; -- ebenfalls

AIC_MEM_CC_REG_EN <= '1'; -- soll immer enable sein, zwischen ex und mem stufe, siehe tabelle und text
AIC_WB_CC_REG_EN <= '1'; -- ebenso
AIC_WB_RES_REG_EN <= '1'; -- gilt dasselbe, siehe tabelle


AIC_WB_IAR_MUX_CTRL <= '0'; -- damit res-gister mit der wb stufe verbunden ist, um zu springen

AIC_WB_IAR_LOAD <= sprung; -- soll passieren, wenn gesprungen wird

--AIC_ID_REGS_USED(0) <=
--AIC_ID_REGS_USED(1) <=
--AIC_ID_REGS_USED(2) <=

AIC_ID_REGS_USED(0) <= '1';	-- Always read first operand via read port A
AIC_ID_REGS_USED(1) <= arith_register or arith_register_register;
AIC_ID_REGS_USED(2) <= arith_register_register;

AIC_DELAY <=	"10" when sprung = '1' else -- steht im text
							"00";

AIC_IF_IAR_INC <= not sprung; -- steht im text

AIC_ARM_NEXT_STATE <=	STATE_WAIT_TO_FETCH when sprung = '1' else --steht im text
											STATE_DECODE;

AIC_WB_W_PORT_A_EN <=	'0' when (opcode = OP_TST or opcode = OP_TEQ or opcode = OP_CMP or opcode = OP_CMN) else -- siehe armtypes, nur bei denen wird nicht in rd geschrieben
											'1';

sprung <= '1' when AIC_INSTRUCTION(15 downto 12) = R15 and not(opcode = OP_TST or opcode = OP_TEQ or opcode = OP_CMP or opcode = OP_CMN) else
					'0';

AIC_WB_PSR_EN <= '1' when AIC_INSTRUCTION(20) = '1' or (opcode = OP_TST or opcode = OP_TEQ or opcode = OP_CMP or opcode = OP_CMN) or (sprung = '1' and AIC_INSTRUCTION(20) = '1') else
								 '0'; -- steht im text, wenn status register geändert wird (conditioncode) oder pc und s bit 1 oder nur s bit 1, dann setzen

AIC_WB_PSR_SET_CC <= '1' when AIC_INSTRUCTION(20) = '1' or (opcode = OP_TST or opcode = OP_TEQ or opcode = OP_CMP or opcode = OP_CMN) else
										 '0'; -- soll 1 sein, wenn s bit oder conditioncode sich ändert

 AIC_WB_PSR_ER <=	'1' when sprung = '1' and AIC_INSTRUCTION(20) = '1' else -- soll nicht gleichzeitig mit den condition code flags gesetzt werden, deshalb sprung 1 und s bit, steht im text
									'0';



end architecture behave;
