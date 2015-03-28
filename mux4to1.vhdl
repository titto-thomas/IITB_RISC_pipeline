--IITB RISC processor---
--Mux Module(4to1)---
-- author: Anakha
library ieee;
use ieee.std_logic_1164.all;
entity mux4to1 is
  generic (
    nbits : integer);

  port (
    input0, input1, input2, input3: in  std_logic_vector(nbits-1 downto 0);
    output                        : out std_logic_vector(nbits-1 downto 0);
    sel0, sel1                    : in  std_logic);
end mux4to1;

architecture behave  of mux4to1 is
begin  -- behave 
  process(input0,input1,input2,input3,sel0,sel1)
    variable sel_var : std_logic_vector(1 downto 0);
  begin
      sel_var(0) := sel0;
      sel_var(1) := sel1;
     
      case sel_var is
        when "00" =>
          output <= input0 ;
        when "01" =>
          output <= input1;
        when "10" =>
          output <= input2;
        when "11" =>
          output <= input3;
	when others =>
	  output <= "Z";
      end case;
  end process;
end behave ;
