----------------------------------------
-- INCR : IITB-RISC
-- Author : Sainath
-- Date : 18/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity incr is
  port (
    	input : in  std_logic_vector(15 downto 0);		-- 16 std_logic input
    	output : out  std_logic_vector(15 downto 0)		-- 16 std_logic output
	);
end incr;
--------------------------------Architecture-----------------------------------------------


architecture code of incr is

begin  -- behave 
	output <= std_logic_vector(unsigned(input) + X"0001");
end code;

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
