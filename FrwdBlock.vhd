----------------------------------------
-- Conditional update of RF Write : IITB-RISC
-- Author : Titto Thomas
-- Date : 23/3/2014
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FrwdBlock is
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
end FrwdBlock;

architecture behave of FrwdBlock is

signal init_ls : std_logic := '0';

begin	--behave

	Main : process (Opcode, Curr_M7_Sel, Curr_M8_Sel, MA_Ir911, WB_Ir911, Ir35, Ir68, ALUout, MemOut, MA_M4_Sel, MA_RFWrite,  WB_M4_Sel, WB_RFWrite )
	begin
		if ( Opcode(5 downto 2) = x"0" or Opcode(5 downto 2) = x"1" or Opcode(5 downto 2) = x"2" ) then
			init_ls <= '0';
			if (( MA_Ir911 = Ir35 ) and (MA_M4_Sel = b"01") and (MA_RFWrite = '1') )then
				M8_In <= ALUout;
				Nxt_M8_Sel <= b"10";
				if (( MA_Ir911 = Ir68 ) and (MA_M4_Sel = b"01") and (MA_RFWrite = '1')) then
					Nxt_M7_Sel <= b"11";
					M7_In <= ALUout;
				elsif (( WB_Ir911 = Ir68 ) and (WB_M4_Sel = b"00") and (WB_RFWrite = '1')) then
					Nxt_M7_Sel <= b"11";
					M7_In <= MemOut;
				else
					Nxt_M7_Sel <= Curr_M7_Sel;
					M7_In <= x"0000";
				end if;
				
			elsif (( MA_Ir911 = Ir68 ) and (MA_M4_Sel = b"01") and (MA_RFWrite = '1') ) then
				M7_In <= ALUout;
				Nxt_M7_Sel <= b"11";
				if (( MA_Ir911 = Ir35 ) and (MA_M4_Sel = b"01") and (MA_RFWrite = '1')) then
					Nxt_M8_Sel <= b"10";
					M8_In <= ALUout;
				elsif (( WB_Ir911 = Ir35 ) and (WB_M4_Sel = b"00") and (WB_RFWrite = '1')) then
					Nxt_M8_Sel <= b"10";
					M8_In <= MemOut;
				else
					Nxt_M8_Sel <= Curr_M8_Sel;
					M8_In <= x"0000";
				end if;
			elsif (( WB_Ir911 = Ir35 ) and (WB_M4_Sel = b"00") and (WB_RFWrite = '1') ) then
				M8_In <= Memout;
				Nxt_M8_Sel <= b"10";
				if (( MA_Ir911 = Ir68 ) and (MA_M4_Sel = b"01") and (MA_RFWrite = '1')) then
					Nxt_M7_Sel <= b"11";
					M7_In <= ALUout;
				elsif (( WB_Ir911 = Ir68 ) and (WB_M4_Sel = b"00") and (WB_RFWrite = '1')) then
					Nxt_M7_Sel <= b"11";
					M7_In <= MemOut;
				else
					Nxt_M7_Sel <= Curr_M7_Sel;
					M7_In <= x"0000";
				end if;
			elsif (( WB_Ir911 = Ir68 ) and (WB_M4_Sel = b"00") and (WB_RFWrite = '1') ) then
				M7_In <= Memout;
				Nxt_M7_Sel <= b"11";
				if (( MA_Ir911 = Ir35 ) and (MA_M4_Sel = b"01") and (MA_RFWrite = '1')) then
					Nxt_M8_Sel <= b"10";
					M8_In <= ALUout;
				elsif (( WB_Ir911 = Ir35 ) and (WB_M4_Sel = b"00") and (WB_RFWrite = '1')) then
					Nxt_M8_Sel <= b"10";
					M8_In <= MemOut;
				else
					Nxt_M8_Sel <= Curr_M8_Sel;
					M8_In <= x"0000";
				end if;
			else
				Nxt_M7_Sel <= Curr_M7_Sel;
				Nxt_M8_Sel <= Curr_M8_Sel;
				M7_In <= ALUout;
				M8_In <= ALUout;
			end if;
		elsif ( Opcode(5 downto 2) = x"6" or Opcode(5 downto 2) = x"7" ) and init_ls = '0' then -- Need to rethink !!!
			init_ls <= '1';
			if (( MA_Ir911 = Ir911 ) and (MA_M4_Sel = b"01") and (MA_RFWrite = '1') )then
				M8_In <= ALUout;
				Nxt_M8_Sel <= b"10";
			elsif (( WB_Ir911 = Ir911 ) and (WB_M4_Sel = b"00") and (WB_RFWrite = '1') ) then
				M8_In <= MemOut;
				Nxt_M8_Sel <= b"10";
			else
				Nxt_M7_Sel <= Curr_M7_Sel;
				Nxt_M8_Sel <= Curr_M8_Sel;
				M7_In <= ALUout;
				M8_In <= ALUout;
			end if;
		else
			init_ls <= '0';
			Nxt_M7_Sel <= Curr_M7_Sel;
			Nxt_M8_Sel <= Curr_M8_Sel;
			M7_In <= ALUout;
			M8_In <= ALUout;
		end if;
	end process Main;

end behave;
