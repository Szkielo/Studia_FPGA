library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Projekt_8 is
port( writedata: in std_logic_vector(31 downto 0);
      clk_clk, reset_reset_n:   in std_logic;
      wr, cs, rd :  in std_logic;
	  readdata: out std_logic_vector(31 downto 0);
      hex0_out: out std_logic_vector(6 downto 0);
	  hex1_out: out std_logic_vector(6 downto 0);
	  led_out:  out std_logic);
end Projekt_8;

architecture rtl of Projekt_8 is
	signal error_state: std_logic;
	signal slider_state: std_logic_vector(1 downto 0);
	signal pb_state: std_logic_vector(2 downto 0);
	signal bezplatne_start: std_logic_vector(4 downto 0);
	signal bezplatne_koniec: std_logic_vector(4 downto 0);
	signal wysokosc_znizek: std_logic_vector(5 downto 0);
	signal hex1: std_logic_vector(6 downto 0);
	signal hex2: std_logic_vector(6 downto 0);
	shared variable opcja_bezplatne: std_logic := '0';
	shared variable temp : integer range 0 to 1023 := 0;
	shared variable temp1 : integer range 0 to 1023 := 0;
	shared variable temp2 : integer range 0 to 1023 := 0;
	shared variable err_flag: std_logic := '0';
	
	procedure IntTo7seg(variable int : in integer; signal vec : out std_logic_vector) is
	begin
		case int is
			when 0 => vec <= "0000001";   
			when 1 => vec <= "1001111";
			when 2 => vec <= "0010010";  
			when 3 => vec <= "0000110"; 
			when 4 => vec <= "1001100";
			when 5 => vec <= "0100100";
			when 6 => vec <= "0100000";
			when 7 => vec <= "0001111";
			when 8 => vec <= "0000000";     
			when 9 => vec <= "0000100";
			when others => 
						 vec <= "0110000";
		end case;
	end procedure;
-- example in: 0 10 000 00000 00000 000000 ||| 0100000000000000000000
begin
	process(clk_clk)
	begin
		if (clk_clk'event and clk_clk='1') then			
			if(wr='1' and cs='1') then
				error_state      <= writedata(21);
				slider_state     <= writedata(20 downto 19);
				pb_state         <= writedata(18 downto 16);
				bezplatne_start  <= writedata(15 downto 11);
				bezplatne_koniec <= writedata(10 downto 6);
				wysokosc_znizek  <= writedata(5 downto 0);
			end if;
			
			if (slider_state = 1) then
				if (pb_state = 1) then
					wysokosc_znizek <= wysokosc_znizek - '1';
				end if;
				if (pb_state = 2) then
					wysokosc_znizek <= wysokosc_znizek + '1';
				end if;
			temp := to_integer(unsigned(wysokosc_znizek));
			end if;

			if (slider_state = 2) then
				if (opcja_bezplatne = '0') then
					if (pb_state = 1) then
						bezplatne_start <= bezplatne_start - '1';
					end if;
					if (pb_state = 2) then
						bezplatne_start <= bezplatne_start + '1';
					end if;
					if (pb_state = 4) then
						opcja_bezplatne := '1';
					end if;
				temp:= to_integer(unsigned(bezplatne_start));
					if (bezplatne_start > 24) then
						err_flag := '1';
					else
						err_flag := '0';
					end if;
				end if;
				if(opcja_bezplatne = '1') then
					if (pb_state = 1) then
						bezplatne_koniec <= bezplatne_koniec - '1';
					end if;
					if (pb_state = 2) then
						bezplatne_koniec <= bezplatne_koniec + '1';
					end if;
					if (pb_state = 3) then
						opcja_bezplatne := '0';
					end if;
					if (bezplatne_start > 24) then
						err_flag := '1';
					else
						err_flag := '0';
					end if;
				temp:= to_integer(unsigned(bezplatne_koniec));
				end if;
			end if;
			
			temp2 := temp mod 10;
			temp1 := (temp / 10) mod 10;
			IntTo7seg(temp1, hex1);
			IntTo7seg(temp2, hex2);
			
			hex0_out <= hex2;
			hex1_out <= hex1;
			led_out <= err_flag;
			
			if(rd = '1' and cs = '1') then
				readdata (15 downto 11) <= bezplatne_start;
				readdata (10 downto 6)  <= bezplatne_koniec;
				readdata (5 downto 0)   <= wysokosc_znizek;
			end if;
		end if;
	end process;
	
end rtl;