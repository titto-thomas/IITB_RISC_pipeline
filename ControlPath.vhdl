----------------------------------------
-- Datapath : IITB-RISC
-- Author : Titto Thomas, Sainath, Anakha
-- Date : 20/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ControlPath is
  port (
    clock, reset			        : in std_logic;		-- clock and reset signals
    RF_Write				        : out std_logic;		-- Reg File write enable
    MemRead, MemWrite			        : out std_logic;		-- Read / Write from / to the data memory
    OpSel, ALUc, ALUz, Cen, Zen, ALUop		: out std_logic;		-- ALU & Flag block signals

    M1_Sel, M2_Sel, M5_Sel, M3_Sel	: out std_logic;		-- Mux select lines
    M4_Sel, M6_Sel, M7_Sel, M8_Sel, M9_Sel : out std_logic_vector(1 downto 0);	-- Mux select lines
    Instruction				: in std_logic_vector(15 downto 0)	-- Instruction to the CP
   
    );
end ControlPath;

architecture behave of ControlPath is

begin
main: process(Instruction,reset)
begin
	if (reset='1') then 
	  RF_Write <= '0';
	   MemRead <= '0';
	   MemWrite <= '0';
	   OpSel <= '0';
	   ALUc <= '0';
	   ALUz <= '0';
	   Cen <= '0';
	   Zen <= '0';
	   ALUOp <='0';
	   M1_Sel <= '0';
	   M2_Sel <='0';
	   M3_Sel <='0';
           M4_Sel <=b"00";
	   M5_Sel <='0';
	   M6_Sel <=b"00";
	   M7_Sel <=b"00";
	   M8_Sel <=b"00";
	   M9_Sel <=b"00";
	elsif (Instruction(15 downto 12) =X"0" and Instruction(1 downto 0) =b"00" ) then
	   RF_Write <= '1';
	   MemRead <= '0';
	   MemWrite <= '0';
	   OpSel <= '0';
	   ALUc <= '0';
	   ALUz <= '0';
	   Cen <= '1';
	   Zen <= '1';
	   ALUOp <= '1';
	   M1_Sel <= '0';
	   M2_Sel <='0';
	   M3_Sel <='0';
           M4_Sel <= b"01";
	   M5_Sel <='0';
	   M6_Sel <= b"00";
	   M7_Sel <= b"10";
	   M8_Sel <= b"01";
	   M9_Sel <=b"00";
	elsif (Instruction(15 downto 12) =X"4") then
	   RF_Write <= '1';
	   MemRead <= '1';
	   MemWrite <= '0';
	   OpSel <= '0';
	   ALUc <= '0';
	   ALUz <= '0';
	   Cen <= '0';
	   Zen <= '0';
	   ALUOp <= '1';
	   M1_Sel <= '0';
	   M2_Sel <='0';
	   M3_Sel <='0';
           M4_Sel <= b"00";
	   M5_Sel <='0';
	   M6_Sel <= b"00";
	   M7_Sel <= b"10";
	   M8_Sel <= b"00";
	   M9_Sel <=b"00";
	end if;

end process main;

end behave;

