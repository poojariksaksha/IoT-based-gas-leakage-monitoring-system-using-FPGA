----------------------------------------------------------------------------------
-- Project Name		: Gas leakage detection
-- Module Name		: IOT - Behavioral 
-- Create Date		: 01:00:00 21/02/2021 
-- Design Name		: Gas leakage detection IOT
-- Target Devices	: Spartan 6
-- Tool versions	: ISE project navigator version 14.7 (nt64) 
-- Description: 
-- 		Transmitting Gas leakage data and temperature  data through WiFi involves communication with cloud server using IP Address
--      We used an open source data logger website thingspeak.com to reduce the implementation cost. 
--      Once we created our channel for entering the data into web site, the channel will be allocated with one API key
---     We have created one thingspeak channel and used field 1 for Gas data and field 2 Temperature sensor ouput data
--      thingspeak server will automatically plots the data retrieving from the field which we have entered an integer data of gas and temperature output. 
---     Parallaly we can check the output from LCD display.
-- Revision			: 1.0.0
----------------------------------------------------------------------------------

-- Including libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

entity IOT is
	Port (
		clk		: in STD_LOGIC;							-- Clock signal
		txd 	: out STD_LOGIC;						-- UART Transmitter data
		cs    	: out std_logic;  						-- ADC chip selection
		sc  	: out std_logic;  						-- ADC serial clock
		do    	: out std_logic;  						-- ADC data out
		din   	: in std_logic;   						-- ADC data in
		lcd_e  	: out std_logic;   						-- LCD enable control
		lcd_rs 	: out std_logic;   						-- LCD data or command control
		data   	: out std_logic_vector(7 downto 0)   	-- LCD data line
	);
end IOT;

architecture Behavioral of IOT is

	signal chsel : std_logic := '0'; -- Signal for channel selection
	signal gas_data1,gas_data2,gas_data3	: std_logic_vector(7 downto 0); -- Signals for ASCII conversion of gas data  
	signal temp_data1,temp_data2,temp_data3	: std_logic_vector(7 downto 0); -- Signals for ASCII conversion of temperature data

	---------------------------------------- ADC connection ----------------------------------------
	component ADC 
		Port (
			clk 	: in  STD_LOGIC;						-- ADC clock signal
			cs		: out std_logic;						-- ADC chip selection
			sc  	: out std_logic;						-- ADC serial clock
			do    	: out std_logic;						-- ADC data out
			din   	: in std_logic;							-- ADC data in
			chsel   : in std_logic;							-- ADC channel selection
			gas_data1,gas_data2,gas_data3		: out std_logic_vector(7 downto 0);	-- Signals for ASCII conversion of gas data
			temp_data1,temp_data2,temp_data3	: out std_logic_vector(7 downto 0)	-- Signals for ASCII conversion of temperature data
		);
	end component;

	---------------------------------------- LCD connections ----------------------------------------
	component LCD 
		Port (
			clk 	: in  STD_LOGIC;						-- LCD clock signal
			lcd_e  	: out std_logic;   						-- LCD enable control
			lcd_rs 	: out std_logic;						-- LCD data or command control
			data   	: out std_logic_vector(7 downto 0);   	-- LCD data line
			chsel 	: out std_logic;						-- LCD channel selection
			gas_data1,gas_data2,gas_data3		: in std_logic_vector(7 downto 0); 	-- Signals for ASCII conversion of gas data
			temp_data2,temp_data3				: in std_logic_vector(7 downto 0)	-- Signals for ASCII conversion of temperature data
		);
	end component;

	---------------------------------------- UART connections ----------------------------------------
	component UART 
		Port (
			clk		: in  STD_LOGIC;						-- UART clock signal
			txd 	: out  STD_LOGIC;						-- UART Transmitter data
			gas_data1,gas_data2,gas_data3		: in std_logic_vector(7 downto 0);	-- Signals for ASCII conversion of gas data
			temp_data1,temp_data2,temp_data3	: in std_logic_vector(7 downto 0)	-- Signals for ASCII conversion of temperature data
		);
	end component;

begin

	-- Commponent maping
	A1:ADC port map(clk,cs,sc,do,din,chsel,temp_data1,temp_data2,temp_data3,gas_data1,gas_data2,gas_data3);
	L1:LCD port map(clk,lcd_e,lcd_rs,data,chsel,temp_data2,temp_data3,gas_data1,gas_data2,gas_data3);
	U1:UART port map(clk,txd,temp_data1,temp_data2,temp_data3,gas_data1,gas_data2,gas_data3);

end Behavioral;
