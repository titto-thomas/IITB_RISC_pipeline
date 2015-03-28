--IITB RISC processor---
--Regfile Module(2to1)---
-- author: Anakha
-----------------------description of entity---------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
  entity regfile is 
    port (
   clock  : in std_logic;
   reset  : in std_logic;
   InA    : in std_logic_vector(2 downto 0); --address for selecting A 
   InB    : in std_logic_vector(2 downto 0); --address for selecting B 
   dataA  : out std_logic_vector(15 downto 0); --read the data into reg A
   dataB  : out std_logic_vector(15 downto 0);--read the data into reg B 
   dataIn : in std_logic_vector(15 downto 0);---data to be written into the register
   WritEn : in std_logic; 			---enable for writing
   WriteAdr : in std_logic_vector(2 downto 0) --to select the destination register
);

  end regfile;
 
----------------------end entity----------------------------

-----------------------description of architecture----------
architecture behave of regfile is 
type regarray is array (6 downto 0) of std_logic_vector(15 downto 0);
signal reg: regarray;
begin
---separate process for write and read----------------------
write: process(clock)
	
	begin
	if clock'event and clock='1' then 
		if reset ='1' then 
			 reg(0)<= X"0000";
			 reg(1)<= X"0000";
			 reg(2)<= X"0000";
			 reg(3)<= X"0000";
			 reg(4)<= X"0000";
			 reg(5)<= X"0000";
			 reg(6)<= X"0000";
		else 
			if WritEn = '1' then
                        case WriteAdr is 
				 when "000" =>
					reg(0)<= dataIn;
				 when "001" => 
					reg(1) <= dataIn;
		                 when "010" =>
					reg(2) <= dataIn;
				 when "011" => 
					reg(3) <= dataIn;
				 when "100" =>
					reg(4) <= dataIn;
			         when "101" => 
					reg(5) <= dataIn;
				 when "110" => 
					reg(6) <= dataIn;
				 when others =>
				       reg(0)<= reg(0);
                        end case;      
			end if;
		end if;
	end if;
		
end process write;
---------------------------------------------------------------
 ---------------------process for read-------------------------

read: process(InA,InB)
	begin
	case InA is 
		when "000" =>
			dataA <= reg(0);
		when "001" =>
			dataA <= reg(1);		
		when "010" =>
			dataA <= reg(2);
		when "011" =>
			dataA <= reg(3);
		when "100" =>
			dataA <= reg(4);
		when "101" =>
			dataA <= reg(5);
		when "110" =>
			dataA <= reg(6);
		when others => 
			dataB <= X"0000";
	end case;

	case InB is 
		when "000" =>
			dataB <= reg(0);
		when "001" =>
			dataB <= reg(1);		
		when "010" =>
			dataB <= reg(2);
		when "011" =>
			dataB <= reg(3);
		when "100" =>
			dataB <= reg(4);
		when "101" =>
			dataB <= reg(5);
		when "110" =>
			dataB <= reg(6);
		when others => 
			dataB <= X"0000";
	end case;
end process read;
---------------------------------------------------
end behave;
