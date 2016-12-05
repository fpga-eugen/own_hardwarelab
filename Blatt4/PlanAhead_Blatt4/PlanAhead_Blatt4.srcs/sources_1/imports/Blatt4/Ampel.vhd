--------------------------------------------------------------------------------
-- 	Fiktive Steuerung einer Ampel zur Einfuehrung von Zustandsautomaten
--	im Hardwarepraktikum.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Ampel is
	port(
		CLK 	: in std_logic;
		RST 	: in std_logic;
		E_AKTIV : in std_logic;
		A_ROT 	: out std_logic;
		A_GELB 	: out std_logic;
		A_GRUEN : out std_logic
	    );
end entity Ampel;

architecture behave of Ampel is
--------------------------------------------------------------------------------
--	Zustaende der Ampel als neuer Typ ohne festgelegte Codierung.
--	AMPEL_STATE speichert den aktuellen Zustand der Ampel und wird
--	in einem sequenziellen Prozess gesetzt. AMPEL_NEXT_STATE ist der
--	Zustand, den die Ampel mit der naechsten steigenden Taktflanke
--	annimmt.
--------------------------------------------------------------------------------
type AMPEL_STATE_TYPE is (S_ROT,S_GELB,S_GRUEN,S_GELBROT,S_AUS);
signal AMPEL_STATE 	: AMPEL_STATE_TYPE := S_ROT;
signal AMPEL_NEXT_STATE : AMPEL_STATE_TYPE := S_ROT;

begin

	A_ROT <= '1' when AMPEL_STATE = S_ROT or AMPEL_STATE = S_GELBROT else '0';
	A_GELB <= '1' when AMPEL_STATE = S_GELB or AMPEL_STATE = S_GELBROT else '0';
	A_GRUEN <= '1' when AMPEL_STATE = S_GRUEN else  '0';


	state_reg : process(CLK) is
	begin

		if (rising_edge(CLK))	then
			AMPEL_STATE <= AMPEL_NEXT_STATE;
		end if;

	end process state_reg;

	set_output_and_next_state : process(AMPEL_STATE, RST, E_AKTIV) is
	begin

		if(RST = '1') then AMPEL_NEXT_STATE <= S_ROT;

		else

			if AMPEL_STATE = S_ROT and E_AKTIV = '1' then AMPEL_NEXT_STATE <= S_GELBROT;

		  elsif AMPEL_STATE = S_ROT and E_AKTIV = '0' then AMPEL_NEXT_STATE <= S_AUS;
			end if;

			if AMPEL_STATE = S_GELBROT then AMPEL_NEXT_STATE <= S_GRUEN;
			end if;

			if AMPEL_STATE = S_GRUEN then AMPEL_NEXT_STATE <= S_GELB;
			end if;

			if AMPEL_STATE = S_GELB and E_AKTIV = '1' then AMPEL_NEXT_STATE <= S_ROT;

		  elsif AMPEL_STATE = S_GELB and E_AKTIV = '0' then AMPEL_NEXT_STATE <= S_AUS;
			end if;

			if AMPEL_STATE = S_AUS then AMPEL_NEXT_STATE <= S_GELB;
			end if;

		end if;

	end process set_output_and_next_state;




