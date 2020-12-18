library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity Jednostka_sterujaca is
port
(
	clk : in std_logic;
	IR  : in signed(15 downto 0);
	reset, C, Z, S, INT : in std_logic;
	Salu : out signed(3 downto 0);
	Sbb, Sbc, Sba : out signed(3 downto 0);
	Sid : out signed(2 downto 0); 
	Sa  : out signed(1 downto 0);
	LDF, Smar, Smbr, WR, RD, INTA, MIO : out bit
);
end Jednostka_sterujaca;

architecture rtl of Jednostka_sterujaca is
	type state_type is (
		reset_state,
		fetch_0,
		fetch_1,
		
		mov_0,
		mov_1,
		mov_2,
		mov_3,
		
		add_0,
		add_1,
		add_2,
		add_3,
		
		sub_0,
		sub_1,
		sub_2,
		sub_3,
		
		st4_case0_0,
		st4_case0_1,
		st4_case0_2,
		st4_case0_3,
		
		st4_case1_0,
		st4_case1_1,
		st4_case1_2,
		st4_case1_3,
		
		st2_case0_0,
		st2_case0_1,
		st2_case0_2,
		st2_case0_3,
		
		st2_case1_0,
		st2_case1_1,
		st2_case1_2,
		st2_case1_3,
		
		st2_case2_0,
		st2_case2_1,
		st2_case2_2,
		st2_case2_3,
		
		st2_case3_0,
		st2_case3_1,
		st2_case3_2,
		st2_case3_3,
		
		l2b_case0,
		l2b_case1,
		l2b_case2,
		l2b_case3,
		
		l4b_case0,
		l4b_case1,
		
		s_and,
		
		beq_start,
		beq_jump_0,
		beq_jump_1,
		beq_nojump
	);
	signal state : state_type;

begin

