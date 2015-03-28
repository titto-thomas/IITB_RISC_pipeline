--IITB RISC processor---
--Mux Module(8to1)---
-- author: Anakha
library ieee;
use ieee.std_logic_1164.all;
entity mux8to1 is
  generic (
    nbits : integer);

  port (
    input0, input1, input2, input3, input4, input5, input6, input7 : in  std_logic_vector(nbits-1 downto 0);
    output                                                   	   : out std_logic_vector(nbits-1 downto 0);
    sel0, sel1, sel2                       	                   : in  std_logic);
end mux8to1;

architecture behave  of mux8to1 is
begin  -- behave 
  process(input0,input1,input2,input3,input4,input5,input6,input7,sel0,sel1,sel2)
    variable sel_var : std_logic_vector(2 downto 0);
  begin
      sel_var(0) := sel0;
      sel_var(1) := sel1;
      sel_var(2) := sel2;
      case sel_var is
        when "000" =>
          output <= input0 ;
        when "001" =>
          output <= input1;
        when "010" =>
          output <= input2;
        when "011" =>
          output <= input3;
        when "100" =>
          output <= input4;
        when "101" => 
 	  output <= input5;
	when "110" =>
	  output <= input6;
	when "111" =>
	  output <= input7;
	when others =>
	 output <="Z";
      end case;
  end process;
end behave ;
