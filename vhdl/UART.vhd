----------------------------------------------------------------------------------
-- Project Name		: Gas leakage detection
-- Module Name		: UART - Behavioral 
-- Create Date		: 01:00:00 21/02/2021 
-- Design Name		: UART communication
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

entity UART is
	Port ( 	
		clk 	: in  STD_LOGIC;						-- UART clock signal
		txd 	: out  STD_LOGIC;						-- UART Transmitter data
		gas_data1,gas_data2,gas_data3		: in std_logic_vector(7 downto 0);	-- Signals for ASCII conversion of gas data
		temp_data1,temp_data2,temp_data3	: in std_logic_vector(7 downto 0)	-- Signals for ASCII conversion of temperature data
	);
end UART;

architecture Behavioral of UART is
	type stat1 is (ready2,start2,stop2);
	signal ps2 :stat1 := ready2; 
	signal start,stop :std_logic;
	signal store :std_logic_vector(7 downto 0);
	signal baud_clk : std_logic; 


	signal siga,sigb: std_logic_vector(2 downto 0):=(others => '0');

	type arr is array (1 to 181) of std_logic_vector(7 downto 0); 
	constant str :  arr :=  (
		X"41",X"54",X"2b",X"52",X"53",X"54",X"0d",X"0a",																				-- AT+RST
		X"41",X"54",X"2b",X"43",X"57",X"4a",X"41",X"50",X"3d",X"22",X"3E",X"3E",X"43",X"72",X"61",X"7A",X"79",X"5F",X"65",X"6E",X"67",X"69",X"6E",X"65",X"65",X"72",X"3C",X"3C",X"22",X"2c",
		X"22",X"31",X"32",X"33",X"34",X"35",X"36",X"37",X"38",X"70",X"74",X"62",X"22",X"0d",X"0a", 										--AT+CWJAP=">>Crazy_engineer","12345678ptb"
		X"41",X"54",X"2b",X"43",X"49",X"50",X"53",X"54",X"41",X"52",X"54",X"3D",X"22",X"54",X"43",X"50",X"22",X"2C",X"22",
		X"31",X"38",X"34",X"2E",X"31",X"30",X"36",X"2E",X"31",X"35",X"33",X"2E",X"31",X"34",X"39",X"22",X"2C",X"38",X"30",X"0d",X"0a",	-- AT+CIPSTART="TCP","184.106.153.149",80
		X"41",X"54",X"2b",X"43",X"49",X"50",X"53",X"45",X"4e",X"44",X"3d",X"36",X"30",X"0d",X"0a",										-- AT+CIPSEND=60
		X"47",X"45",X"54",X"20",X"2F",X"75",X"70",X"64",X"61",X"74",X"65",X"3F",X"61",X"70",X"69",X"5F",X"6B",X"65",X"79",X"3D",  
		X"38",X"4E",X"4E",X"43",X"4F",X"42",X"33",X"4E",X"5A",X"4B",X"33",X"30",X"5A",X"33",X"38",X"35",
		X"26",X"66",X"69",X"65",X"6C",X"64",X"31",X"3D",X"30",X"30",X"30",X"26",X"66",X"69",X"65",X"6C",X"64",X"32",X"3D",X"30",X"30",X"30",X"0d",X"0a", -- GET /update?api_key=8NNCOB3NZK30Z385&field1=000&field2=000
		X"41",X"54",X"2b",X"43",X"49",X"50",X"43",X"4c",X"4f",X"53",X"45",X"0d",X"0a");													-- AT+CIPCLOSE

begin

	process(clk)

		-- 50 x 10^6 / 16*115200 = 27
		variable baud_count : integer range 0 to 27 := 0;

	begin

		-- Baudrate clock generation
		if rising_edge(clk) then
			if baud_count = 27 then
				baud_clk <= '1';
				baud_count := 0;
			else
				baud_count := baud_count + 1;
				baud_clk <= '0';
			end if;
		end if;

	end process; 

	process(baud_clk)

		variable i,k : integer := 0;
		variable j : integer := 0;

	begin

		if rising_edge(baud_clk)then
			if ps2 = ready2 then
				i := i + 1;	
				if i = 8 then
					txd <= '0';
					i := 0;
					ps2 <= start2;
				end if;
			end if;

			---------------------  16xbaudrate sampling method ---------------------------
			if ps2 = start2 then
				i := i + 1;

				if j = 153 then
					store <= gas_data1;
				elsif j = 154 then
					store <= gas_data2;
				elsif j = 155 then
					store <=gas_data3;
				elsif j = 164 then
					store <= temp_data1;
				elsif j = 165 then
					store <= temp_data2;
				elsif j = 166 then
					store <= temp_data3;
				else
					store <= str(j)(7 downto 0);
				end if;

				if i = 16 then
					txd <= store(0);
				end if;

				if i = 32 then
					txd <= store(1);
				end if;

				if i = 48 then
					txd <= store(2);
				end if;

				if i = 64 then
					txd <= store(3);
				end if;

				if i = 80 then
					txd <= store(4);
				end if;

				if i = 96 then
					txd <= store(5);
				end if;

				if i = 112 then
					txd <= store(6);
				end if;

				if i = 128 then
					txd <= store(7);
				end if;

				if i = 144 then
					txd <= '1';
				end if;

				if i = 160 then
					i := 0;
					ps2 <= stop2;
				end if;

			elsif ps2 = stop2 then
				if j = 8 then
					ps2 <= stop2;
					k := k + 1;
					if k = 10000000 then
						j := j + 1;
						k := 0;
						ps2 <= ready2;
					end if;
				elsif j = 53 then
					ps2 <= stop2;
					k := k + 1;
					if k = 50000000 then
						j := j + 1;
						k := 0;
						ps2 <= ready2;
					end if;
				elsif j = 93 then
					ps2 <= stop2;
					k := k + 1;
					if k = 5000000 then
						j := j + 1;
						k := 0;
						ps2 <= ready2;
					end if;
				elsif  j = 108 then
					ps2 <= stop2;
					k := k + 1;
					if k = 5000000 then
						j := j + 1;
						k := 0;
						ps2 <= ready2;
					end if;
				elsif  j = 168 then
					ps2 <= stop2;
					k := k + 1;
					if k = 5000000 then
						j := j + 1;
						k := 0;
						ps2 <= ready2;
					end if;
				elsif j = 181 then
					ps2 <= stop2;
					k := k + 1;
					if k = 5000000 then
						k := 0;
						j := 53;	
						ps2 <= ready2;
					end if;
				else
					j := j + 1;
					ps2 <= ready2;
				end if;
			end if;
		end if;
	end process;
end Behavioral;
