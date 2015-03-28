--IITB RISC processor---
--Mux Module(2to1)---
-- author: Anakha
library ieee;
use ieee.std_logic_1164.all;
entity mux2to1bit is
  port (
    input0 : in  std_logic;
    input1 : in  std_logic;
    output : out std_logic;
    sel    : in  std_logic);

end mux2to1bit;

architecture behave of mux2to1bit is

begin  -- mux2to1
	process(input0,input1,sel)
	variable sel_var: std_logic;
	begin
	sel_var:= sel;
  	case sel_var is 
	when '0' =>
		output <= input0;
	when '1' =>
		output <= input1;
	when others =>
		output <= 'Z';
  	end case;
	end process;
end behave;
