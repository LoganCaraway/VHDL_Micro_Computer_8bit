library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
	port(A          : in  std_logic_vector(7 downto 0);
	     B          : in  std_logic_vector(7 downto 0);
	     ALU_Sel    : in  std_logic_vector(3 downto 0);
	     ALU_Result : out std_logic_vector(7 downto 0);
	     NZVC       : out std_logic_vector(3 downto 0));
end entity;

architecture alu_arch of alu is



begin
	ALU_PROCESS : process(A, B, ALU_Sel)
	
		variable Sum_uns : unsigned(8 downto 0);

	begin
		if (ALU_Sel="0000") then --ADDITION------------------------------------
			Sum_uns :=  unsigned('0' & A) + unsigned('0' & B);
			ALU_Result <=  std_logic_vector(Sum_uns(7 downto 0));
			
			--Negative Flag (N)
			NZVC(3) <=  Sum_uns(7);
			
			--Zero Flag (Z)
			if (Sum_uns(7 downto 0)=x"00") then
				NZVC(2) <=  '1';
			else
				NZVC(2) <=  '0';
			end if;
			
			--Overflow Flag (V)
			if ((A(7)='0' and B(7)='0' and Sum_uns(7)='1') or
			    (A(7)='1' and B(7)='1' and Sum_uns(7)='0')) then
				NZVC(1) <=  '1';
			else
				NZVC(1) <=  '0';
			end if;
			
			--Carry Flag (C)
			NZVC(0) <=  Sum_uns(8);

		elsif (ALU_Sel="0001") then --SUBTRACTION------------------------------
			Sum_uns :=  unsigned('0' & B) + (unsigned('0' & (not A)) + 1);
			ALU_Result <=  std_logic_vector(Sum_uns(7 downto 0));
			
			--Negative Flag (N)
			NZVC(3) <=  Sum_uns(7);
			
			--Zero Flag (Z)
			if (Sum_uns(7 downto 0)=x"00") then
				NZVC(2) <=  '1';
			else
				NZVC(2) <=  '0';
			end if;
			
			--Overflow Flag (V)
			if ((B(7)='0' and A(7)='1' and Sum_uns(7)='1') or
			    (B(7)='1' and A(7)='0' and Sum_uns(7)='0')) then
				NZVC(1) <=  '1';
			else
				NZVC(1) <=  '0';
			end if;
			
			--Carry Flag (C)
			NZVC(0) <=  Sum_uns(8);

		elsif (ALU_Sel="0010") then --AND-----------------------------------------
			Sum_uns :=  unsigned('0' & A) and unsigned('0' & B);
			ALU_Result <=  std_logic_vector(Sum_uns(7 downto 0));
			
			--Negative Flag (N)
			NZVC(3) <=  Sum_uns(7);
			
			--Zero Flag (Z)
			if (Sum_uns(7 downto 0)=x"00") then
				NZVC(2) <=  '1';
			else
				NZVC(2) <=  '0';
			end if;
			
			--Overflow Flag (V)
			NZVC(1) <=  '0';
			
			--Carry Flag (C)
			NZVC(0) <=  '0';

		elsif (ALU_Sel="0011") then --OR------------------------------------------
			Sum_uns :=  unsigned('0' & A) or unsigned('0' & B);
			ALU_Result <=  std_logic_vector(Sum_uns(7 downto 0));
			
			--Negative Flag (N)
			NZVC(3) <=  Sum_uns(7);
			
			--Zero Flag (Z)
			if (Sum_uns(7 downto 0)=x"00") then
				NZVC(2) <=  '1';
			else
				NZVC(2) <=  '0';
			end if;
			
			--Overflow Flag (V)
			NZVC(1) <=  '0';
			
			--Carry Flag (C)
			NZVC(0) <=  '0';

		elsif (ALU_Sel="0100") then --Increment Register A---------------------
			Sum_uns :=  unsigned('0' & B) + 1;
			ALU_Result <=  std_logic_vector(Sum_uns(7 downto 0));
			
			--Negative Flag (N)
			NZVC(3) <=  Sum_uns(7);
			
			--Zero Flag (Z)
			if (Sum_uns(7 downto 0)=x"00") then
				NZVC(2) <=  '1';
			else
				NZVC(2) <=  '0';
			end if;
			
			--Overflow Flag (V)
			if (B(7)='0' and Sum_uns(7)='1') then
				NZVC(1) <=  '1';
			else
				NZVC(1) <=  '0';
			end if;
			
			--Carry Flag (C)
			NZVC(0) <=  Sum_uns(8);
		elsif (ALU_Sel="0101") then --Increment Register B---------------------
			Sum_uns :=  unsigned('0' & A) + 1;
			ALU_Result <=  std_logic_vector(Sum_uns(7 downto 0));
			
			--Negative Flag (N)
			NZVC(3) <=  Sum_uns(7);
			
			--Zero Flag (Z)
			if (Sum_uns(7 downto 0)=x"00") then
				NZVC(2) <=  '1';
			else
				NZVC(2) <=  '0';
			end if;
			
			--Overflow Flag (V)
			if (A(7)='0' and Sum_uns(7)='1') then
				NZVC(1) <=  '1';
			else
				NZVC(1) <=  '0';
			end if;
			
			--Carry Flag (C)
			NZVC(0) <=  Sum_uns(8);
		elsif (ALU_Sel="0110") then --Decrement Register A---------------------
			Sum_uns :=  unsigned('0' & B) - 1;
			ALU_Result <=  std_logic_vector(Sum_uns(7 downto 0));
			
			--Negative Flag (N)
			NZVC(3) <=  Sum_uns(7);
			
			--Zero Flag (Z)
			if (Sum_uns(7 downto 0)=x"00") then
				NZVC(2) <=  '1';
			else
				NZVC(2) <=  '0';
			end if;
			
			--Overflow Flag (V)
			if (B(7)='1' and Sum_uns(7)='0') then
				NZVC(1) <=  '1';
			else
				NZVC(1) <=  '0';
			end if;
			
			--Carry Flag (C)
			NZVC(0) <=  Sum_uns(8);
		elsif (ALU_Sel="0111") then --Decrement Register B---------------------
			Sum_uns :=  unsigned('0' & A) - 1;
			ALU_Result <=  std_logic_vector(Sum_uns(7 downto 0));
			
			--Negative Flag (N)
			NZVC(3) <=  Sum_uns(7);
			
			--Zero Flag (Z)
			if (Sum_uns(7 downto 0)=x"00") then
				NZVC(2) <=  '1';
			else
				NZVC(2) <=  '0';
			end if;
			
			--Overflow Flag (V)
			if (A(7)='1' and Sum_uns(7)='0') then
				NZVC(1) <=  '1';
			else
				NZVC(1) <=  '0';
			end if;
			
			--Carry Flag (C)
			NZVC(0) <=  Sum_uns(8);
		--OTHER ARITHMETIC & LOGIC TO BE IMPLEMENTED AS NEEDED
		end if;
	end process;
end architecture;