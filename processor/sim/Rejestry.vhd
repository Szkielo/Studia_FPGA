library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity Rejestry is
port
(
	clk : in std_logic;
	DI  : in signed (15 downto 0);
	BA  : in signed (15 downto 0);
	Sbb : in signed (3 downto 0);
	Sbc : in signed (3 downto 0);
	Sba : in signed (3 downto 0);
	Sid : in signed (2 downto 0);
	Sa  : in signed (1 downto 0);
	BB  : out signed (15 downto 0);
	BC  : out signed (15 downto 0);
	ADR : out signed (15 downto 0);
	IRout : out signed (15 downto 0)
);
end entity;

architecture rtl of Rejestry is
begin
	process (clk, Sbb, Sbc, Sba, Sid, Sa, DI)
		variable IR, TMP, A, B, C, D, E, F: signed (15 downto 0);
		variable AD, PC, SP, ATMP : signed (15 downto 0);
		variable ES, DS, CS : signed (15 downto 0);
	begin
		if (clk'event and clk='1') then
			case Sid is
				when "001" =>
					PC := PC + 1;
				when "010" =>
					SP := SP + 1;
				when "011" =>
					SP := SP - 1;
				when "100" =>
					AD := AD + 1;
				when "101" =>
					AD := AD - 1;
				when others =>
				null;
			end case;
			
			case Sba is
				when "0000" => IR   := BA;
				when "0001" => TMP  := BA;
				when "0010" => A    := BA;
				when "0011" => B    := BA;
				when "0100" => C    := BA;
				when "0101" => D    := BA;
				when "0110" => E    := BA;
				when "0111" => F    := BA;
				when "1000" => AD   := BA;
				when "1001" => PC   := BA;
				when "1010" => SP   := BA;
				when "1011" => ATMP := BA;
				when "1100" => ES   := BA;
				when "1101" => DS   := BA;
				when "1110" => CS   := BA;
				when others => null;
			end case;
		end if;
			case Sbb is
				when "0000" => BB <= DI;
				when "0001" => BB <= TMP; 
				when "0010" => BB <= A;
				when "0011" => BB <= B;
				when "0100" => BB <= C;
				when "0101" => BB <= D;
				when "0110" => BB <= E;
				when "0111" => BB <= F;
				when "1000" => BB <= AD;
				when "1001" => BB <= PC;
				when "1010" => BB <= SP;
				when "1011" => BB <= ATMP;
				when "1100" => BB <= ES;
				when "1101" => BB <= DS;
				when "1110" => BB <= CS;
				when others => null;
			end case;
			
			case Sbc is
				when "0000" => BC <= DI;
				when "0001" => BC <= TMP;
				when "0010" => BC <= A;
				when "0011" => BC <= B;
				when "0100" => BC <= C;
				when "0101" => BC <= D;
				when "0110" => BC <= E;
				when "0111" => BC <= F;
				when "1000" => BC <= AD;
				when "1001" => BC <= PC;
				when "1010" => BC <= SP;
				when "1011" => BC <= ATMP;
				when "1100" => BC <= ES;
				when "1101" => BC <= DS;
				when "1110" => BC <= CS;
				when others => null;
			end case;
			
			case Sa is
				when "00" => ADR <= AD;
				when "01" => ADR <= PC;
				when "10" => ADR <= SP;
				when "11" => ADR <= ATMP;
				when others => null;
			end case;
		IRout <= IR;
	end process;
end rtl;