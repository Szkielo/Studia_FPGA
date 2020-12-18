library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab5_biletomat is
	port(
		signal service_pin       : inout std_logic; --priority
		signal button_reset      : in 	 std_logic;
		signal button_next_type  : in 	 std_logic;
		signal button_prev_type  : in 	 std_logic;
		signal button_inc_amount : in 	 std_logic;
		signal button_dec_amount : in 	 std_logic;
		signal button_buy        : in 	 std_logic; --next state
		
		-- wszystkie wartosci pieniezne wewnatrz modulu, sa przechowywane jako wartosci 2 razy wieksze, w celu unikniecia ulamkow
		-- zamiana wartosci na prawdziwe jest dokonywana: przez wyswietlacz, przez czytnik, przez automat do wydawania
		
		-- czytnik nominalu
		signal received_money_val_x2   : in  integer range 0 to 1023; -- 50gr liczymy jako 1 itd. sygnal to suma wrzuconych pieniedzy
		
		-- wydawanie reszty
		signal send_money_val_x2       : out integer range 0 to 1023; -- modul wydajacy powinien interpretowac podane wartosci jako 2x mniejsze
		signal send_money_enable		 : out std_logic;
		signal send_money_complete		 : in  std_logic;
		
		-- wyswietlacze
		signal seg1              : out std_logic_vector(6 downto 0); 
		signal seg2              : out std_logic_vector(6 downto 0);
		-- kropka
		signal seg3              : out std_logic_vector(6 downto 0);
		
		-- drukowanie biletu (wysyła rodzaj do drukarki)
		signal print_enable  	 : out  std_logic;
		signal print_complete	 : in  std_logic;
		signal print_type 		 : out integer range 0 to 9; 
		signal print_amount		 : out integer range 1 to 63
	);

end lab5_biletomat;


architecture rtl of lab5_biletomat is
	shared variable current_type    : integer range 	 0 to 9   := 0; -- 0-4 normalne, 5-9 ulgowe, od najkrótszego do najdłuższego
	shared variable current_amount  : integer range 	 1 to 63  := 1;
	shared variable money_sum       : integer range  	 0 to 1023 := 0;
	shared variable money_remaining : integer range -1024 to 1023 := 0;
	shared variable clk_reset_count : integer range 	 0 to 255  := 0;
	shared variable temp            : integer range 	 0 to 1023 := 0;
	
	
	type     		 price_array is array (integer range <>) of integer range 0 to 63;
	shared variable ticket_price    : price_array (0 to 9);
	
	type 		state_type  is (service, wybierz, zaplac, drukowanie, reszta);
	signal 	state           : state_type;

	constant clk_period 		 : time 		 := 700ms;
	signal   clk 				 : std_logic := '1';	
	
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
						 vec <= "0111111";
		end case;
	end procedure;
	
