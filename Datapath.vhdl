----------------------------------------
-- Datapath : IITB-RISC
-- Author : Titto Thomas, Sainath, Anakha
-- Date : 20/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Datapath is
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
end Datapath;

architecture behave of Datapath is

--==================================== Components ====================================================--

component alu16 is		-- ALU block
	port (
    	operand1 : in  std_logic_vector(15 downto 0);		-- 16 std_logic input1
    	operand2 : in  std_logic_vector(15 downto 0);		-- 16 std_logic input2
	op_code	 : in  std_logic;				-- 1 std_logic opcode
    	result   : out std_logic_vector(15 downto 0);		-- 16 std_logic ALU result
	carry 	 : out std_logic;				-- carry flag
	zero 	 : out std_logic;				-- zero flag
	alu_equ	 : out std_logic				-- comparator output
	);
end component;


component incr is		--increa
  port (
    	input : in  std_logic_vector(15 downto 0);		-- 16 std_logic input
    	output : out  std_logic_vector(15 downto 0)		-- 16 std_logic output
	);
end component;

component FlagBlock is		-- FR block
    port (
    clock	: in std_logic;		-- clock signal
    reset	: in std_logic;		-- reset signal
    ALUc	: in std_logic;		-- conditional carry flag change
    ALUz	: in std_logic;		-- conditional zero flag change
    Cen		: in std_logic;		-- enable carry flag change
    Zen		: in std_logic;		-- enable zero flag change
    ALUop	: in std_logic;		-- unconditional ALU operation
    ALUcout	: in std_logic;		-- the carry out from ALU
    ALUzout	: in std_logic;		-- the zero out from ALU
    ALUvalid	: out std_logic;	-- whether the ALU output is valid or not
    FR		: out std_logic_vector(1 downto 0)	-- Flag register
    );
end component;

component Memory is		-- Memory block
    port (
    clock	: in  std_logic;                      -- clock
    write	: in  std_logic;			-- write to the memory
    read	: in  std_logic;			-- read from the memory
    address	: in  std_logic_vector(15 downto 0);	-- address of the memory being read
    data_in	: in  std_logic_vector(15 downto 0);  -- data input
    data_out	: out  std_logic_vector(15 downto 0)  -- data output
    );
end component;

component mux2to1bit is		-- 2:1 Mux (1 bit) block
    port (
    input0 : in  std_logic;
    input1 : in  std_logic;
    output : out std_logic;
    sel    : in  std_logic
    );
end component;

component mux2to1 is		-- 2:1 Mux block
    generic (
    nbits : integer
    );
    port (
    input0 : in  std_logic_vector(nbits-1 downto 0);
    input1 : in  std_logic_vector(nbits-1 downto 0);
    output : out std_logic_vector(nbits-1 downto 0);
    sel    : in  std_logic
    );
end component;

component mux4to1 is		-- 4:1 Mux block
    generic (
    nbits : integer
    );
    port (
    input0, input1, input2, input3: in  std_logic_vector(nbits-1 downto 0);
    output                        : out std_logic_vector(nbits-1 downto 0);
    sel0, sel1                    : in  std_logic
    );
end component;

component mux8to1 is		-- 8:1 Mux block
    generic (
    nbits : integer
    );
    port (
    input0, input1, input2, input3, input4, input5, input6, input7 : in  std_logic_vector(nbits-1 downto 0);
    output                                                   	   : out std_logic_vector(nbits-1 downto 0);
    sel0, sel1, sel2                       	                   : in  std_logic
    );
end component;

component reg is		-- Register
generic (
    nbits : integer
    );
    port (
    reg_in	: in  std_logic_vector(nbits-1 downto 0);	-- register input
    reg_out	: out std_logic_vector(nbits-1 downto 0);	-- register output
    clock	: in  std_logic;			-- clock signal
    write	: in  std_logic;			-- write enable signal
    reset	: in  std_logic				-- reset signal
    );
end component;

