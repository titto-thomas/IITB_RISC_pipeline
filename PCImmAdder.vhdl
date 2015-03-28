----------------------------------------
-- INCR : IITB-RISC
-- Author : Sainath
-- Date : 18/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PCImmAdd is
  port (
    	input1 : in  std_logic_vector(15 downto 0);		-- 16 std_logic input
	input2 : in  std_logic_vector(15 downto 0);
    	output : out  std_logic_vector(15 downto 0)		-- 16 std_logic output
	);
end PCImmAdd;
--------------------------------Architecture-----------------------------------------------


architecture code of PCImmAdd is

begin  -- behave 
	output <= std_logic_vector(unsigned(input1) + unsigned(input2));
end code;

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
