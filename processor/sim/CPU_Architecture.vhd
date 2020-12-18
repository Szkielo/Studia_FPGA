library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity CPU_Architecture is port(
	clock : in std_logic;
	reset_button : in std_logic
);
end CPU_Architecture;


architecture join of CPU_Architecture is

	component ALU is port
	(
		A     : in signed(15 downto 0);
		B     : in signed(15 downto 0);
		Salu  : in signed (3 downto 0);
		LDF   : in bit;
		clk   : in std_logic;
		Y     : out signed (15 downto 0);
		C,Z,S : out std_logic
	);
	end component;
	
	component Rejestry is port
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
	end component;
	
	component Jednostka_sterujaca is port
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
	end component;
	
	component Wspolpraca_z_pamiecia is port(
		Smar, Smbr, WRin, RDin : in bit;
		ADR : in signed(15 downto 0);
		DO  : in signed(15 downto 0);
		DI  : out signed(15 downto 0);
		AD  : out signed (15 downto 0);
		D   : inout signed (15 downto 0);
		WR, RD : out std_logic
	);
	end component;
	
	component RAM1PORT is port
	(
		address	: IN signed (15 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN signed (15 DOWNTO 0);
		rden		: IN STD_LOGIC;
		wren		: IN STD_LOGIC;
		q			: OUT signed (15 DOWNTO 0)
	);
	end component;
	
	signal LDF, Smar, Smbr, WRin, RDin, INTA, MIO :  bit;
	signal IR, IRout : signed(15 downto 0);
	signal C, Z, S, P, INT : std_logic;
	signal Sbb, Sbc, Sba : signed(3 downto 0);
	signal Salu : signed(3 downto 0);
	signal Sid : signed(2 downto 0);
	signal Sa : signed(1 downto 0);
	signal AD, ADR, DI, DO, D : signed (15 downto 0);
	signal A, B, Y, BA, BB, BC : signed (15 downto 0);
	signal WR, RD, WR0, RD0 : std_logic;


begin
	alu_1: ALU port map(
		A    => BB,
		B    => BC,
		Salu => Salu,
		LDF  => LDF,
		clk  => clock,
		Y    => BA,
		C	  => C,
		Z    => Z,
		S    => S
	);
	
	reg_1: Rejestry port map(
	
		clk   => clock,
		DI    => DI,
		BA    => BA,
		Sbb   => Sbb,
		Sbc   => Sbc,
		Sba   => Sba,
		Sid   => Sid,
		Sa    => Sa,
		BB    => BB,
		BC    => BC,
		ADR   => ADR,
		IRout => IR
	);
	
	ctrl_1: Jednostka_sterujaca port map(
	
		clk   => clock,
		IR	   => IR,
		reset	=> reset_button,
		C	   => C,
		Z	   => Z,
		S	   => S,
		INT	=> INT,
		Salu	=> Salu,
		Sbb	=> Sbb,
		Sbc	=> Sbc,
		Sba	=> Sba,
		Sid	=> Sid,
		Sa	   => Sa,
		LDF	=> LDF,
		Smar	=> Smar,
		Smbr  => Smbr,
		WR		=> WRin,
		RD		=> RDin,
		INTA	=> INTA,
		MIO	=> MIO
	);
	
	mem_1: Wspolpraca_z_pamiecia port map(
	
		Smar	=> Smar,
		Smbr	=> Smbr,
		WRin	=> WRin,
		RDin	=> RDin,
		ADR	=> ADR,
		DO 	=> BA,
		DI 	=> DI,
		AD 	=> AD,
		D  	=> D,
		WR 	=> WR0,
		RD		=> RD0
	);
	
	ram_1:RAM1PORT port map(
	
		address		=> AD,
		clock		=> clock,
		data		=> D,
		rden		=> RD,
		wren		=> WR,
		q 			=> D
	);
end join;