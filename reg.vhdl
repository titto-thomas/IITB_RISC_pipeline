----------------------------------------
-- Register Module : IITB-RISC
-- Author : Titto Thomas
-- Date : 8/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is

generic (
    nbits : integer);

  port (
    reg_in	: in  std_logic_vector(nbits-1 downto 0);	-- register input
    reg_out	: out std_logic_vector(nbits-1 downto 0);	-- register output
    clock	: in  std_logic;			-- clock signal
    write	: in  std_logic;			-- write enable signal
    reset	: in  std_logic				-- reset signal
    );
end reg;

architecture behave of reg is

begin  -- behave

	process(clock,reset)
	begin 
	  if(rising_edge(clock)) then
	    if(reset = '1') then
	      reg_out <= (others => '0');	-- reset the register
	    elsif write = '1' then
	      reg_out <= reg_in;		-- store the input
	    end if;
	  end if;
	end process;

end behave;