process (clk, reset)
begin
	if reset = '1' then
		state <= reset_state;
	elsif (clk'event and clk='1') then
		case state is
			when reset_state => state <= fetch_0;
			when fetch_0 => state <= fetch_1;
			---------- Dekodowanie ----------
			When fetch_1 =>
				case IR(15 downto 12) is
					when "0000" => -- MOV
						state <= mov_0;
					when "0001" => -- ADD
						state <= add_0;
					when "0010" => -- SUB
						state <= sub_0;
					when "0011" => -- ST4s
						case IR(11 downto 10) is
							when "00" => state <= st4_case0_0;
							when "01" => state <= st4_case0_1;
							when others => state <= fetch_0;
						end case;
					when "0100" => -- ST2s
						case IR(11 downto 10) is
							when "00" => state <= st2_case0_0;
							when "01" => state <= st2_case1_0;
							when "10" => state <= st2_case2_0;
							when "11" => state <= st2_case3_0;
							when others => state <= fetch_0;
						end case;
					when "0101" => -- L2b
						case IR(11 downto 10) is
							when "00" => state <= l2b_case0;
							when "01" => state <= l2b_case1;
							when "10" => state <= l2b_case2;
							when "11" => state <= l2b_case3;
							when others => state <= fetch_0;
						end case;
					when "0110" => -- L4b
						case IR(11 downto 10) is
							when "00" => state <= l4b_case0;
							when "01" => state <= l4b_case1;
							when others => state <= fetch_0;
						end case;
					when "0111" => -- AND
						state <= s_and;
					when "1000" => -- BEQ
						state <= beq_start;
					when others => state <= fetch_0;
				end case;
			--------- Kolejne stany rozkazow ----------
			when mov_0 => state <= mov_1;
			when mov_1 => state <= mov_2;
			when mov_2 => state <= mov_3;
			when mov_3 => state <= fetch_0;
			
			when add_0 => state <= add_1;
			when add_1 => state <= add_2;
			when add_2 => state <= add_3;
			when add_3 => state <= fetch_0;
			
			when sub_0 => state <= sub_1;
			when sub_1 => state <= sub_2;
			when sub_2 => state <= sub_3;
			when sub_3 => state <= fetch_0;
			
			when st4_case0_0 => state <= st4_case0_1;
			when st4_case0_1 => state <= st4_case0_2;
			when st4_case0_2 => state <= st4_case0_3;
			when st4_case0_3 => state <= fetch_0;
			
			when st4_case1_0 => state <= st4_case1_1;
			when st4_case1_1 => state <= st4_case1_2;
			when st4_case1_2 => state <= st4_case1_3;
			when st4_case1_3 => state <= fetch_0;
			
			when st2_case0_0 => state <= st2_case0_1;
			when st2_case0_1 => state <= st2_case0_2;
			when st2_case0_2 => state <= st2_case0_3;
			when st2_case0_3 => state <= fetch_0;
			
			when st2_case1_0 => state <= st2_case1_1;
			when st2_case1_1 => state <= st2_case1_2;
			when st2_case1_2 => state <= st2_case1_3;
			when st2_case1_3 => state <= fetch_0;
			
			when st2_case2_0 => state <= st2_case2_1;
			when st2_case2_1 => state <= st2_case2_2;
			when st2_case2_2 => state <= st2_case2_3;
			when st2_case2_3 => state <= fetch_0;
			
			when st2_case3_0 => state <= st2_case3_1;
			when st2_case3_1 => state <= st2_case3_2;
			when st2_case3_2 => state <= st2_case3_3;
			when st2_case3_3 => state <= fetch_0;
			
			when l2b_case0 => state <= fetch_0;
			
			when l2b_case1 => state <= fetch_0;
			
			when l2b_case2 => state <= fetch_0;
			
			when l2b_case3 => state <= fetch_0;
			
			
			when l4b_case0 => state <= fetch_0;
			
			when l4b_case1 => state <= fetch_0;
			
			when s_and => state <= fetch_0;
			
			when beq_start =>
				if Z = '1' then
					state <= beq_jump_0;
				else
					state <= beq_nojump;
				end if;
			
			when beq_jump_0 => state <= beq_jump_1;
			when beq_jump_1 => state <= fetch_0;
			when beq_nojump => state <= fetch_0;
			
			when others => state <= fetch_0;
		end case;
	end if;
end process;

process (state) 
begin
	case state is
		when reset_state =>
			Sa <= "00"; Sbb <= "0000"; Sba <= "0000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when fetch_0 => -- pobranie instrukcji z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "0000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when fetch_1 => -- zapis do rejestru IR, inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "0000"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		-------------------------------------------------------------------------
		
		when mov_0 => -- pobranie adresu arg2 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when mov_1 => -- zapis do rejestru AD, inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when mov_2 => -- odczytanie wartosci arg2 z pamieci
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when mov_3 => -- wpisanie wartosci na DI do podanego rejestru
			Sa <= "00"; Sbb <= "0000"; Sba <= IR(11 downto 8); Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		-------------------------------------------------------------------------	
		
		when add_0 => -- pobranie adresu arg2 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when add_1 => -- zapis do rejestru AD, inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when add_2 => -- odczytanie wartosci arg2 z pamieci
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when add_3 => -- dodawanie zawartości rejestru IR(11 downto 8) z DI
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= IR(11 downto 8); Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0001"; LDF <='0'; INTA <='0';
		-------------------------------------------------------------------------	
		
		when sub_0 => -- pobranie adresu arg2 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when sub_1 => -- zapis do rejestru AD, inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when sub_2 => -- odczytanie wartosci arg2 z pamieci
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when sub_3 => -- odejmowanie zawartości rejestru IR(11 downto 8) z DI
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= IR(11 downto 8); Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0010"; LDF <='0'; INTA <='0';
		
		-------------------------------------------------------------------------
		
		when st4_case0_0 => -- pobranie adresu arg1 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st4_case0_1 => -- zapis do rejestru AD, inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st4_case0_2 => -- wykonanie operacji i podanie do modułu pamięci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0011"; LDF <='0'; INTA <='0';
		
		when st4_case0_3 => -- zapis do pamieci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <= IR(11 downto 8); MIO <='1';
			Smar <='0'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="0011"; LDF <='0'; INTA <='0';
			
		
		
		when st4_case1_0 => -- pobranie adresu arg1 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st4_case1_1 => -- zapis do rejestru AD, inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st4_case1_2 => -- wykonanie operacji i podanie do modułu pamięci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0100"; LDF <='0'; INTA <='0';
		
		when st4_case1_3 => -- zapis do pamieci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="0100"; LDF <='0'; INTA <='0';
			-------------------------------------------------------------------------
		
		
		when st2_case0_0 => -- pobranie adresu arg1 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case0_1 => -- zapis do rejestru AD, inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case0_2 => -- wykonanie operacji i podanie do modułu pamięci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0101"; LDF <='0'; INTA <='0';
		
		when st2_case0_3 => -- zapis do pamieci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="0101"; LDF <='0'; INTA <='0';
			
		
		
		when st2_case1_0 => -- pobranie adresu arg1 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case1_1 => -- zapis do rejestru AD, inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case1_2 => -- wykonanie operacji i podanie do modułu pamięci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0110"; LDF <='0'; INTA <='0';
		
		when st2_case1_3 => -- zapis do pamieci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="0110"; LDF <='0'; INTA <='0';
			
		
		
		when st2_case2_0 => -- pobranie adresu arg1 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case2_1 => -- zapis do rejestru AD, inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case2_2 => -- wykonanie operacji i podanie do modułu pamięci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0111"; LDF <='0'; INTA <='0';
		
		when st2_case2_3 => -- zapis do pamieci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="0111"; LDF <='0'; INTA <='0';
			
		
		when st2_case3_0 => -- pobranie adresu arg1 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case3_1 => -- zapis do rejestru AD, inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case3_2 => -- wykonanie operacji i podanie do modułu pamięci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="1000"; LDF <='0'; INTA <='0';
		
		when st2_case3_3 => -- zapis do pamieci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="1000"; LDF <='0'; INTA <='0';
			
			-------------------------------------------------------------------------
		
		when l2b_case0 => -- wykonanie operacji
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= IR(11 downto 8); Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="1001"; LDF <='0'; INTA <='0';
			
		when l2b_case1 => -- wykonanie operacji
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= IR(11 downto 8); Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="1010"; LDF <='0'; INTA <='0';
			
		when l2b_case2 => -- wykonanie operacji
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= IR(11 downto 8); Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="1011"; LDF <='0'; INTA <='0';
			
		when l2b_case3 => -- wykonanie operacji
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= IR(11 downto 8); Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="1100"; LDF <='0'; INTA <='0';
			
			-------------------------------------------------------------------------
		when l4b_case0 => -- wykonanie operacji
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= IR(11 downto 8); Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="1101"; LDF <='0'; INTA <='0';
			
		when l4b_case1 => -- wykonanie operacji
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= IR(11 downto 8); Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="1110"; LDF <='0'; INTA <='0';
			
			-------------------------------------------------------------------------
		when s_and => -- wykonanie operacji na rejestrach
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= IR(11 downto 8); Sid <="001"; Sbc <=IR(3 downto 0); MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="1111"; LDF <='0'; INTA <='0';
			
		-------------------------------------------------------------------------
		when beq_start =>
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <=IR(3 downto 0); MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0010"; LDF <='0'; INTA <='0';
		
		when beq_jump_0 => -- wczytuje wskazany adres na DI
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		when beq_jump_1 => -- zapisuje do PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1001"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when beq_nojump => -- inkrementuje PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "0000"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when others =>
			Sa <= "00"; Sbb <= "0000"; Sba <= "0000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
	end case;
end process;
end rtl; 