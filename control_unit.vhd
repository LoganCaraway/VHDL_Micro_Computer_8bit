library IEEE;
use IEEE.std_logic_1164.all;

entity control_unit is
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
end entity;

architecture control_unit_arch of control_unit is
	
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
	
	type State_Type is (S_FETCH_0, S_FETCH_1, S_FETCH_2,
	                    S_DECODE_3,
	                    --LOAD-&-STORE---------------------
	                    S_LDA_IMM_4, S_LDA_IMM_5, S_LDA_IMM_6,
	                    S_LDA_DIR_4, S_LDA_DIR_5, S_LDA_DIR_6, S_LDA_DIR_7, S_LDA_DIR_8,
	                    S_STA_DIR_4, S_STA_DIR_5, S_STA_DIR_6, S_STA_DIR_7,
	                    S_LDB_IMM_4, S_LDB_IMM_5, S_LDB_IMM_6,
	                    S_LDB_DIR_4, S_LDB_DIR_5, S_LDB_DIR_6, S_LDB_DIR_7, S_LDB_DIR_8,
	                    S_STB_DIR_4, S_STB_DIR_5, S_STB_DIR_6, S_STB_DIR_7,
	                    --DATA-MANIPULATIONS---------------
	                    S_ADD_AB_4,
	                    S_SUB_AB_4,
	                    S_AND_AB_4,
	                    S_OR_AB_4,
	                    S_INCA_4,
	                    S_INCB_4,
	                    S_DECA_4,
	                    S_DECB_4,
	                    --BRANCH---------------------------
	                    S_BRA_4, S_BRA_5, S_BRA_6,
	                    S_BMI_4, S_BMI_5, S_BMI_6,S_BMI_7,
	                    S_BEQ_4, S_BEQ_5, S_BEQ_6,S_BEQ_7,
	                    S_BVS_4, S_BVS_5, S_BVS_6,S_BVS_7,
	                    S_BCS_4, S_BCS_5, S_BCS_6,S_BCS_7);
	signal current_state, next_state : State_Type;

begin
---------------------------------------------------------------------
------NEXT STATE LOGIC
---------------------------------------------------------------------
	NEXT_STATE_LOGIC : process(current_state, IR, CCR_Result)
	begin
		if    (current_state=S_FETCH_0) then
			next_state <= S_FETCH_1;
		elsif  (current_state=S_FETCH_1) then
			next_state <= S_FETCH_2;
		elsif (current_state=S_FETCH_2) then
			next_state <= S_DECODE_3;
		elsif (current_state=S_DECODE_3) then
			--LOAD-&-STORE---------------------
			if    (IR=LDA_IMM) then
				next_state <= S_LDA_IMM_4;
			elsif (IR=LDA_DIR) then
				next_state <= S_LDA_DIR_4;
			elsif (IR=STA_DIR) then
				next_state <= S_STA_DIR_4;
			elsif (IR=LDB_IMM) then
				next_state <= S_LDB_IMM_4;
			elsif (IR=LDB_DIR) then
				next_state <= S_LDB_DIR_4;
			elsif (IR=STB_DIR) then
				next_state <= S_STB_DIR_4;
			--DATA-MANIPULATIONS---------------
			elsif (IR=ADD_AB) then
				next_state <= S_ADD_AB_4;
			elsif (IR=SUB_AB) then
				next_state <= S_SUB_AB_4;
			elsif (IR=AND_AB) then
				next_state <= S_AND_AB_4;
			elsif (IR=OR_AB) then
				next_state <= S_OR_AB_4;
			elsif (IR=INCA) then
				next_state <= S_INCA_4;
			elsif (IR=INCB) then
				next_state <= S_INCB_4;
			elsif (IR=DECA) then
				next_state <= S_DECA_4;
			elsif (IR=DECB) then
				next_state <= S_DECB_4;
			--BRANCH---------------------------
			elsif (IR=BRA) then
				next_state <= S_BRA_4;
			elsif (IR=BMI and CCR_Result(3)='1') then
				next_state <= S_BMI_4;
			elsif (IR=BMI and CCR_Result(3)='0') then
				next_state <= S_BMI_7;
			elsif (IR=BEQ and CCR_Result(2)='1') then
				next_state <= S_BEQ_4;
			elsif (IR=BEQ and CCR_Result(2)='0') then
				next_state <= S_BEQ_7;
			elsif (IR=BVS and CCR_Result(1)='1') then
				next_state <= S_BVS_4;
			elsif (IR=BVS and CCR_Result(1)='0') then
				next_state <= S_BVS_7;
			elsif (IR=BCS and CCR_Result(0)='1') then
				next_state <= S_BCS_4;
			elsif (IR=BCS and CCR_Result(0)='0') then
				next_state <= S_BCS_7;
			--Unknown-Opcode-in-IR-------------
			else
				next_state <= S_FETCH_0;
			end if;
----LDA_IMM-----------------------------------------------------
		elsif (current_state=S_LDA_IMM_4) then
			next_state <= S_LDA_IMM_5;
		elsif (current_state=S_LDA_IMM_5) then
			next_state <= S_LDA_IMM_6;
