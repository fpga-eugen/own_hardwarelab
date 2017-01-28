------------------------------------------------------------------------------
--	Paket fuer die Funktionen zur die Abbildung von ARM-Registeradressen
-- 	auf Adressen des physischen Registerspeichers (5-Bit-Adressen)
------------------------------------------------------------------------------
--	Datum:		05.11.2013
--	Version:	0.1
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ArmTypes.all;

package ArmRegaddressTranslation is

	function get_internal_address(
		EXT_ADDRESS: std_logic_vector(3 downto 0);
		THIS_MODE: std_logic_vector(4 downto 0);
		USER_BIT : std_logic
    )
	return std_logic_vector;

end package ArmRegaddressTranslation;

package body ArmRegAddressTranslation is

function get_internal_address(
	EXT_ADDRESS: std_logic_vector(3 downto 0);
	THIS_MODE: std_logic_vector(4 downto 0);
	USER_BIT : std_logic)
	return std_logic_vector
is


variable return_address: std_logic_vector (4 downto 0);
--------------------------------------------------------------------------------
--	Raum fuer lokale Variablen innerhalb der Funktion
--------------------------------------------------------------------------------
	begin

    if (USER_BIT = '1') then
    return_address := std_logic_vector(to_unsigned(to_integer(unsigned(EXT_ADDRESS)), 5)); --unsigned(std_logic) -> std_logic wird zu unsigned

    else
      if (THIS_MODE = "10001") then -- fiq
        return_address := std_logic_vector(to_unsigned(to_integer(unsigned(EXT_ADDRESS)+8), 5));
      elsif (THIS_MODE = "10011") then -- irq
        return_address := std_logic_vector(to_unsigned(to_integer(unsigned(EXT_ADDRESS)+10), 5));--(unsigned(EXT_ADDRESS + 10));
      elsif (THIS_MODE = "10111") then -- supervisor
        return_address := std_logic_vector(to_unsigned(to_integer(unsigned(EXT_ADDRESS)+12), 5));--(unsigned(EXT_ADDRESS + 12));
      elsif (THIS_MODE = "10111") then -- abort
        return_address := std_logic_vector(to_unsigned(to_integer(unsigned(EXT_ADDRESS)+14), 5));--(unsigned(EXT_ADDRESS + 14));
      elsif (THIS_MODE = "11011") then -- undefined
        return_address := std_logic_vector(to_unsigned(to_integer(unsigned(EXT_ADDRESS)+16), 5));--(unsigned(EXT_ADDRESS + 16));
      else
          return_address := std_logic_vector(to_unsigned(to_integer(unsigned(EXT_ADDRESS)), 5));--(unsigned(EXT_ADDRESS));
      end if;
    end if;

	return return_address;

end function get_internal_address;

end package body ArmRegAddressTranslation;