component regfile is		-- Register File block
   port (
   clock  : in std_logic;
   reset  : in std_logic;
   InA    : in std_logic_vector(2 downto 0); --address for selecting A 
   InB    : in std_logic_vector(2 downto 0); --address for selecting B 
   dataA  : out std_logic_vector(15 downto 0); --read the data into reg A
   dataB  : out std_logic_vector(15 downto 0);--read the data into reg B 
   dataIn : in std_logic_vector(15 downto 0);---data to be written into the register
   WritEn : in std_logic; ---enable for writing
   WriteAdr : in std_logic_vector(2 downto 0) --to select the destination register
   );
end component;

component SE is		-- Sign Extender block
    generic (
    initial	: integer;			-- number of input std_logics
    final	: integer			-- number of output std_logics
    );
    port (
    data_in	: in  std_logic_vector(initial-1 downto 0);  -- data input
    data_out	: out  std_logic_vector(final-1 downto 0)  -- data output
    );
end component;

component CondBlock is
  port (
    OpCode	: in  std_logic_vector(5 downto 0);  	-- Opcode (0-2 and 12-15) bits
    ALU_val	: in std_logic;				-- valid signal from ALU
    Curr_RFWrite : in std_logic;			-- Current value of RF write
    Nxt_RFWrite  : out std_logic			-- Next value for RF write
    );
end component;
component PCImmAdd is
 port (
    	input1 : in  std_logic_vector(15 downto 0);		-- 16 std_logic inputs
	input2 : in  std_logic_vector(15 downto 0);
    	output : out  std_logic_vector(15 downto 0)		-- 16 std_logic output
	);
end component;

component FrwdBlock is
port (
	MA_M4_Sel, WB_M4_Sel : in std_logic_vector(1 downto 0);		-- M4 sel lines
	MA_RFWrite, WB_RFWrite : in std_logic;				-- RF write
	OpCode : in std_logic_vector(5 downto 0);			-- Opcode (12-15 & 0-1)
	Curr_M7_Sel, Curr_M8_Sel : in std_logic_vector(1 downto 0);	-- Current Mux select lines
	MA_Ir911, WB_Ir911, Ir35, Ir68, Ir911 : in std_logic_vector(2 downto 0);	-- Source and destination registers
	ALUout, MemOut : in std_logic_vector(15 downto 0);		-- ALUout and Data memory out
	M7_In, M8_In : out std_logic_vector(15 downto 0);		-- Inputs for M7 and M8
	Nxt_M7_Sel, Nxt_M8_Sel : out std_logic_vector(1 downto 0)	-- Updated Mux select lines
    );
end component;

component LmSmBlock is
port (
	clock, reset : in std_logic;
	Ir0_8 : in std_logic_vector(8 downto 0);
	Ir12_15 : in std_logic_vector(3 downto 0);
	M1_Sel, M2_Sel, M3_Sel : in std_logic;
	M4_Sel, M9_Sel, M7_Sel, M8_Sel : in std_logic_vector(1 downto 0);
	PC_en, IF_en, MemRead, MemWrite, RF_Write : in std_logic;

	M1_Sel_ls, M2_Sel_ls, M3_Sel_ls : out std_logic;
	M4_Sel_ls, M9_Sel_ls, M7_Sel_ls, M8_Sel_ls : out std_logic_vector(1 downto 0);
	PC_en_ls, IF_en_ls, MemRead_ls, MemWrite_ls, RF_Write_ls : out std_logic;
	LM_reg, SM_reg : out std_logic_vector(2 downto 0)
	);
end component;

--==================================== Signals ====================================================--

signal MA_in, MA_out : std_logic_vector(70 downto 0);	-- Memory Access pipeline register
signal EX_in, EX_out : std_logic_vector(90 downto 0);	-- Execute pipeline register
signal RR_in, RR_out : std_logic_vector(105 downto 0);	-- Register Read pipeline register
signal DC_in, DC_out : std_logic_vector(60 downto 0);	-- Decode pipeline register
signal IF_in, IF_out : std_logic_vector(31 downto 0);	-- Fetch pipeline register