----LDA_DIR-----------------------------------------------------
		elsif (current_state=S_LDA_DIR_4) then
			next_state <= S_LDA_DIR_5;
		elsif (current_state=S_LDA_DIR_5) then
			next_state <= S_LDA_DIR_6;
		elsif (current_state=S_LDA_DIR_6) then
			next_state <= S_LDA_DIR_7;
		elsif (current_state=S_LDA_DIR_7) then
			next_state <= S_LDA_DIR_8;
----STA_DIR-----------------------------------------------------
		elsif (current_state=S_STA_DIR_4) then
			next_state <= S_STA_DIR_5;
		elsif (current_state=S_STA_DIR_5) then
			next_state <= S_STA_DIR_6;
		elsif (current_state=S_STA_DIR_6) then
			next_state <= S_STA_DIR_7;
----LDB_IMM-----------------------------------------------------
		elsif (current_state=S_LDB_IMM_4) then
			next_state <= S_LDB_IMM_5;
		elsif (current_state=S_LDB_IMM_5) then
			next_state <= S_LDB_IMM_6;
----LDB_DIR-----------------------------------------------------
		elsif (current_state=S_LDB_DIR_4) then
			next_state <= S_LDB_DIR_5;
		elsif (current_state=S_LDB_DIR_5) then
			next_state <= S_LDB_DIR_6;
		elsif (current_state=S_LDB_DIR_6) then
			next_state <= S_LDB_DIR_7;
		elsif (current_state=S_LDB_DIR_7) then
			next_state <= S_LDB_DIR_8;
----STB_DIR-----------------------------------------------------
		elsif (current_state=S_STB_DIR_4) then
			next_state <= S_STB_DIR_5;
		elsif (current_state=S_STB_DIR_5) then
			next_state <= S_STB_DIR_6;
		elsif (current_state=S_STB_DIR_6) then
			next_state <= S_STB_DIR_7;
----BRA---------------------------------------------------------
		elsif (current_state=S_BRA_4) then
			next_state <= S_BRA_5;
		elsif (current_state=S_BRA_5) then
			next_state <= S_BRA_6;
----BMI---------------------------------------------------------
		elsif (current_state=S_BMI_4) then
			next_state <= S_BMI_5;
		elsif (current_state=S_BMI_5) then
			next_state <= S_BMI_6;
----BEQ---------------------------------------------------------
		elsif (current_state=S_BEQ_4) then
			next_state <= S_BEQ_5;
		elsif (current_state=S_BEQ_5) then
			next_state <= S_BEQ_6;
----BVS---------------------------------------------------------
		elsif (current_state=S_BVS_4) then
			next_state <= S_BVS_5;
		elsif (current_state=S_BVS_5) then
			next_state <= S_BVS_6;
----BCS---------------------------------------------------------
		elsif (current_state=S_BCS_4) then
			next_state <= S_BCS_5;
		elsif (current_state=S_BCS_5) then
			next_state <= S_BCS_6;
----End of Current Branch: Resetting Back to Initial State------
		else
			next_state <= S_FETCH_0;
		end if;
	end process;

---------------------------------------------------------------------
------STATE MEMORY LOGIC
---------------------------------------------------------------------
	STATE_MEMORY : process(clock, reset)
	begin
		if    (reset='0') then
			current_state <= S_FETCH_0;
		elsif (rising_edge(clock)) then
			current_state <= next_state;
		end if;
	end process;

