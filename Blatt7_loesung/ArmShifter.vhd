--------------------------------------------------------------------------------
--	Shifter des HWPR-Prozessors, instanziiert einen Barrelshifter.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmTypes.all;

entity ArmShifter is
	port (
		SHIFT_OPERAND	: in	std_logic_vector(31 downto 0);
		SHIFT_AMOUNT	 : in	std_logic_vector(7 downto 0);
		SHIFT_TYPE_IN	: in	std_logic_vector(1 downto 0);
		SHIFT_C_IN		  : in	std_logic;
		SHIFT_RXX		   : in	std_logic;
		SHIFT_RESULT	 : out	std_logic_vector(31 downto 0);
		SHIFT_C_OUT		 : out	std_logic    		
 	);
end entity ArmShifter;

architecture behave of ArmShifter is
  
  -- Verwendete Komponenten aus anderen Dateien
  
  component ArmBarrelShifter is
    generic ( OPERAND_WIDTH : integer := 4;
              SHIFTER_DEPTH : integer := 2 --ceil(log(2, OPERAND_WIDTH))
     );
    port ( 	  OPERAND 	   : in std_logic_vector(OPERAND_WIDTH-1 downto 0);	
              MUX_CTRL 	  : in std_logic_vector(1 downto 0);
              AMOUNT 		   : in std_logic_vector(SHIFTER_DEPTH-1 downto 0);	
              ARITH_SHIFT : in std_logic; 
              C_IN 		     : in std_logic;
              DATA_OUT 	  : out std_logic_vector(OPERAND_WIDTH-1 downto 0);	
              C_OUT 		    : out std_logic
    );
  end component ArmBarrelShifter;
  
  
  -- SIGNALS
  
  signal  mux_ctrl_map  : std_logic_vector(1 downto 0); -- wird benötigt, da ARM-Shifter andere Steuercodes verwendet
  signal  bshifter_out  : std_logic_vector(31 downto 0); -- Output des BarrelShifters
  signal  c_out_bshifter: std_logic; -- C_OUT des BShifters
  signal  arith_shift_in: std_logic; -- ist 1 wenn SHIFT_TYPE_IN = ASR ist
  
  signal  rxx_out       : std_logic_vector(32 downto 0);

