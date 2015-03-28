----------------------------------------
-- Main Processor : IITB-RISC
-- Author : Titto Thomas, Sainath, Anakha
-- Date : 9/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_RISC is
  port (
    clock, reset						: in std_logic;			-- clock and reset signals
    InstrData, InstrAddress, DataData, DataAddress		: in std_logic_vector(15 downto 0);	-- External data and address for programing
    mode, InstrWrite, DataWrite				: in std_logic		-- Program / Execution mode
    );
end pipeline_RISC;

architecture behave of pipeline_RISC is

component Datapath is
	port (
	    clock, reset			: in std_logic;		-- clock and reset signals
	    ExDData, ExDAddress			: in std_logic_vector(15 downto 0);	-- External data and address for programing
	    mode, ExDWrite			: in std_logic;		-- Program / Execution mode
	    RF_Write				: in std_logic;		-- Reg File write enable
	    MemRead, MemWrite			: in std_logic;		-- Read / Write from / to the data memory
	    OpSel, ALUc, ALUz, Cen, Zen,ALUOp	: in std_logic;		-- ALU & Flag block signals

	    M1_Sel, M2_Sel, M5_Sel, M3_Sel	: in std_logic;		-- Mux select lines
	    M4_Sel, M6_Sel, M7_Sel, M8_Sel, M9_Sel : in std_logic_vector(1 downto 0);	-- Mux select lines
	    Instruction				: out std_logic_vector(15 downto 0);	-- Instruction to the CP
	    ExIWrite 				: in std_logic;		-- Write to Instruction Mem
	    ExIData, ExIAddress			: in std_logic_vector(15 downto 0)	-- External instruction and address for programing
	    );
end component;

component ControlPath is
    port (
    clock, reset			        : in std_logic;		-- clock and reset signals
    RF_Write				        : out std_logic;		-- Reg File write enable
    MemRead, MemWrite			        : out std_logic;		-- Read / Write from / to the data memory
    OpSel, ALUc, ALUz, Cen, Zen, ALUop		: out std_logic;		-- ALU & Flag block signals

    M1_Sel, M2_Sel, M5_Sel, M3_Sel	: out std_logic;		-- Mux select lines
    M4_Sel, M6_Sel, M7_Sel, M8_Sel, M9_Sel : out std_logic_vector(1 downto 0);	-- Mux select lines
    Instruction				: in std_logic_vector(15 downto 0)	-- Instruction to the CP
   
    );
end component;

signal RF_Write, MemRead, MemWrite, OpSel, ALUc, ALUz, Cen, Zen,ALUOp, M1_Sel, M2_Sel, M5_Sel, M3_Sel	: std_logic;
signal M4_Sel, M6_Sel, M7_Sel, M8_Sel, M9_Sel : std_logic_vector(1 downto 0);

signal Instruction : std_logic_vector(15 downto 0);

begin 	-- behave

	DP : Datapath port map (clock, reset, DataData, DataAddress, mode, DataWrite, RF_Write, MemRead, MemWrite, OpSel, ALUc, ALUz, Cen, Zen, ALUOp, M1_Sel, M2_Sel, M5_Sel, M3_Sel, M4_Sel, M6_Sel, M7_Sel, M8_Sel, M9_Sel, Instruction, InstrWrite, InstrData, InstrAddress);

	CP : ControlPath port map (clock, reset, RF_Write, MemRead, MemWrite, OpSel, ALUc, ALUz, Cen, Zen, ALUop, M1_Sel, M2_Sel, M5_Sel, M3_Sel, M4_Sel, M6_Sel, M7_Sel, M8_Sel, M9_Sel, Instruction);

end behave;
