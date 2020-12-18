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
		fetch_2,
		fetch_3,
		fetch_4,
		
		mov_0,
		mov_1,
		mov_2,
		mov_3,
		mov_4,
		mov_5,
		mov_6,
		
		add_0,
		add_1,
		add_2,
		add_3,
		add_4,
		add_5,
		add_6,
		
		sub_0,
		sub_1,
		sub_2,
		sub_3,
		sub_4,
		sub_5,
		sub_6,
		
		st4_case0_0,
		st4_case0_1,
		st4_case0_2,
		st4_case0_3,
		st4_case0_4,
		st4_case0_5,
		
		st4_case1_0,
		st4_case1_1,
		st4_case1_2,
		st4_case1_3,
		st4_case1_4,
		st4_case1_5,
		
		st2_case0_0,
		st2_case0_1,
		st2_case0_2,
		st2_case0_3,
		st2_case0_4,
		st2_case0_5,
		
		st2_case1_0,
		st2_case1_1,
		st2_case1_2,
		st2_case1_3,
		st2_case1_4,
		st2_case1_5,
		
		st2_case2_0,
		st2_case2_1,
		st2_case2_2,
		st2_case2_3,
		st2_case2_4,
		st2_case2_5,
		
		st2_case3_0,
		st2_case3_1,
		st2_case3_2,
		st2_case3_3,
		st2_case3_4,
		st2_case3_5,
		
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
		beq_jump_2,
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
			when fetch_1 => state <= fetch_2;
			when fetch_2 => state <= fetch_3;
			when fetch_3 => state <= fetch_4;
			---------- Dekodowanie ----------
			when fetch_4 =>
				case IR(15 downto 12) is
					when "0000" => -- MOV
						if IR = "0000000000000000" then state <= fetch_0;
						else state <= mov_0;
						end if;
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
			when mov_3 => state <= mov_4;
			when mov_4 => state <= mov_5;
			when mov_5 => state <= mov_6;
			when mov_6 => state <= fetch_0;
			
			when add_0 => state <= add_1;
			when add_1 => state <= add_2;
			when add_2 => state <= add_3;
			when add_3 => state <= add_4;
			when add_4 => state <= add_5;
			when add_5 => state <= add_6;
			when add_6 => state <= fetch_0;
			
			when sub_0 => state <= sub_1;
			when sub_1 => state <= sub_2;
			when sub_2 => state <= sub_3;
			when sub_3 => state <= sub_4;
			when sub_4 => state <= sub_5;
			when sub_5 => state <= sub_6;
			when sub_6 => state <= fetch_0;
			
			when st4_case0_0 => state <= st4_case0_1;
			when st4_case0_1 => state <= st4_case0_2;
			when st4_case0_2 => state <= st4_case0_3;
			when st4_case0_3 => state <= st4_case0_4;
			when st4_case0_4 => state <= st4_case0_5;
			when st4_case0_5 => state <= fetch_0;
			
			when st4_case1_0 => state <= st4_case1_1;
			when st4_case1_1 => state <= st4_case1_2;
			when st4_case1_2 => state <= st4_case1_3;
			when st4_case1_3 => state <= st4_case1_4;
			when st4_case1_4 => state <= st4_case1_5;
			when st4_case1_5 => state <= fetch_0;
			
			when st2_case0_0 => state <= st2_case0_1;
			when st2_case0_1 => state <= st2_case0_2;
			when st2_case0_2 => state <= st2_case0_3;
			when st2_case0_3 => state <= st2_case0_4;
			when st2_case0_4 => state <= st2_case0_5;
			when st2_case0_5 => state <= fetch_0;
			
			when st2_case1_0 => state <= st2_case1_1;
			when st2_case1_1 => state <= st2_case1_2;
			when st2_case1_2 => state <= st2_case1_3;
			when st2_case1_3 => state <= st2_case1_4;
			when st2_case1_4 => state <= st2_case1_5;
			when st2_case1_5 => state <= fetch_0;
			
			when st2_case2_0 => state <= st2_case2_1;
			when st2_case2_1 => state <= st2_case2_2;
			when st2_case2_2 => state <= st2_case2_3;
			when st2_case2_3 => state <= st2_case2_4;
			when st2_case2_4 => state <= st2_case2_5;
			when st2_case2_5 => state <= fetch_0;
			
			when st2_case3_0 => state <= st2_case3_1;
			when st2_case3_1 => state <= st2_case3_2;
			when st2_case3_2 => state <= st2_case3_3;
			when st2_case3_3 => state <= st2_case3_4;
			when st2_case3_4 => state <= st2_case3_5;
			when st2_case3_5 => state <= fetch_0;
			
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
			when beq_jump_1 => state <= beq_jump_2;
			when beq_jump_2 => state <= fetch_0;
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
			
		when fetch_1 => -- oczekiwanie na aktualizację
			Sa <= "01"; Sbb <= "0000"; Sba <= "0000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';	
		
		when fetch_2 => -- oczekiwanie na aktualizację
			Sa <= "01"; Sbb <= "0000"; Sba <= "0000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';	
		
		when fetch_3 => -- zapis do rejestru IR
			Sa <= "01"; Sbb <= "0000"; Sba <= "0000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when fetch_4 => -- oczekiwanie na aktualizację, inkrementacja PC
			Sa <= "01"; Sbb <= "0000"; Sba <= "0000"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		-------------------------------------------------------------------------
		
		when mov_0 => -- pobranie adresu arg2 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when mov_1 => -- oczekiwanie na aktualizację
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when mov_2 => -- zapis do rejestru AD
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when mov_3 => -- oczekiwanie na aktualizacje, , inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when mov_4 => -- odczytanie wartosci arg2 z pamieci
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when mov_5 => -- oczekiwanie na aktualizację
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when mov_6 => -- wpisanie wartosci na DI do podanego rejestru
			Sa <= "00"; Sbb <= "0000"; Sba <= IR(11 downto 8); Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='1'; INTA <='0';
		-------------------------------------------------------------------------	
		
		when add_0 => -- pobranie adresu arg2 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when add_1 => -- oczekiwanie na aktualizacje
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when add_2 => -- zapis do rejestru AD
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when add_3 => -- oczzekiwanie na aktualizacje inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when add_4 => -- odczytanie wartosci arg2 z pamieci
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when add_5 => -- oczzekiwanie na aktualizacje
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when add_6 => -- dodawanie zawartości rejestru IR(11 downto 8) z DI
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= IR(11 downto 8); Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0001"; LDF <='1'; INTA <='0';
		-------------------------------------------------------------------------	
		
		when sub_0 => -- pobranie adresu arg2 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when sub_1 => -- pobranie adresu arg2 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when sub_2 => -- zapis do rejestru AD
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when sub_3 => -- update, inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when sub_4 => -- odczytanie wartosci arg2 z pamieci
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when sub_5 => -- update
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when sub_6 => -- odejmowanie zawartości rejestru IR(11 downto 8) z DI
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= IR(11 downto 8); Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0010"; LDF <='1'; INTA <='0';
		
		-------------------------------------------------------------------------
		
		when st4_case0_0 => -- pobranie adresu arg1 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st4_case0_1 => 
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st4_case0_2 => -- zapis do rejestru AD
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when st4_case0_3 => --  inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st4_case0_4 => -- wykonanie operacji i podanie do modułu pamięci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0011"; LDF <='0'; INTA <='0';
		
		when st4_case0_5 => -- zapis do pamieci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <= IR(11 downto 8); MIO <='1';
			Smar <='0'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="0011"; LDF <='0'; INTA <='0';
			
		
		
		when st4_case1_0 => -- pobranie adresu arg1 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when st4_case1_1 => 
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st4_case1_2 => -- zapis do rejestru AD
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when st4_case1_3 => -- inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1111"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st4_case1_4 => -- wykonanie operacji i podanie do modułu pamięci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0100"; LDF <='0'; INTA <='0';
		
		when st4_case1_5 => -- zapis do pamieci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="0100"; LDF <='0'; INTA <='0';
			-------------------------------------------------------------------------
		
		
		when st2_case0_0 => -- pobranie adresu arg1 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when st2_case0_1 => 
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case0_2 => -- zapis do rejestru AD
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when st2_case0_3 => -- inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case0_4 => -- wykonanie operacji i podanie do modułu pamięci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0101"; LDF <='0'; INTA <='0';
		
		when st2_case0_5 => -- zapis do pamieci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="0101"; LDF <='0'; INTA <='0';
			
		
		
		when st2_case1_0 => -- pobranie adresu arg1 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when st2_case1_1 => 
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case1_2 => -- zapis do rejestru AD
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when st2_case1_3 => -- inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case1_4 => -- wykonanie operacji i podanie do modułu pamięci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0110"; LDF <='0'; INTA <='0';
		
		when st2_case1_5 => -- zapis do pamieci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="0110"; LDF <='0'; INTA <='0';
			
		
		
		when st2_case2_0 => -- pobranie adresu arg1 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when st2_case2_1 => 
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case2_2 => -- zapis do rejestru AD
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when st2_case2_3 => -- inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case2_4 => -- wykonanie operacji i podanie do modułu pamięci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0111"; LDF <='0'; INTA <='0';
		
		when st2_case2_5 => -- zapis do pamieci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="0111"; LDF <='0'; INTA <='0';
			
		
		when st2_case3_0 => -- pobranie adresu arg1 z pamieci
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when st2_case3_1 => 
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case3_2 => -- zapis do rejestru AD
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when st2_case3_3 => -- inkrementacja PC
			Sa <= "00"; Sbb <= "0000"; Sba <= "1000"; Sid <="001"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
		
		when st2_case3_4 => -- wykonanie operacji i podanie do modułu pamięci
			Sa <= "00"; Sbb <= IR(11 downto 8); Sba <= "1111"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="1000"; LDF <='0'; INTA <='0';
		
		when st2_case3_5 => -- zapis do pamieci
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
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0010"; LDF <='1'; INTA <='0';
		
		when beq_jump_0 => -- wczytuje wskazany adres na DI
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when beq_jump_1 => -- update
			Sa <= "01"; Sbb <= "0000"; Sba <= "1000"; Sid <="000"; Sbc <="0000"; MIO <='1';
			Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			
		when beq_jump_2 => -- zapisuje do PC
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