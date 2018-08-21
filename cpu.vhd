library IEEE;
use IEEE.std_logic_1164.all;

entity cpu is
	port(clock       : in  std_logic;
	     reset       : in  std_logic;
	     address     : out std_logic_vector(7 downto 0);
	     write       : out std_logic;
	     to_memory   : out std_logic_vector(7 downto 0);
	     from_memory : in  std_logic_vector(7 downto 0));
end entity;

architecture cpu_arch of cpu is

	component control_unit
		port(clock      : in  std_logic;
		     reset      : in  std_logic;
		     write      : out std_logic;
		     IR_Load    : out std_logic;
		     IR         : in  std_logic_vector(7 downto 0);
		     MAR_Load   : out std_logic;
		     PC_Load    : out std_logic;
		     PC_Inc     : out std_logic;
		     A_Load     : out std_logic;
		     B_Load     : out std_logic;
		     ALU_Sel    : out std_logic_vector(3 downto 0);
		     CCR_Result : in  std_logic_vector(3 downto 0);
		     CCR_Load   : out std_logic;
		     Bus2_Sel   : out std_logic_vector(1 downto 0);
		     Bus1_Sel   : out std_logic_vector(1 downto 0));
	end component;

	component data_path
		port(clock       : in  std_logic;
		     reset       : in  std_logic;
		     address     : out std_logic_vector(7 downto 0);
		     to_memory   : out std_logic_vector(7 downto 0);
		     from_memory : in  std_logic_vector(7 downto 0);
		     IR_Load     : in  std_logic;
		     IR          : out std_logic_vector(7 downto 0);
		     MAR_Load    : in  std_logic;
		     PC_Load     : in  std_logic;
		     PC_Inc      : in  std_logic;
		     A_Load      : in  std_logic;
		     B_Load      : in  std_logic;
		     ALU_Sel     : in  std_logic_vector(3 downto 0);
		     CCR_Result  : out std_logic_vector(3 downto 0);
		     CCR_Load    : in  std_logic;
		     Bus2_Sel    : in  std_logic_vector(1 downto 0);
		     Bus1_Sel    : in  std_logic_vector(1 downto 0));
	end component;

	signal IR_Load, MAR_Load, PC_Load, PC_Inc, A_Load, B_Load, CCR_Load : std_logic;
	signal IR                 : std_logic_vector(7 downto 0);
	signal ALU_Sel            : std_logic_vector(3 downto 0);
	signal CCR_Result         : std_logic_vector(3 downto 0);
	signal Bus2_Sel, Bus1_Sel : std_logic_vector(1 downto 0);
begin
	CU : control_unit port map(clock      => clock,
	                           reset      => reset,
	                           write      => write,
	                           IR_Load    => IR_Load,
	                           IR         => IR,
	                           MAR_Load   => MAR_Load,
	                           PC_Load    => PC_Load,
	                           PC_Inc     => PC_Inc,
	                           A_Load     => A_Load,
	                           B_Load     => B_Load,
	                           ALU_Sel    => ALU_Sel,
	                           CCR_Result => CCR_Result,
	                           CCR_Load   => CCR_Load,
	                           Bus2_Sel   => Bus2_Sel,
	                           Bus1_Sel   => Bus1_Sel);

	DP : data_path port map(clock       => clock,
	                        reset       => reset,
	                        address     => address,
	                        to_memory   => to_memory,
	                        from_memory => from_memory,
	                        IR_Load     => IR_Load,
	                        IR          => IR,
	                        MAR_Load    => MAR_Load,
	                        PC_Load     => PC_Load,
	                        PC_Inc      => PC_Inc,
	                        A_Load      => A_Load,
	                        B_Load      => B_Load,
	                        ALU_Sel     => ALU_Sel,
	                        CCR_Result  => CCR_Result,
	                        CCR_Load    => CCR_Load,
	                        Bus2_Sel    => Bus2_Sel,
	                        Bus1_Sel    => Bus1_Sel);
end architecture;