signal ZPad : std_logic_vector(15 downto 0);	-- Zero padded output of WB(63-55)
signal M3_out : std_logic_vector(2 downto 0);
signal M4_out, incr_out: std_logic_vector(15 downto 0);
signal WB_PC, WB_ALUout, WB_MemOut : std_logic_vector(15 downto 0);
signal WB_M4_Sel : std_logic_vector(1 downto 0);
signal WB_M3_Sel : std_logic;
signal WB_LM_DestAdr, WB_DestAdr : std_logic_vector(2 downto 0);
signal WB_RFWrite : std_logic;

signal M9_out: std_logic_vector(15 downto 0);
signal MA_ALUout, MA_PC, MA_A, MA_B: std_logic_vector(15 downto 0);
signal DMem_Write, DMem_Read : std_logic;
signal MA_M9_Sel : std_logic_vector(1 downto 0);

signal MuxExDA_out, MuxExDD_out : std_logic_vector(15 downto 0);	-- Data Memory input Muxes
signal MuxExDW_out : std_logic;
signal DMemory_out : std_logic_vector(15 downto 0);	-- Data Memory output

signal PC_en : std_logic;		-- Enable PC updation
signal PC_out, PC_incr_out : std_logic_vector(15 downto 0);	-- PC output

signal IF_en : std_logic;		-- Enable IF updation
signal IF_PC : std_logic_vector(15 downto 0);	-- IF stage PC

signal MuxExIW_out,IMem_Read : std_logic;		-- Instruction Memory write
signal MuxExID_out, MuxExIA_out :  std_logic_vector(15 downto 0);	-- Instruction Memory input Muxes
signal IMemory_out : std_logic_vector(15 downto 0);	-- Instruction Memory output

signal Ir12_15  : std_logic_vector(3 downto 0);	-- Instruction (12 - 15) bits
signal Ir9_11  : std_logic_vector(2 downto 0);	-- Instruction (9 - 11) bits
signal Ir0_8  : std_logic_vector(8 downto 0);	-- Instruction (0 - 8) bits

signal DC_en : std_logic;		-- Enable DC updation

signal RR_en : std_logic;		-- Enable RR updation

signal RRead_SrcB1, RRead_SrcB2, RRead_SrcA1, RRead_SrcA2 : std_logic_vector(2 downto 0);	-- Register Source Mux inputs
signal M1_out, M2_out : std_logic_vector(2 downto 0);	-- Register Source Mux outputs
signal RR_M1_Sel, RR_M2_Sel, RR_M5_Sel : std_logic;		--  Register Source Mux select lines
signal RR_PC, RR_SE6_out, RR_SE9_out, M5_out : std_logic_vector(15 downto 0);	-- Sign extender outputs

signal RFoutA, RFoutB  : std_logic_vector(15 downto 0);	-- Register file outputs
signal JB_addr : std_logic_vector(15 downto 0);	-- Jump / Branch address
signal LM_Slct : std_logic_vector(2 downto 0);	-- LM select from LM/SM block

signal EX_en : std_logic;		-- Enable EX updation

signal EX_B , M7_out : std_logic_vector(15 downto 0);	-- M7 inputs and output
signal EX_SE6_out, EX_A, M8_out : std_logic_vector(15 downto 0);	-- M8 inputs and output
signal EX_PC, PCImm, M6_out : std_logic_vector(15 downto 0);	-- M6 inputs and output

signal EX_M6_Sel, EX_M7_Sel, EX_M8_Sel : std_logic_vector(1 downto 0);	-- Mux select lines
signal EX_OpCode : std_logic_vector(5 downto 0);	-- Opcode (0-1, 12-15) bits
signal EX_ALU_val, Curr_RFWrite, Nxt_RFWrite : std_logic;		-- Enable EX updation

