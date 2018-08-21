library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rom_128x8_sync is
	port(clock    : in  std_logic;
	     address  : in  std_logic_vector(7 downto 0);
	     data_out : out std_logic_vector(7 downto 0));
end entity;

architecture rom_128x8_sync_arch of rom_128x8_sync is

	--Constants for Instructions
	constant LDA_IMM : std_logic_vector(7 downto 0) := x"86"; --Load Register A with Immediate Addressing
	constant LDA_DIR : std_logic_vector(7 downto 0) := x"87"; --Load Register A with Direct Addressing
	constant LDB_IMM : std_logic_vector(7 downto 0) := x"88"; --Load Register B with Immediate Addressing
	constant LDB_DIR : std_logic_vector(7 downto 0) := x"89"; --Load Register B with Direct Addressing
	constant STA_DIR : std_logic_vector(7 downto 0) := x"96"; --Store Register A to Memory with Direct Addressing
	constant STB_DIR : std_logic_vector(7 downto 0) := x"97"; --Store Register B to Memory with Direct Addressing
	
	constant ADD_AB  : std_logic_vector(7 downto 0) := x"42"; --A <= A + B (plus)
	constant SUB_AB  : std_logic_vector(7 downto 0) := x"43"; --A <= A - B (minus)
	constant AND_AB  : std_logic_vector(7 downto 0) := x"44"; --A <= A * B (AND)
	constant OR_AB   : std_logic_vector(7 downto 0) := x"45"; --A <= A + B (OR)
	constant INCA    : std_logic_vector(7 downto 0) := x"46"; --A <= A + 1
	constant INCB    : std_logic_vector(7 downto 0) := x"47"; --B <= B + 1
	constant DECA    : std_logic_vector(7 downto 0) := x"48"; --A <= A - 1
	constant DECB    : std_logic_vector(7 downto 0) := x"49"; --B <= B - 1

	constant BRA     : std_logic_vector(7 downto 0) := x"20"; --Branch Always
	constant BMI     : std_logic_vector(7 downto 0) := x"21"; --Branch to Address provided if N=1
	constant BEQ     : std_logic_vector(7 downto 0) := x"23"; --Branch to Address provided if Z=1
	constant BVS     : std_logic_vector(7 downto 0) := x"25"; --Branch to Address provided if V=1
	constant BCS     : std_logic_vector(7 downto 0) := x"27"; --Branch to Address provided if C=1
	
	type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);
	constant ROM : rom_type := (
			0      => LDA_DIR,
			1      => x"F0",
			2      => STA_DIR,
			3      => x"E0",
			4      => BRA,
			5      => x"00",
			others => x"00");
			
	signal EN : std_logic;

begin

	ENABLE : process(address)
	begin
		if ((to_integer(unsigned(address)) >= 0) and
		    (to_integer(unsigned(address)) <= 127)) then
			EN <= '1';
		else
			EN <= '0';
		end if;
	end process;


	ROM_MEMORY : process(clock)
	begin
		if(rising_edge(clock)) then
			if (EN='1') then
				data_out <= ROM(to_integer(unsigned(address)));
			end if;
		end if;
	end process;
end architecture;