-- synthesis translate_off
--------------------------------------------------------------------------------
--	Typen, Signale und Konstanten fuer einen automatischen Test auf
--	korrekte Uebergaenge zwischen Zustaenden des Automaten auf Basis eines
--	Referenzmodells in Form einer Adjazenzmatrix.
--------------------------------------------------------------------------------
--	TRANSMISSION_CONDITION definiert die vier Moeglichkeiten fuer
--	Transitionen zwischen zwei Zustaenden, die in der Adjazenzmatrix
--	verwendet werden koennen:
--		X:	Transition existiert nicht
--		-:	Transition wird unbedingt durchlaufen
--		0:	Transition wird durchlaufen, wenn Eingang E = 0
--		1:	Transition wird durchlaufen, wenn Eingang E = 1
--------------------------------------------------------------------------------
assertion_test : block is
	type TRANSITION_CONDITION_TYPE is ('0','1','-','X');
	type A_MATRIX_TYPE is array(S_ROT to S_AUS, S_ROT to S_AUS) of TRANSITION_CONDITION_TYPE;
        constant A_MATRIX : A_MATRIX_TYPE :=
       --ROT,GELB,GRUEN,GELBROT,AUS
	(('X','X','X','1','0'),		--ROT
	 ('1','X','X','X','0'),		--GELB
	 ('X','-','X','X','X'),		--GRUEN
	 ('X','X','-','X','X'),		--GELBROT
	 ('X','-','X','X','X'));	--AUS
	signal LAST_STATE : AMPEL_STATE_TYPE := S_ROT;
begin

--------------------------------------------------------------------------------
--	Automatischer Test auf korrekte Zustandsuebergange durch
--	Betrachtung des aktuellen und des vorherigen Zustandes und den Wert von
--	E_AKTIV. Es wird nur erkannt, ob eine aufgetretene Transition korrekt
--	war. Fehlende Transitionen werden nicht unmittelbar erkannt!
---------------------------------------------------------------------------------

	check_transitions : PROCESS(AMPEL_STATE)IS
		variable TC : TRANSITION_CONDITION_TYPE;
	begin
---------------------------------------------------------------------------------
--	Fehler zum Initialisierungszeitpunkt der Simulation ignorieren.
---------------------------------------------------------------------------------
		if NOW > 0 ps then
---------------------------------------------------------------------------------
--	Falls in der Simulation RST "gleichzeitig" mit dem Taktsignal
--	gesetzt, aber vom Automaten synchron ausgewertet wird, versetzt es ihn
--	nicht sofort nach S_ROT (moegliche Race Condition).
---------------------------------------------------------------------------------
			if RST = '1' then
				if ((RST'last_event /= CLK'last_event) or CLK = '0') then
---------------------------------------------------------------------------------
--	Assertion: Reset versetzt den Automat in den Startzustand S_ROT,
--	ob synchron oder asynchron ist nicht spezifiziert.
---------------------------------------------------------------------------------
					assert (AMPEL_STATE) = S_ROT report "Reset versetzt Automat nicht nach S_ROT" severity error;
				else
---------------------------------------------------------------------------------
--	Moegliche Race Condition zwischen Takt und Reset, ein fehlender
--	Uebergang nach S_ROT kann trotz korrekter Beschreibung auftreten.
--	Daher: kein Test.
---------------------------------------------------------------------------------
					null;
				end if;
			else
				TC := A_MATRIX(LAST_STATE,AMPEL_STATE);
				if TC = 'X' then
					report "Unerwarteter Zustandsuebergang von " & AMPEL_STATE_TYPE'image(LAST_STATE) & " nach " & AMPEL_STATE_TYPE'image(AMPEL_STATE) severity error;
				elsif TC = '-' then
					null;
				elsif TC = '0' then
					if E_AKTIV = '1' then
						report "Zustandsuebergang von  " & AMPEL_STATE_TYPE'image(LAST_STATE) & " nach " & AMPEL_STATE_TYPE'image(AMPEL_STATE) & " mit falscher Bedingung E_AKTIV = 1" severity error;
					end if;
				else
					if E_AKTIV = '0' then
						report "Zustandsuebergang von  " & AMPEL_STATE_TYPE'image(LAST_STATE) & " nach " & AMPEL_STATE_TYPE'image(AMPEL_STATE) & " mit falscher Bedingung E_AKTIV = 0" severity error;
					end if;
				end if;
			end if;
		end if;

		LAST_STATE <= AMPEL_STATE;
	end process check_transitions;
end block assertion_test;
-- synthesis translate_on
--------------------------------------------------------------------------------

end architecture behave;
