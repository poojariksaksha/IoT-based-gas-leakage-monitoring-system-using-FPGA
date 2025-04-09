----------------------------------------------------------------------------------
-- Project Name		: Gas leakage detection
-- Module Name		: LCD - Behavioral 
-- Create Date		: 01:00:00 21/02/2021 
-- Design Name		: 16X2 LCD interfacing
-- Target Devices	: Spartan 6
-- Tool versions	: ISE project navigator version 14.7 (nt64) 
-- Description: 
-- 		Transmitting Gas leakage data and temperature data shown on LCD display
-- Revision			: 1.0.0
----------------------------------------------------------------------------------

-- Including libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;

entity LCD is
	Port ( 	
		clk 	: in  STD_LOGIC;						-- LCD clock signal
		lcd_e  	: out std_logic;						-- LCD enable control
		lcd_rs 	: out std_logic;						-- LCD data or command control
		data   	: out std_logic_vector(7 downto 0);		-- LCD data line
		chsel 	: out std_logic;
		temp_data2,temp_data3			: in std_logic_vector(7 downto 0);	-- Signals for ASCII conversion of gas data
		gas_data1,gas_data2,gas_data3	: in std_logic_vector(7 downto 0)	-- Signals for ASCII conversion of temperature data
	);
end LCD;

architecture Behavioral of LCD is

	constant N: integer :=35; 
	type arr1 is array (1 to N) of std_logic_vector(7 downto 0); 
	constant datas : arr1 := (X"38",X"0c",X"06",X"01",X"81",X"54",X"45",X"4d",X"50",X"45",X"52",X"41",X"54",X"55",X"52",X"45",X"3a",X"3a",X"3a",
							  X"c1",X"47",X"41",X"53",X"20",X"4c",X"45",X"56",X"45",X"4c",X"20",X"20",X"3a",X"3a",X"3a",X"3a"); -- command and data to display                                              

begin

	process(clk)

		variable i : integer := 0;
		variable j : integer := 1;

	begin
		
		-- Writing data on LCD data line
		if clk'event and clk = '1' then
			if i <= 1000000 then
				i := i + 1;
				lcd_e <= '1';
				if j < 18 then
					data <= datas(j)(7 downto 0);
				elsif j = 18 then
					data <= temp_data2;
				elsif j = 19 then
					data <= temp_data3;
					chsel <= '0';
				elsif j > 19 and j < 33 then
					data <= datas(j)(7 downto 0);
				elsif j = 34 then
					data <= gas_data1;
				elsif j = 35 then
					data <= gas_data2;
				elsif j = 33 then
					data <= gas_data3;
					chsel <= '1';
				end if;
			elsif i > 1000000 and i < 2000000 then
				i := i + 1;
				lcd_e <= '0';
			elsif i = 2000000 then
				j := j + 1;
				i := 0;
			end if;
			
			-- Command and data register controling
			if j <= 5  then
				lcd_rs <= '0';    				-- Command signal
			elsif j > 5 and j < 20 then
				lcd_rs <= '1';   				-- Data signal
			elsif j = 20 then
				lcd_rs <= '0';   				-- Command signal
			elsif j > 20 and j <= 35 then
				lcd_rs <= '1';   				-- Data signal
			end if;
			
			-- Reset pointer to repeat display of data
			if j = 36 then 
				j := 5;
			end if;
		end if;
	end process;

end Behavioral;