signal EX_OpSel, cout, zout, ALUeq	: std_logic;		-- ALU signals
signal EX_ALUout : std_logic_vector(15 downto 0);		-- ALU output 

signal EX_ALUc, EX_ALUz, EX_Cen, EX_Zen, EX_ALUop, ALU_val : std_logic;		-- ALU signals
signal FR_out : std_logic_vector(1 downto 0);					-- Flag Register

signal MA_en : std_logic;		-- Enable MA updation

signal MA_Ir911, WB_Ir911, EX_Ir35, EX_Ir68,  EX_Ir911 : std_logic_vector(2 downto 0); -- Forwarding block input
signal M7_In, M8_In : std_logic_vector(15 downto 0);		-- Mux Inputs
signal Nxt_M7_Sel, Nxt_M8_Sel, MA_M4_Sel : std_logic_vector(1 downto 0);		-- Mux Select lines
signal MA_RFWrite : std_logic;

signal M1_Sel_ls, M2_Sel_ls, M3_Sel_ls : std_logic;
signal M4_Sel_ls, M9_Sel_ls, M7_Sel_ls, M8_Sel_ls : std_logic_vector(1 downto 0);
signal PC_en_ls, IF_en_ls, MemRead_ls, MemWrite_ls, RF_Write_ls : std_logic;

signal LM_reg, SM_reg : std_logic_vector(2 downto 0);
--================================================================================================--

begin  -- behave

--==================================== Write back ====================================================--

	ZPad <= MA_out(31 downto 23) & b"0000000";

	M3 : mux2to1 generic map (3) port map (WB_DestAdr, WB_LM_DestAdr, M3_out, WB_M3_Sel);
	M4 : mux4to1 generic map (16) port map (WB_MemOut, WB_ALUout, incr_out, ZPad, M4_out, WB_M4_Sel(0), WB_M4_Sel(1));
	wbinc: incr port map(WB_PC, incr_out);
	
	WB_PC <= MA_out(22 downto 7);
	WB_M4_Sel <= MA_out(33 downto 32);
	WB_ALUout <= MA_out(54 downto 39);
	WB_MemOut <= MA_out(70 downto 55);
	WB_M3_Sel <= MA_out(0);
	WB_LM_DestAdr <= MA_out(6 downto 4);
	WB_DestAdr <= MA_out(3 downto 1);
	WB_RFWrite <= MA_out(34);
	
	WB_Ir911 <= MA_out(3 downto 1);

--================================= Memory Access ====================================================--

	reg_MA : reg generic map (71) port map (MA_in, MA_out, clock, MA_en, reset);
	M9 : mux4to1 generic map (16) port map (MA_A, MA_B, MA_PC, X"0000", M9_out, MA_M9_Sel(0), MA_M9_Sel(1));
	DataMem : Memory port map (clock, MuxExDW_out, DMem_Read, MuxExDA_out, MuxExDD_out, DMemory_out);
	
	MuxExDA : mux2to1 generic map (16) port map (MA_ALUout, ExDAddress, MuxExDA_out, mode);
	MuxExDD : mux2to1 generic map (16) port map (M9_out, ExDData, MuxExDD_out, mode);
	MuxExDW : mux2to1bit port map (DMem_Write, ExDWrite, MuxExDW_out, mode);

	MA_ALUout <= EX_out(90 downto 75);
	DMem_Write <= EX_out(70);
	DMem_Read <= EX_out(69);
	MA_M9_Sel <= EX_out(68 downto 67);
	MA_PC <= EX_out(22 downto 7);
	MA_B <= EX_out(66 downto 51);
	MA_A <= EX_out(50 downto 35);
	MA_M4_Sel <= EX_out(33 downto 32);
	MA_RFWrite <= EX_out(34);

	MA_en <= '1';	-- Will be modified by LM/SM block

	MA_Ir911 <= EX_out(3 downto 1);

	MA_in(0) <= EX_out(0);					-- M3_Sel
	MA_in(3 downto 1) <= EX_out(3 downto 1);		-- 9-11
	MA_in(6 downto 4) <= EX_out(6 downto 4);		-- LM_Sel
	MA_in(22 downto 7) <= MA_PC;				-- PC
	MA_in(31 downto 23) <= EX_out(31 downto 23);		-- 0-8
	MA_in(33 downto 32) <= EX_out(33 downto 32);		-- M4_Sel
	MA_in(34) <= EX_out(34);				-- RF_Write
	MA_in(38 downto 35) <= EX_out(74 downto 71);		-- OpCode
	MA_in(54 downto 39) <= EX_out(90 downto 75);		-- ALUout
	MA_in(70 downto 55) <= DMemory_out;			-- Data Memory Out

