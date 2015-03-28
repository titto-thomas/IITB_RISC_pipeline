----------------------------------------
-- Memory Module : IITB-RISC
-- Author : Titto Thomas
-- Date : 18/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
  port (
    clock	: in  std_logic;                      -- clock
    write	: in  std_logic;			-- write to the memory
    read	: in  std_logic;			-- read from the memory
    address	: in  std_logic_vector(15 downto 0);	-- address of the memory being read
    data_in	: in  std_logic_vector(15 downto 0);  -- data input
    data_out	: out  std_logic_vector(15 downto 0)  -- data output
    );
end Memory;

architecture RAM of Memory is

type mem_type is array (65535 downto 0) of std_logic_vector(15 downto 0);	-- the size of the memory in use
signal mem	: mem_type;

begin

data_out <= mem(to_integer(unsigned(address))) when (read = '1') else (others => 'Z'); -- give the memory content as the output

------------------- writing the data to the register ------------------------------------
Memory_Write : process(clock)
begin
   if (rising_edge(clock)) then
      if (write = '1') then
          mem (to_integer(unsigned(address))) <= data_in ;	-- write the input data on the corresponding location
      end if;
   end if;
end process Memory_Write;
-----------------------------------------------------------------------------------------

end architecture RAM;
