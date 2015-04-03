----------------------------------------
-- Main Processor - Testbench : IITB-RISC
-- Author : Titto Thomas, Sainath, Anakha
-- Date : 9/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is

end testbench;

architecture behave of testbench is

component pipeline_RISC is
   port (
    clock, reset						: in std_logic;			-- clock and reset signals
    InstrData, InstrAddress, DataData, DataAddress		: in std_logic_vector(15 downto 0);	-- External data and address for programing
    mode, InstrWrite, DataWrite				: in std_logic		-- Program / Execution mode
    );
end component;

signal clock, reset, mode, InstrWrite, DataWrite : std_logic := '0';
signal InstrData, InstrAddress, DataData, DataAddress : std_logic_vector(15 downto 0);

begin --behave

	DUT : pipeline_RISC port map (clock, reset, InstrData, InstrAddress, DataData, DataAddress, mode, InstrWrite, DataWrite);

	clock <= not clock after 5 ns;

	Main : process
	begin
		reset <= '1';
		InstrData <= x"42B0";
		InstrAddress <= x"0000";
		DataData <= x"0000";
		DataAddress <= x"0000";
		mode <= '1';
		DataWrite <= '0';
		InstrWrite <= '1';
		wait for 10 ns;
		InstrData <= x"6200";
		InstrAddress <= x"0001";
		wait for 10 ns;
		InstrData <= x"6254";
		InstrAddress <= x"0002";
		wait for 10 ns;
		InstrWrite <= '0';
		DataWrite <= '1';
		DataData <= x"0001";
		DataAddress <= x"FFF0";
		wait for 10 ns;
		DataData <= x"ABCD";
		DataAddress <= x"0001";
		wait for 10 ns;
		DataData <= x"EF10";
		DataAddress <= x"0002";
		wait for 10 ns;
		DataData <= x"FFFF";
		DataAddress <= x"0003";
		wait for 10 ns;
		DataWrite <= '0';
		reset <= '0';		
		mode <= '0';
		wait ;
	end process;

end behave;
