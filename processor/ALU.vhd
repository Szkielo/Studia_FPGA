library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity ALU is
port ( 
		A     : in signed(15 downto 0);
		B     : in signed(15 downto 0);
		Salu  : in signed (3 downto 0);
		LDF   : in bit;
		clk   : in std_logic;
		Y     : out signed (15 downto 0);
		C,Z,S : out std_logic
);
end entity;

architecture rtl of ALU is
begin
	process (Salu, A, B, clk)
		variable res, AA, BB, CC: signed (16 downto 0);
		variable CF,ZF,SF : std_logic;
	begin
		AA(16) := A(15);
		AA(15 downto 0) := A;
		BB(16) := B(15);
		BB(15 downto 0) := B;
		CC(0) := CF;
		CC(16 downto 1) := "0000000000000000";
		
		case Salu is 
			when "0000" => res := AA; -- MOV
			when "0001" => res := AA + BB; -- ADD
			when "0010" => res := AA - BB; -- SUB
			when "0011" => res := "0000000000000"   & AA(7 downto 4); -- ST4 case0
			when "0100" => res := "0000000000000"   & AA(3 downto 0); -- ST4 case1
			when "0101" => res := "000000000000000" & AA(7 downto 6); -- ST2 case 0
			when "0110" => res := "000000000000000" & AA(5 downto 4); -- ST2 case 1
			when "0111" => res := "000000000000000" & AA(3 downto 2); -- ST2 case 2
			when "1000" => res := "000000000000000" & AA(1 downto 0); -- ST2 case 3
			when "1001" => res := "000000000000000" & AA(7 downto 6); -- L2b case 0
			when "1010" => res := "000000000000000" & AA(5 downto 4); -- L2b case 1
			when "1011" => res := "000000000000000" & AA(3 downto 2); -- L2b case 2
			when "1100" => res := "000000000000000" & AA(1 downto 0); -- L2b case 3
			when "1101" => res := "0000000000000"   & AA(7 downto 4); -- L4b case 0
			when "1110" => res := "0000000000000"   & AA(3 downto 0); -- L4b case 1
			when "1111" => res := AA and BB; -- AND
			when others => null;
			-- BEQ jest wykonywane przy uzyciu SUB i flagi Zero
		end case;
		
		if (clk'event and clk='1') then
			if (LDF='1') then
				if (res = "00000000000000000") then ZF:='1';
				else ZF:='0';
				end if;
			
				if (res(15)='1') then SF:='1';
				else SF:='0';
				end if;
				
				CF := res(16) xor res(15);
			end if;
		end if;
		
		Y <= res(15 downto 0);
		Z <= ZF;
		S <= SF;
		C <= CF;
	end process;
end rtl; 
