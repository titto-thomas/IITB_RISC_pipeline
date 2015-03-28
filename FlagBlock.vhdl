----------------------------------------
-- Flag Block Module : IITB-RISC
-- Author : Titto Thomas
-- Date : 18/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FlagBlock is
  port (
    clock	: in std_logic;		-- clock signal
    reset	: in std_logic;		-- reset signal
    ALUc	: in std_logic;		-- conditional carry flag change
    ALUz	: in std_logic;		-- conditional zero flag change
    Cen		: in std_logic;		-- enable carry flag change
    Zen		: in std_logic;		-- enable zero flag change
    ALUop	: in std_logic;		-- unconditional ALU operation
    ALUcout	: in std_logic;		-- the carry out from ALU
    ALUzout	: in std_logic;		-- the zero out from ALU
    ALUvalid	: out std_logic;	-- whether the ALU output is valid or not
    FR		: out std_logic_vector(1 downto 0)	-- Flag register
    );
end FlagBlock;

architecture behave of FlagBlock is
signal carry, zero : std_logic;
begin  -- behave

	ALUvalid <= ((carry and ALUc) or (zero and ALUz) or (ALUop));
	FR(0) <= carry;
	FR(1) <= zero;

	process(clock,reset)
	begin 
	  if(rising_edge(clock)) then
	    if (reset = '1') then
	      carry <= '0';	-- reset the register
	      zero <= '0';
	    else
		if (Cen = '1') then
			carry <= ALUcout;	-- Update the carry register
		end if;
	      	if (Zen = '1') then
			zero <= ALUzout;	-- Update the zero register
		end if;	
	    end if;
	  end if;
	end process;

end behave;
