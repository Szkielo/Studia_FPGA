library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab4_zegar is
port (
	reset : in     std_logic; -- przyciski
	set   : in     std_logic;

	H1		: inout  integer := 0;
	H2		: inout  integer := 0;
	M1		: inout  integer := 0;
	M2		: inout  integer := 0;
	S1		: inout  integer := 0;
	S2		: inout  integer := 0; 
	
	seg1 : out std_logic_vector (6 downto 0);
	seg2 : out std_logic_vector (6 downto 0);
	seg3 : out std_logic_vector (6 downto 0);
	seg4 : out std_logic_vector (6 downto 0);
	seg5 : out std_logic_vector (6 downto 0);
	seg6 : out std_logic_vector (6 downto 0) );
	
end entity;

architecture sim of lab4_zegar is
	constant clk_period : time := 1000ms;
	
	signal clk : std_logic := '1';
	
	procedure IncrementReset(signal   counter   : inout integer; 
	                         constant resetVal  : in    integer;
									 constant carry     : in    boolean; -- dzieki carry i isReset pozbywamy sie kaskadowych if
									 variable isReset   : out   boolean) is
		begin
			if carry = true then
				if counter = resetVal then
					isReset := true;
					counter <= 0;
				else
					isReset := false;
					counter <= counter + 1;
				end if;
			end if;
	end procedure;
	
	procedure IntTo7seg(signal int : in integer; signal vec : out std_logic_vector) is
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
						 vec <= "0111111";
		end case;
	end procedure;

begin
	
	clk <= not clk after clk_period / 2;
	
	process(clk) is
		variable isReset : boolean;
	begin
		if rising_edge(clk) then
			if reset = '1' then
				H1 <= 0;
				H2 <= 0;
				M1 <= 0;
				M2 <= 0;
				S1 <= 0;
				S2 <= 0;
			
			elsif set = '1' then
				H1 <= 1;
				H2 <= 6;
				M1 <= 2;
				M2 <= 0;
				S1 <= 0;
				S2 <= 0;
			
			else
				IncrementReset(S2, 9, true   , isReset);
				IncrementReset(S1, 5, isReset, isReset);
				IncrementReset(M2, 9, isReset, isReset);
				IncrementReset(M1, 5, isReset, isReset);
				
				if (H1 = 2) then
					IncrementReset(H2, 3, isReset, isReset);
				else
					IncrementReset(H2, 9, isReset, isReset);
				end if;
				
				IncrementReset(H1,  2, isReset, isReset);
			end if;
		end if;
	end process;
	
	process(H1) is
		begin
			IntTo7seg(H1, seg1);
	end process;
	
	process(H2) is
		begin
			IntTo7seg(H2, seg2);
	end process;
	
	process(M1) is
		begin
			IntTo7seg(M1, seg3);
	end process;
		
	process(M2) is
		begin
			IntTo7seg(M2, seg4);
	end process;
	
	process(S1) is
		begin
			IntTo7seg(S1, seg5);
	end process;
	
	process(S2) is
		begin
			IntTo7seg(S2, seg6);
	end process;
	
end architecture;