--======================================= Execution =================================================--

	reg_EX : reg generic map (91) port map (EX_in, EX_out, clock, EX_en, reset);
	M7 : mux4to1 generic map (16) port map (x"0000", x"0001", EX_B , M7_In, M7_out, Nxt_M7_Sel(0), Nxt_M7_Sel(1));
	M8 : mux4to1 generic map (16) port map (EX_SE6_out, EX_A, M8_In, MA_ALUout, M8_out, Nxt_M8_Sel(0), Nxt_M8_Sel(1));
	M6 : mux4to1 generic map (16) port map (PC_incr_out, DMemory_out, PCImm, x"0000", M6_out, EX_M6_Sel(0), EX_M6_Sel(1));

	ConcBlock : CondBlock port map ( EX_OpCode, EX_ALU_val, Curr_RFWrite, Nxt_RFWrite);

	EX_SE6 : SE generic map (6, 16) port map (RR_out(28 downto 23), EX_SE6_out);

-------------------------- ALU ----------------------------------------------------------------------------
	ALU : alu16 port map (M7_out, M8_out, EX_OpSel, EX_ALUout, cout, zout, ALUeq);

-------------------------- FlagBlock ----------------------------------------------------------------------
	FR : FlagBlock port map (clock, reset, EX_ALUc, EX_ALUz, EX_Cen, EX_Zen, EX_ALUop, cout, zout, EX_ALU_val, FR_out);

-------------------------- Forwarding Block ----------------------------------------------------------------------------
	FB : FrwdBlock port map (MA_M4_Sel, WB_M4_Sel, MA_RFWrite, WB_RFWrite, EX_OpCode, EX_M7_Sel, EX_M8_Sel, MA_Ir911, WB_Ir911, EX_Ir35, EX_Ir68, EX_Ir911, MA_ALUout, WB_MemOut, M7_In, M8_In, Nxt_M7_Sel, Nxt_M8_Sel );

	EX_B <= RR_out(66 downto 51);
	EX_A <= RR_out(50 downto 35);
	EX_M7_Sel <= RR_out(72 downto 71);
	EX_M8_Sel <= RR_out(74 downto 73);
	EX_M6_Sel <= RR_out(97 downto 96);
	PCImm <= RR_out(95 downto 80);
	EX_PC <= RR_out(22 downto 7);
	Curr_RFWrite <= RR_out(34);
	EX_OpSel <= RR_out(75);
	EX_ALUop <= RR_out(105);

	EX_ALUc <= RR_out(76);
	EX_ALUz <= RR_out(77);
	EX_Cen <= RR_out(78);
	EX_Zen <= RR_out(79);

	EX_Ir35 <= RR_out(28 downto 26);
	EX_Ir68 <= RR_out(31 downto 29);
	EX_Ir911<= RR_out(3 downto 1);

	EX_OpCode <= RR_out(104 downto 101) & RR_out(24 downto 23);

	EX_en <= '1';	-- Will be modified by LM/SM block

	EX_in(0) <= RR_out(0);					-- M3_Sel
	EX_in(3 downto 1) <= RR_out(3 downto 1);		-- 9-11
	EX_in(6 downto 4) <= RR_out(6 downto 4);		-- LM_Sel
	EX_in(22 downto 7) <= RR_out(22 downto 7);		-- PC
	EX_in(31 downto 23) <= RR_out(31 downto 23);		-- 0-8
	EX_in(33 downto 32) <= RR_out(33 downto 32);		-- M4_Sel
	EX_in(34) <= Nxt_RFWrite;				-- RF_Write
	EX_in(50 downto 35) <= EX_A;				-- RF file out A
	EX_in(66 downto 51) <= EX_B;				-- RF file out B
	EX_in(68 downto 67) <= RR_out(68 downto 67);		-- M9_Sel
	EX_in(69) <= RR_out(69);				-- MemRead
	EX_in(70) <= RR_out(70);				-- MemWrite
	EX_in(74 downto 71) <= RR_out(104 downto 101);		-- OpCode
	EX_in(90 downto 75) <= EX_ALUout;			-- ALUout