begin
  
  -- Instanziierung der BarrelShifter Komponente
  BSHIFT: ArmBarrelShifter
	generic map(
			         OPERAND_WIDTH => 32,
			         SHIFTER_DEPTH => 5
	)
	port map(
			         OPERAND		   => SHIFT_OPERAND,
			         MUX_CTRL	   => mux_ctrl_map,
			         AMOUNT		    => SHIFT_AMOUNT(4 downto 0), -- erledigt glaube ich alle SHIFT_AMOUNT mod 32
			         ARITH_SHIFT	=> arith_shift_in,
			         C_IN		      => SHIFT_C_IN, -- ???
			         DATA_OUT	   => bshifter_out,
			         C_OUT		     => c_out_bshifter
	); 
	
	-- setzen des Arith Bit wenn es benötigt wird
  arith_shift_in  <=  '1' when SHIFT_TYPE_IN = SH_ASR else
                      '0';
  
  -- MUX_CTRL auf ARMShifter anpassen
  mux_ctrl_map    <=  "00" when (unsigned(SHIFT_AMOUNT) = 0) else -- kein shift bei SHIFT_AMOUNT = 0
                      "01" when (SHIFT_TYPE_IN = SH_LSL) else -- Linksshift
                      "10" when ((SHIFT_TYPE_IN = SH_LSR) or (SHIFT_TYPE_IN = SH_ASR)) else -- Rechtsshift bei LSR und ASR. Bei ASR wird arith_shift_in gesetzt
                      "11";
                      
  --------------------------------------------------------------------------------------------------
  -- Abstraktions Wrapper für alle Fälle, welcher der instantiierte BarrelShifter nicht übernimmt :                   
  --------------------------------------------------------------------------------------------------
  
  
  rxx_out   <=  SHIFT_C_IN & SHIFT_OPERAND;
  
  
  --------------------------------------
  -- Ausgaben des ARMShifters zuweisen
  --------------------------------------
  
  -- MUX um richtigen Wert auf Ausgang des ARMShifters zu mappen                                
  SHIFT_RESULT	   <=  -- wenn Amount im Größenbereich ist, welcher der BSHifter ausführen kann und RXX = 0
                      bshifter_out      when ((unsigned(SHIFT_AMOUNT) < 32) and (SHIFT_RXX = '0')) else
                      
                      -- Logik Shifts um 32 Stellen oder mehr erzeugen nur 0en
                      (others => '0')   when (((SHIFT_TYPE_IN = SH_LSL) or (SHIFT_TYPE_IN = SH_LSR)) and (unsigned(SHIFT_AMOUNT) >= 32)) else
                      
                      -- Arith Shift um mehr als 32 Stellen liefert MSB des Operanten an allen Stellen am Ausgang 
                      (others => SHIFT_OPERAND(31)) when ((SHIFT_TYPE_IN = SH_ASR) and (unsigned(SHIFT_AMOUNT) >= 32)) else
                      
                      -- Wenn ROR dann dann wiederkehrende Ergebnisse, deshalb BSHIFTER Ergebnis
                      bshifter_out  when ((unsigned(SHIFT_AMOUNT) > 31) and (SHIFT_TYPE_IN = SH_ROR)) else
                      
                      -- RXX Fall
                      rxx_out(32 downto 1) when (SHIFT_RXX = '1') else
                      
                      --dummy 0? oder 'X'? oder umbauen?
                      (others => '0');
                      
                
                      
  
  -- MUX um richtiges Wert auf SHIFT_C_OUT des ARMShifters zu mappen
  SHIFT_C_OUT		   <=  -- C_OUT aus BarrelShifter verwenden
                      c_out_bshifter  when ((unsigned(SHIFT_AMOUNT) < 32) and (SHIFT_RXX = '0')) else
                      
                      -- LogikShifts um mehr als 32 Stellen erzeugen 0 als C_OUT
                      '0'  when (((SHIFT_TYPE_IN = SH_LSL) or (SHIFT_TYPE_IN = SH_LSR)) and (unsigned(SHIFT_AMOUNT) > 32)) else 
                      
                      -- (I.) Arith Shift um mehr als 32 Stellen führt dazu, dass C_OUT = MSB des Operanten wird
                      SHIFT_OPERAND(31) when ((SHIFT_TYPE_IN = SH_ASR) and (unsigned(SHIFT_AMOUNT) > 32)) else
                                            
                      -- OPTIMIERUNG AUS I. und II. ???
                      --SHIFT_OPERAND(31) when (((SHIFT_TYPE_IN = SH_ASR) or (SHIFT_TYPE_IN = SH_LSR)) and (unsigned(SHIFT_AMOUNT) >= 32)) else
                    
                    
                      -- Beim Linksshift um genau 32 Stellen wird C_OUT das LSB des SHIFT_OPERAND
                      SHIFT_OPERAND(0) when ((SHIFT_TYPE_IN = SH_LSL) and (unsigned(SHIFT_AMOUNT) = 32)) else

                      -- (II.) Bei Rechtsshifts um genau 32 Stellen wird C_OUT das MSB des SHIFT_OPERAND
                      SHIFT_OPERAND(31) when (((SHIFT_TYPE_IN = SH_LSR) or (SHIFT_TYPE_IN = SH_ASR)) and (unsigned(SHIFT_AMOUNT) = 32)) else
                      
                      -- bei ROR und AMOUNT > 31 liefert der BSHIFTER wiederkehrende Ergebnisse
                      c_out_bshifter when ((unsigned(SHIFT_AMOUNT) > 31) and ((unsigned(SHIFT_AMOUNT) mod 32) /= 0) and (SHIFT_TYPE_IN = SH_ROR)) else
                      
                      -- bei ROR und AMOUNT > 31 und n= 32*k wird C_OUT mit MSB überschrieben
                      SHIFT_OPERAND(31) when ((unsigned(SHIFT_AMOUNT) > 31) and ((unsigned(SHIFT_AMOUNT) mod 32) = 0) and (SHIFT_TYPE_IN = SH_ROR)) else
                      
                      -- RXX Fall: SHIFT_TYPE_IN und SHIFT_AMOUNT werden ignoriert 
                      rxx_out(0) when (SHIFT_RXX = '1') else

                      --dummy 0? oder 'X'? oder umbauen?
                      '0';
                      
end architecture behave;

