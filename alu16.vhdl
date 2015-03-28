----------------------------------------
-- ALU : IITB-RISC
-- Author : Sainath
-- Date : 18/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu16 is
  port (
    	operand1 : in  std_logic_vector(15 downto 0);		-- 16 std_logic input1
    	operand2 : in  std_logic_vector(15 downto 0);		-- 16 std_logic input2
	op_code	 : in  std_logic;				-- 1 std_logic opcode
    	result   : out std_logic_vector(15 downto 0);		-- 16 std_logic ALU result
	carry 	 : out std_logic;				-- carry flag
	zero 	 : out std_logic;				-- zero flag
	alu_equ	 : out std_logic				-- comparator output
	);
end alu16;
--------------------------------Architecture-----------------------------------------------


architecture code of alu16 is

 signal result_dummy : std_logic_vector(16 downto 0) := X"0000" & '0';

begin  -- behave 

          result <= result_dummy(15 downto 0);
	  carry <= result_dummy(16);
	  ALU : process (operand1, operand2, op_code)
	  begin
		
		----------	OPCODE for ADDITION operation ---------------------		
			if(op_code='0') then
				result_dummy <= std_logic_vector(unsigned('0' & operand1) + unsigned('0' & operand2));
	
		----------	OPCODE for NAND operation ---------------------
			elsif(op_code='1') then
				for i in 0 to 15 loop
					result_dummy(i) <= operand1(i) nand operand2(i);
				end loop;
				result_dummy(16) <= '0';
			end if;

		--------------------------------------------------------------------
	end process ALU;

	Equality_Check : process(operand1, operand2)
	begin
		if( operand1 = operand2 ) then				-- to set comparator output
			alu_equ <= '1';
		else
			alu_equ <= '0';
		end if;
	end process Equality_Check;
	
	Zero_Check : process(result_dummy, op_code)
	begin
		if( result_dummy(15 downto 0) = X"0000" and op_code = '0' ) then				-- to set comparator output
			zero <= '1';
		else
			zero <= '0';
		end if;
	end process Zero_Check;
end code;

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