---------------------------------------------------------------------
------OUTPUT LOGIC
---------------------------------------------------------------------
	OUTPUT_LOGIC : process (current_state)
	begin
		case (current_state) is
			when S_FETCH_0 => --Move PC to MAR to read Opcode
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "00"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "01"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_FETCH_1 => --Increment PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '1';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_FETCH_2 => --Move Opcode from_memory to IR
				write <= '0';
				IR_Load <= '1';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_DECODE_3 => --Machine is decoding IR
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----LDA_IMM----------------------------------------------------------

			when S_LDA_IMM_4 => --Move PC to MAR to read Operand
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "00"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "01"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_LDA_IMM_5 => --Increment PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '1';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_LDA_IMM_6 => --Move Operand from_memory to Register A
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '1';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----LDA_DIR----------------------------------------------------------

			when S_LDA_DIR_4 => --Move PC to MAR to read Operand
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "00"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "01"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_LDA_DIR_5 => --Increment PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '1';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_LDA_DIR_6 => --Move Operand from_memory to MAR
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_LDA_DIR_7 => --Empty State: memory needs time to respond
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_LDA_DIR_8 => --Move Data from_memory to Register A
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '1';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----STA_DIR----------------------------------------------------------

			when S_STA_DIR_4 =>  --Move PC to MAR to read Operand
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "00"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "01"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_STA_DIR_5 => --Increment PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '1';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_STA_DIR_6 =>  --Move Operand from_memory to MAR
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_STA_DIR_7 => --Store A at given address in memory
				write <= '1';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "01"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----LDB_IMM----------------------------------------------------------

			when S_LDB_IMM_4 => --Move PC to MAR to read Operand
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "00"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "01"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_LDB_IMM_5 => --Increment PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '1';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_LDB_IMM_6 => --Move Operand from_memory to Register B
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '1';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----LDB_DIR----------------------------------------------------------

			when S_LDB_DIR_4 => --Move PC to MAR to read Operand
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "00"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "01"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_LDB_DIR_5 => --Increment PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '1';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_LDB_DIR_6 => --Move Operand from_memory to MAR
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_LDB_DIR_7 => --Empty State: memory needs time to respond
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_LDB_DIR_8 => --Move Data from_memory to Register B
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '1';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----STB_DIR----------------------------------------------------------

			when S_STB_DIR_4 =>  --Move PC to MAR to read Operand
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "00"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "01"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_STB_DIR_5 => --Increment PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '1';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_STB_DIR_6 =>  --Move Operand from_memory to MAR
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_STB_DIR_7 => --Store B at given address in memory
				write <= '1';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "10"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----ADD_AB-----------------------------------------------------------

			when S_ADD_AB_4 => --Route Register A into ALU to be added to Register B. Sum is placed into Register A
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '1';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '1';
				Bus1_Sel <= "01"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "00"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----SUB_AB-----------------------------------------------------------

			when S_SUB_AB_4 => --Route Register A into ALU to be subtracted by Register B. Sum is placed into Register A
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '1';
				B_Load <= '0';
				ALU_Sel <= "0001"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '1';
				Bus1_Sel <= "01"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "00"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----AND_AB-----------------------------------------------------------

			when S_AND_AB_4 => --Route Register A into ALU to be added to Register B. Sum is placed into Register A
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '1';
				B_Load <= '0';
				ALU_Sel <= "0010"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '1';
				Bus1_Sel <= "01"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "00"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----OR_AB------------------------------------------------------------

			when S_OR_AB_4 => --Route Register A into ALU to be added to Register B. Sum is placed into Register A
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '1';
				B_Load <= '0';
				ALU_Sel <= "0011"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '1';
				Bus1_Sel <= "01"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "00"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----INCA-------------------------------------------------------------

			when S_INCA_4 => --Route Register A into ALU to be incremented and moved back into Register A
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '1';
				B_Load <= '0';
				ALU_Sel <= "0100"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '1';
				Bus1_Sel <= "01"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "00"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----INCB-------------------------------------------------------------

			when S_INCB_4 => --Tell ALU to increment Register B and store result in Register B
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '1';
				ALU_Sel <= "0101"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '1';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "00"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----DECA-------------------------------------------------------------

			when S_DECA_4 => --Route Register A into ALU to be decremented and moved back into Register A
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '1';
				B_Load <= '0';
				ALU_Sel <= "0110"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '1';
				Bus1_Sel <= "01"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "00"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----DECB-------------------------------------------------------------

			when S_DECB_4 => --Tell ALU to decrement Register B and store result in Register B
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '1';
				ALU_Sel <= "0111"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '1';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "00"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----BRA--------------------------------------------------------------

			when S_BRA_4 => --Move PC to MAR to read Operand
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "00"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "01"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BRA_5 => --Empty State: memory needs time to respond
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BRA_6 => --Move Data from_memory to PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '1';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----BMI--------------------------------------------------------------

			when S_BMI_4 => --Move PC to MAR to read Operand
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "00"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "01"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BMI_5 => --Empty State: memory needs time to respond
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BMI_6 => --Move Data from_memory to PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '1';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BMI_7 => --Increment PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '1';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----BEQ--------------------------------------------------------------

			when S_BEQ_4 => --Move PC to MAR to read Operand
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "00"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "01"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BEQ_5 => --Empty State: memory needs time to respond
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BEQ_6 => --Move Data from_memory to PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '1';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BEQ_7 => --Increment PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '1';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----BVS--------------------------------------------------------------

			when S_BVS_4 => --Move PC to MAR to read Operand
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "00"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "01"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BVS_5 => --Empty State: memory needs time to respond
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BVS_6 => --Move Data from_memory to PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '1';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BVS_7 => --Increment PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '1';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

----BCS--------------------------------------------------------------

			when S_BCS_4 => --Move PC to MAR to read Operand
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '1';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "00"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "01"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BCS_5 => --Empty State: memory needs time to respond
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BCS_6 => --Move Data from_memory to PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '1';
				PC_Inc <= '0';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "10"; --ALU:00, Bus1:01, from_memory:10, x"00":11

			when S_BCS_7 => --Increment PC
				write <= '0';
				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				PC_Inc <= '1';
				A_Load <= '0';
				B_Load <= '0';
				ALU_Sel <= "0000"; --ADD:0000, SUB:0001, AND:0010, OR:0011, INCA:0100, INCB:0101, DECA:0110, DECB:0111
				CCR_Load <= '0';
				Bus1_Sel <= "11"; --PC:00, A:01, B:10, x"00":11
				Bus2_Sel <= "11"; --ALU:00, Bus1:01, from_memory:10, x"00":11
		end case;
	end process;
end architecture;
