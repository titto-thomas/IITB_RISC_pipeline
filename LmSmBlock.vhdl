----------------------------------------
-- Datapath : IITB - Pipelined - RISC
-- Author : Titto Thomas, Sainath, Anakha
-- Date : 2/4/2015
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LmSmBlock is
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
end LmSmBlock;

architecture behave of LmSmBlock is

signal iteration : integer := 0;
signal local : std_logic_vector( 7 downto 0) := x"00";
begin

	Main : process( clock, reset, Ir0_8, Ir12_15, M1_Sel, M2_Sel, M3_Sel, M4_Sel, M9_Sel, M7_Sel, M8_Sel, PC_en, IF_en, MemRead, MemWrite, RF_Write )

	begin
		if Ir12_15 = x"7" then
			LM_reg <= "000";
			if ( iteration = 0 ) then
				M2_Sel_ls <= '1';
				if ( Ir0_8 = x"00" & '0' ) then
					M1_Sel_ls <= '0';
					M3_Sel_ls <= '0';
					M4_Sel_ls <= "00";
					M9_Sel_ls <= "00";
					M7_Sel_ls <= "00";
					M8_Sel_ls <= "00";
					PC_en_ls <= '1';
					IF_en_ls <= '1';
					MemRead_ls <= '0';
					MemWrite_ls <= '0';
					RF_Write_ls <= '0';
					SM_reg <= "000";
					local <= x"00";
				else
					M1_Sel_ls <= '1';
					M3_Sel_ls <= '0';
					M4_Sel_ls <= "00";
					M9_Sel_ls <= "01";
					M7_Sel_ls <= "00";
					M8_Sel_ls <= "01";
					MemRead_ls <= '0';
					MemWrite_ls <= '1';
					RF_Write_ls <= '0';
					if Ir0_8(0) = '1' then
						SM_reg <= "000";
						if ( Ir0_8(7 downto 1) /= "0000000" ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7 downto 1) & '0';
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;					
					elsif Ir0_8(1) = '1' then
						SM_reg <= "001";
						if ( Ir0_8(7 downto 2) /= "000000" ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7 downto 2) & "00";
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;
					elsif Ir0_8(2) = '1' then
						SM_reg <= "010";
						if ( Ir0_8(7 downto 3) /= "00000" ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7 downto 3) & "000";
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;
					elsif Ir0_8(3) = '1' then
						SM_reg <= "011";
						if ( Ir0_8(7 downto 4) /= "0000" ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7 downto 4) & "0000";
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;
					elsif Ir0_8(4) = '1' then
						SM_reg <= "100";
						if ( Ir0_8(7 downto 5) /= "000" ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7 downto 5) & "00000";
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;
					elsif Ir0_8(5) = '1' then
						SM_reg <= "101";
						if ( Ir0_8(7 downto 6) /= "00" ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7 downto 6) & "000000";
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;
					elsif Ir0_8(6) = '1' then
						SM_reg <= "110";
						if ( Ir0_8(7) /= '0' ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7) & "0000000";
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;
					else
						local <= x"00";
						SM_reg <= "111";
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				end if;
			else
				M1_Sel_ls <= '1';
				M3_Sel_ls <= '0';
				M4_Sel_ls <= "00";
				M9_Sel_ls <= "01";
				M7_Sel_ls <= "01";
				M8_Sel_ls <= "10";
				MemRead_ls <= '0';
				MemWrite_ls <= '1';
				RF_Write_ls <= '0';				
				if local(1) = '1' then
					SM_reg <= "001";
					local(1) <= '0';
					if ( local(7 downto 2) /= "000000" ) then
						PC_en_ls <= '0';
						IF_en_ls <= '0';
						iteration <= iteration + 1;
					else
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				elsif local(2) = '1' then
					SM_reg <= "010";
					local(2) <= '0';
					if ( local(7 downto 3) /= "00000" ) then
						PC_en_ls <= '0';
						IF_en_ls <= '0';
						iteration <= iteration + 1;
					else
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				elsif local(3) = '1' then
					SM_reg <= "011";
					local(3) <= '0';
					if ( local(7 downto 4) /= "0000" ) then
						PC_en_ls <= '0';
						IF_en_ls <= '0';
						iteration <= iteration + 1;
					else
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				elsif local(4) = '1' then
					SM_reg <= "100";
					local(4) <= '0';
					if ( local(7 downto 5) /= "000" ) then
						PC_en_ls <= '0';
						IF_en_ls <= '0';
						iteration <= iteration + 1;
					else
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				elsif local(5) = '1' then
					SM_reg <= "101";
					local(5) <= '0';
					if ( local(7 downto 6) /= "00" ) then
						PC_en_ls <= '0';
						IF_en_ls <= '0';
						iteration <= iteration + 1;
					else
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				elsif local(6) = '1' then
					SM_reg <= "110";
					local(6) <= '0';
					if ( local(7) /= '0' ) then
						PC_en_ls <= '0';
						IF_en_ls <= '0';
						iteration <= iteration + 1;
					else
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				else
					local(7) <= '0';
					SM_reg <= "111";
					PC_en_ls <= '1';
					IF_en_ls <= '1';
					iteration <= 0;
				end if;
			end if;
		elsif Ir12_15 = x"6" then
			SM_reg <= "000";
			if ( iteration = 0 ) then
				M2_Sel_ls <= '1';
				if ( Ir0_8 = x"00" & '0' ) then
					M1_Sel_ls <= '0';
					M3_Sel_ls <= '0';
					M4_Sel_ls <= "00";
					M9_Sel_ls <= "00";
					M7_Sel_ls <= "00";
					M8_Sel_ls <= "00";
					PC_en_ls <= '1';
					IF_en_ls <= '1';
					MemRead_ls <= '0';
					MemWrite_ls <= '0';
					RF_Write_ls <= '0';
					LM_reg <= "000";
					local <= x"00";
				else
					M1_Sel_ls <= '1';
					M3_Sel_ls <= '1';
					M4_Sel_ls <= "00";
					M9_Sel_ls <= "00";
					M7_Sel_ls <= "00";
					M8_Sel_ls <= "01";
					MemRead_ls <= '1';
					MemWrite_ls <= '0';
					RF_Write_ls <= '1';
					if Ir0_8(0) = '1' then
						LM_reg <= "000";
						if ( Ir0_8(7 downto 1) /= "0000000" ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7 downto 1) & '0';
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;					
					elsif Ir0_8(1) = '1' then
						LM_reg <= "001";
						if ( Ir0_8(7 downto 2) /= "000000" ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7 downto 2) & "00";
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;
					elsif Ir0_8(2) = '1' then
						LM_reg <= "010";
						if ( Ir0_8(7 downto 3) /= "00000" ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7 downto 3) & "000";
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;
					elsif Ir0_8(3) = '1' then
						LM_reg <= "011";
						if ( Ir0_8(7 downto 4) /= "0000" ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7 downto 4) & "0000";
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;
					elsif Ir0_8(4) = '1' then
						LM_reg <= "100";
						if ( Ir0_8(7 downto 5) /= "000" ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7 downto 5) & "00000";
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;
					elsif Ir0_8(5) = '1' then
						LM_reg <= "101";
						if ( Ir0_8(7 downto 6) /= "00" ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7 downto 6) & "000000";
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;
					elsif Ir0_8(6) = '1' then
						LM_reg <= "110";
						if ( Ir0_8(7) /= '0' ) then
							PC_en_ls <= '0';
							IF_en_ls <= '0';
							iteration <= 1;
							local <= Ir0_8(7) & "0000000";
						else
							PC_en_ls <= '1';
							IF_en_ls <= '1';
							iteration <= 0;
						end if;
					else
						local <= x"00";
						LM_reg <= "111";
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				end if;
			else
				M1_Sel_ls <= '1';
				M3_Sel_ls <= '1';
				M4_Sel_ls <= "00";
				M9_Sel_ls <= "00";
				M7_Sel_ls <= "01";
				M8_Sel_ls <= "10";
				MemRead_ls <= '1';
				MemWrite_ls <= '0';
				RF_Write_ls <= '1';				
				if local(1) = '1' then
					LM_reg <= "001";
					local(1) <= '0';
					if ( local(7 downto 2) /= "000000" ) then
						PC_en_ls <= '0';
						IF_en_ls <= '0';
						iteration <= iteration + 1;
					else
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				elsif local(2) = '1' then
					LM_reg <= "010";
					local(2) <= '0';
					if ( local(7 downto 3) /= "00000" ) then
						PC_en_ls <= '0';
						IF_en_ls <= '0';
						iteration <= iteration + 1;
					else
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				elsif local(3) = '1' then
					LM_reg <= "011";
					local(3) <= '0';
					if ( local(7 downto 4) /= "0000" ) then
						PC_en_ls <= '0';
						IF_en_ls <= '0';
						iteration <= iteration + 1;
					else
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				elsif local(4) = '1' then
					LM_reg <= "100";
					local(4) <= '0';
					if ( local(7 downto 5) /= "000" ) then
						PC_en_ls <= '0';
						IF_en_ls <= '0';
						iteration <= iteration + 1;
					else
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				elsif local(5) = '1' then
					LM_reg <= "101";
					local(5) <= '0';
					if ( local(7 downto 6) /= "00" ) then
						PC_en_ls <= '0';
						IF_en_ls <= '0';
						iteration <= iteration + 1;
					else
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				elsif local(6) = '1' then
					LM_reg <= "110";
					local(6) <= '0';
					if ( local(7) /= '0' ) then
						PC_en_ls <= '0';
						IF_en_ls <= '0';
						iteration <= iteration + 1;
					else
						PC_en_ls <= '1';
						IF_en_ls <= '1';
						iteration <= 0;
					end if;
				else
					local(7) <= '0';
					LM_reg <= "111";
					PC_en_ls <= '1';
					IF_en_ls <= '1';
					iteration <= 0;
				end if;
			end if;
		else
			M1_Sel_ls <= M1_Sel;
			M2_Sel_ls <= M2_Sel;
			M3_Sel_ls <= M3_Sel;
			M4_Sel_ls <= M4_Sel;
			M9_Sel_ls <= M9_Sel;
			M7_Sel_ls <= M7_Sel;
			M8_Sel_ls <= M8_Sel;
			PC_en_ls <= PC_en;
			IF_en_ls <= IF_en;
			MemRead_ls <= MemRead;
			MemWrite_ls <= MemWrite;
			RF_Write_ls <= RF_Write;
		end if;

	end process Main;
end behave;

