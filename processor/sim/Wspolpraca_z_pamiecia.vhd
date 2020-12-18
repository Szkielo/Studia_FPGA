library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity Wspolpraca_z_pamiecia is
port(
	Smar, Smbr, WRin, RDin : in bit;
		ADR : in signed(15 downto 0);
		DO  : in signed(15 downto 0);
		DI  : out signed(15 downto 0);
		AD  : out signed (15 downto 0);
		D   : inout signed (15 downto 0);
		WR, RD : out std_logic
);
end Wspolpraca_z_pamiecia;

architecture rtl of Wspolpraca_z_pamiecia is
begin
	process(Smar, ADR, Smbr, DO, D, WRin, RDin)
		variable MBRin, MBRout: signed(15 downto 0);
		variable MAR : signed(15 downto 0);
	begin
		if(Smar='1') then MAR := ADR; end if;
		if(Smbr='1') then MBRout := DO; end if;
		if(RDin='1') then MBRin := D; end if;
		
		if (WRin='1') then D <= MBRout;
		else D <= "ZZZZZZZZZZZZZZZZ";
		end if;
	DI <= MBRin;
	AD <= MAR;
	if WRin = '1' then WR <= '1';
	else WR <= '0';
	end if;
	if RDin = '1' then RD <= '1';
	else RD <= '0';
	end if;
	end process;

end rtl;