----------------------------------------
-- Conditional update of RF Write : IITB-RISC
-- Author : Titto Thomas
-- Date : 18/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CondBlock is
  port (
    OpCode	: in  std_logic_vector(5 downto 0);  	-- Opcode (0-2 and 12-15) bits
    ALU_val	: in std_logic;				-- valid signal from ALU
    Curr_RFWrite : in std_logic;			-- Current value of RF write
    Nxt_RFWrite  : out std_logic			-- Next value for RF write
    );
end CondBlock;

architecture Condition of CondBlock is

begin

	Main : process(OpCode, ALU_val, Curr_RFWrite)
	begin
		if ( (Opcode = b"000010" or Opcode = b"000001" or Opcode = b"001010" or Opcode = b"001001") )then
			Nxt_RFWrite <= ALU_val;
		else
			Nxt_RFWrite <= Curr_RFWrite;
		end if;
	end process Main;

end architecture Condition;