--======================================== Reg Read =================================================--

	reg_RR : reg generic map (106) port map (RR_in, RR_out, clock, RR_en, reset);

	M1 : mux2to1 generic map (3) port map (RRead_SrcB1, RRead_SrcB2, M1_out, RR_M1_Sel);
	M2 : mux2to1 generic map (3) port map (RRead_SrcA1, RRead_SrcA2, M2_out, RR_M2_Sel);


	RRead_SrcB1 <= DC_out(12 downto 10);
	RRead_SrcB2 <= DC_out(60 downto 58); 	--from SM block
	RR_M1_Sel   <= DC_out(31);

	RRead_SrcA1 <= DC_out(9 downto 7);
	RRead_SrcA2 <= DC_out(3 downto 1);
	RR_M2_Sel   <= DC_out(32);
	RR_PC <= DC_out(53 downto 38);
	
	RR_SE6 : SE generic map (6, 16) port map (DC_out(9 downto 4), RR_SE6_out);
	RR_SE9 : SE generic map (9, 16) port map (DC_out(12 downto 4), RR_SE9_out);
	M5 : mux2to1 generic map (16) port map ( RR_SE6_out, RR_SE9_out, M5_out, RR_M5_Sel);

	RR_M5_Sel    <= DC_out(33);

	RF : regfile port map (clock, reset, M2_out, M1_out, RFoutA, RFoutB, M4_out, WB_RFWrite, M3_out);

	PCImmAdder : PCImmAdd port map(M5_out, RR_PC, JB_addr);

	RR_en <= '1';	-- Will be modified by LM/SM block

	RR_in(0) <= DC_out(0);					-- M3 Sel
	RR_in(3 downto 1) <= DC_out(3 downto 1);		-- 9-11
	RR_in(6 downto 4) <= LM_Slct;				-- LM Sel
	RR_in(22 downto 7) <= DC_out(53 downto 38);		-- PC
	RR_in(31 downto 23) <= DC_out(12 downto 4);		-- 0-8
	RR_in(33 downto 32) <= DC_out(14 downto 13);		-- M4_Sel
	RR_in(34) <= DC_out(15);				-- RF_Write
	RR_in(50 downto 35) <= RFoutA;				-- RF file out A
	RR_in(66 downto 51) <= RFoutB;				-- RF file out B
	RR_in(68 downto 67) <= DC_out(17 downto 16);		-- M9_Sel
	RR_in(69) <= DC_out(18);				-- MemRead
	RR_in(70) <= DC_out(19);				-- MemWrite
	RR_in(72 downto 71) <= DC_out(21 downto 20);		-- M7_Sel
	RR_in(74 downto 73) <= DC_out(23 downto 22);		-- M8_Sel
	RR_in(75) <= DC_out(24);				-- ALU signals
	RR_in(76) <= DC_out(25);
	RR_in(77) <= DC_out(26); 
	RR_in(78) <= DC_out(27); 
	RR_in(79) <= DC_out(28); 
	RR_in(95 downto 80) <= JB_addr;				-- PC+Imm
	RR_in(97 downto 96) <= DC_out(30 downto 29);		-- M6_Sel
	RR_in(98) <= DC_out(31); 				-- M1, M2, M5 Sel
	RR_in(99) <= DC_out(32); 
	RR_in(100) <= DC_out(33);
	RR_in(104 downto 101) <= DC_out(37 downto 34);		-- OpCode
	RR_in (105) <= DC_out(54);                              --ALUOp

	LM_Slct <= DC_out(57 downto 55);		-- From the LM Block


