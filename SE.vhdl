----------------------------------------
-- Sign Extender Module : IITB-RISC
-- Author : Titto Thomas
-- Date : 8/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SE is
  generic (
    initial	: integer;			-- number of input std_logics
    final	: integer			-- number of output std_logics
    );
  port (
    data_in	: in  std_logic_vector(initial-1 downto 0);  -- data input
    data_out	: out  std_logic_vector(final-1 downto 0)  -- data output
    );
end SE;

architecture SignExtend of SE is

begin

	data_out <= std_logic_vector(resize(signed(data_in), final));	-- resize the vector and pass it out

end architecture SignExtend;