begin
	
	clk <= not clk after clk_period / 2;
	
	process(clk)
	begin
		
		if rising_edge(clk) then
			if service_pin = '1' then
				state <= service;
			end if;
			
			case state is
				when service    =>
					if service_pin = '0' then
						state <= wybierz;
					end if;
					
					-- cyklicznie zmieniaj typ biletu, wyswietlaj cene na 7seg
					if button_next_type = '1' then
						if current_type = 9 then
							current_type := 0;
						else
							current_type := current_type + 1;
						end if;
					end if;
					if button_prev_type = '1' then
						if current_type = 0 then
							current_type := 9;
						else
							current_type := current_type - 1;
						end if;
					end if;
					
					-- zmieniaj cene wybranego obecnie: + -
					if button_inc_amount = '1' then
						if ticket_price(current_type) < 63 then
							ticket_price(current_type) := ticket_price(current_type) + 1;
						end if;
					end if;
					
					if button_dec_amount = '1' then
						if ticket_price(current_type) > 0 then
							ticket_price(current_type) := ticket_price(current_type) - 1;
						end if;
					end if;
					
					temp := (ticket_price(current_type) / 2) /   10;
					IntTo7seg(temp, seg1);
					
					temp := (ticket_price(current_type) / 2) mod 10;
					IntTo7seg(temp, seg2);
					
					temp := (ticket_price(current_type) mod 2);
					if temp = 1 then
						temp := 5;
						IntTo7seg(temp, seg3);
						else
						temp := 0;
						IntTo7seg(temp, seg3);
					end if;
					
				when wybierz    =>
					-- cyklicznie zmieniaj typ biletu
					if button_next_type = '1' then
						clk_reset_count := 0;
						if current_type = 9 then
							current_type := 0;
						else
							current_type := current_type + 1;
						end if;
					end if;
					
					if button_prev_type = '1' then
						clk_reset_count := 0;
						if current_type = 0 then
							current_type := 9;
						else
							current_type := current_type - 1;
						end if;
					end if;
					
					-- zmieniaj pamietana ilosc: + -
					if button_inc_amount = '1' then
						clk_reset_count := 0;
						if current_amount < 63 then
							current_amount := current_amount + 1;
						end if;
					end if;
					
					if button_dec_amount = '1' then
						clk_reset_count := 0;
						if current_amount > 0 then
							current_amount := current_amount - 1;
						end if;
					end if;
					
					-- przejdz w nastepny stan naciskajac kup, oblicz i przekaz calkowita cene na ekran
					if button_buy = '1' then
						clk_reset_count := 0;
						money_sum := ticket_price(current_type) * current_amount;
						state <= zaplac;
					end if;
					
					-- reset
					if button_reset = '1' then
						current_amount := 1;
						current_type   := 0;
					end if;
					
					-- timed reset
					if clk_reset_count > 85 then -- okolo 60s
						clk_reset_count := 0;
						current_amount  := 1;
						current_type    := 0;
					end if;
					
					clk_reset_count := clk_reset_count + 1;
					
					temp := current_amount / 10;
					IntTo7seg(temp, seg1);
					
					temp := current_amount mod 10;
					IntTo7seg(temp, seg2);
				
				when zaplac     =>
					-- reset
					if button_reset = '1' then
						state <= wybierz;
						current_amount := 1;
						current_type   := 0;
						send_money_val_x2 <= received_money_val_x2;
						state <= reszta;
					end if;
					
					if clk_reset_count > 170 then -- okolo 120s
						clk_reset_count := 0;
						current_amount  := 1;
						current_type    := 0;
						send_money_val_x2 <= received_money_val_x2;
						state <= reszta;
					end if;
					
					clk_reset_count := clk_reset_count + 1;
					
					-- przyjmuj pieniadze dopoki suma >= naleznosc
					if received_money_val_x2 >= money_sum then
						clk_reset_count := 0;
						send_money_val_x2 <= received_money_val_x2 - money_sum;
						state <= drukowanie;
					end if;
					
					money_remaining := money_sum - received_money_val_x2;
					
					temp := (money_remaining / 2) /   10;
					IntTo7seg(temp, seg1);
					
					temp := (money_remaining / 2) mod 10;
					IntTo7seg(temp, seg2);
					
					temp := (money_remaining mod 2);
					if temp = 1 then
						temp := 5;
						IntTo7seg(temp, seg3);
					end if;
				
				when drukowanie =>
					if (print_complete = '0') then
					-- send drukuj(rodzaj) x ilosc
						print_type   <= current_type;
						print_amount <= current_amount;
						print_enable <= '1'; -- sygnal rozpoczynajacy drukowanie
					-- czekaj na koniec drukowania, jakikolwiek blad przy drukowaniu zatrzymuje dzialanie automatu
					else
						print_enable <= '0';
						state <= reszta;
					end if;
				when reszta     =>
					send_money_enable <= '1';
					if send_money_complete = '1' then
						send_money_enable <= '0';
						send_money_val_x2 <=  0 ;
						state <= wybierz;
					end if;
			end case;
			
		end if;
	end process;
end rtl;