--=========================================== Decode ====================================================--

	reg_DC : reg generic map (61) port map (DC_in, DC_out, clock, DC_en, reset);
	DC_in(0) <= M3_Sel_ls;
	DC_in(3 downto 1) <= Ir9_11;
	DC_in(12 downto 4) <= Ir0_8;
	DC_in(14 downto 13) <= M4_Sel_ls;
	DC_in(15) <= RF_Write_ls;
	DC_in(17 downto 16) <= M9_Sel_ls;
	DC_in(18) <= MemRead_ls;
	DC_in(19) <= MemWrite_ls;
	DC_in(21 downto 20) <= M7_Sel_ls;
	DC_in(23 downto 22) <= M8_Sel_ls;
	DC_in(24) <= OpSel; 
	DC_in(25) <= ALUc;
	DC_in(26) <= ALUz;
	DC_in(27) <= Cen;
	DC_in(28) <= Zen; 
	DC_in(30 downto 29) <= M6_Sel;
	DC_in(31) <= M1_Sel_ls;
	DC_in(32) <= M2_Sel_ls;
	DC_in(33) <= M5_Sel;  
	DC_in(37 downto 34) <= Ir12_15;
	DC_in(53 downto 38) <= IF_PC;
	DC_in(54) <= ALUOp;
	DC_in(57 downto 55) <= LM_reg;
	DC_in(60 downto 58) <= SM_reg;

	LM_SM : LmSmBlock port map ( clock, reset, Ir0_8, Ir12_15, M1_Sel, M2_Sel, M3_Sel, M4_Sel, M9_Sel, M7_Sel, M8_Sel, '1', '1', MemRead, MemWrite, RF_Write, M1_Sel_ls, M2_Sel_ls, M3_Sel_ls, M4_Sel_ls, M9_Sel_ls, M7_Sel_ls, M8_Sel_ls, PC_en_ls, IF_en_ls, MemRead_ls, MemWrite_ls, RF_Write_ls, LM_reg, SM_reg);

	DC_en <= '1';	-- Will be modified by LM/SM block


--========================================= Fetch ===================================================--

	IF_PC <= IF_out(31 downto 16);		-- signals going to the next stage
	Ir12_15 <= IF_out(15 downto 12);
	Ir9_11 <= IF_out(11 downto 9);
	Ir0_8 <= IF_out(8 downto 0);

	Instruction <= IF_out(15 downto 0);		--Instruction passed to the control path
	
	IMem : Memory port map (clock, MuxExIW_out, IMem_Read, MuxExIA_out, MuxExID_out, IMemory_out);
	MuxExIA : mux2to1 generic map (16) port map (PC_out, ExIAddress, MuxExIA_out, mode);
	MuxExID : mux2to1 generic map (16) port map (X"0000", ExIData, MuxExID_out, mode);
	MuxExIW : mux2to1bit port map ('0', ExIWrite, MuxExIW_out, mode);


	reg_IF : reg generic map (32) port map (IF_in, IF_out, clock, IF_en, reset);


	IF_in(15 downto 0) <= IMemory_out;
	IF_in(31 downto 16)<= PC_out;

	reg_PC : reg generic map (16) port map (M6_out, PC_out, clock, PC_en, reset);
	Finc: incr port map(PC_out, PC_incr_out);

	PC_en <= PC_en_ls;		-- modified by LM/SM block
	IF_en <= IF_en_ls;		-- modified by LM/SM block
	IMem_Read <= '1';	-- Always read from Instruction Memory
--===========================================================================================================--

end behave;
