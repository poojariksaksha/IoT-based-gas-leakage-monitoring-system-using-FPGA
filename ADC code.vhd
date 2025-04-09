----------------------------------------------------------------------------------
-- Project Name		: Gas leakage detection
-- Module Name		: ADC - Behavioral 
-- Create Date		: 01:00:00 21/02/2021 
-- Design Name		: ADC reading
-- Target Devices	: Spartan 6
-- Tool versions	: ISE project navigator version 14.7 (nt64) 
-- Description: 
-- 		Reading analog reading of gas sensor and temperature sensor and convert it to digital signal
-- Revision			: 1.0.0
----------------------------------------------------------------------------------

-- Including libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

entity ADC is
	Port ( 	
		clk		: in  STD_LOGIC;						-- ADC clock signal
		cs    	: out std_logic;						-- ADC chip selection
		sc  	: out std_logic;						-- ADC serial clock
		do    	: out std_logic;						-- ADC data out
		din   	: in std_logic;							-- ADC data in
		chsel   : in std_logic;							-- ADC channel selection
		gas_data1,gas_data2,gas_data3		: out std_logic_vector(7 downto 0); 	-- Signals for ASCII conversion of gas data
		temp_data1,temp_data2,temp_data3	: out std_logic_vector(7 downto 0)		-- Signals for ASCII conversion of temperature data
	);
end ADC;

architecture Behavioral of ADC is

	type state is (spi,conversion); 					-- Signals for SPI Communication
	signal presentstate : state := spi;
	signal gas:integer range  0 to 200 :=0; 			-- Signal for Gas Sensor
	signal temp1:integer:=0; 							-- Signal for Temperature Sensor
	signal siga,sigb: std_logic_vector(2 downto 0):=(others => '0');				-- Signals for Binary to BCD and BCD to ASCII

begin

	process(clk)

		variable i,j,k : integer := 0;
		variable tot : std_logic_vector(12 downto 0) := "0000000000000";
		variable temp : std_logic_vector(23 downto 0) := "000000000000000000000000";

	begin

		if rising_edge(clk) then
			if presentstate = spi then
				if i <= 50 then   
					i := i + 1;
					sc <= '1';
				elsif i > 50 and i < 100 then      
					i := i + 1;
					sc <= '0';
				elsif i = 100 then    
					i := 0;    
					if j < 20 then
						j := j + 1;
					elsif j = 20 then
						presentstate <= conversion;
						j := 0; 
					end if;
				end if;
					
				if j = 0 or j >= 19 then
					cs <= '1';
				else
					cs <= '0';
				end if;
						
				if i > 40 and i < 60 then
					case j is
						when 0 =>
							do <= '0';
						when 1 =>
							do <= '1';
						when 2 =>
							do <= '1';
						when 3 =>
							do <= '1';          		-- Channel bit
						when 4 =>
							do <= '1';
						when 5 =>
							if chsel= '1' then
								do <= '1';
							elsif chsel= '0' then
								do <= '0';
							end if;
						when others =>
							null;

					end case;
				end if;
				
				if i >= 0 and i < 10 then
					case j is
						when 7 =>
						tot(12) := din;
						when 8 =>
						tot(11) := din;
						when 9 =>
						tot(10) := din;
						when 10 =>
						tot(9) := din;
						when 11 =>
						tot(8) := din;
						when 12 =>
						tot(7) := din;
						when 13 =>
						tot(6) := din;
						when 14 =>
						tot(5) := din;
						when 15 =>
						tot(4) := din;
						when 16 =>
						tot(3) := din;
						when 17 =>
						tot(2) := din;
						when 18 =>
						tot(1) := din;
						when 19 =>
						tot(0) := din;
						when others =>
						null;
					end case;
				end if; 
			end if;
		--------------------------------------------------------------
			if presentstate = conversion then
				cs <= '1';
				if chsel = '1' then
					temp1 <= (conv_integer(tot(11 downto 0)) * 630)/ 4096;  -------- Temperature Calculation
				elsif chsel = '0' then
					gas <= conv_integer(tot(11 downto 4));
				end if;
				presentstate <= spi;
			end if;
		end if;
	end process;

	----------Temperature Value binary to ASCII Convertion------------
	process (clk)

		variable q1 : integer range 0 to 100 := 0;
		variable p1,p2,p3,p4 : integer range 0 to 10 := 0;

	begin

		if rising_edge(clk) then
			sigb <= sigb + 1;
			case sigb is
				when "000" =>         

					q1 := temp1;
					p1 := 0;
					p2 := 0;
					p3 := 0;
						
				when "001" =>
					if (q1 >= 100) then
						q1 := q1 - 100;
						p1 := p1 + 1;
						sigb <= "001";
					elsif (q1 >= 10) then
						q1 := q1 - 10;
						p2 := p2 + 1;
						sigb <= "001";
					else
							p3 := q1;
					end if;
					
				when "010" =>			
				temp_data1 <= conv_std_logic_vector (p1, 8) + x"30";
				when "011" =>			
				temp_data2 <= conv_std_logic_vector (p2, 8) + x"30";
				when "100" =>			
				temp_data3 <= conv_std_logic_vector (p3, 8) + x"30";
				when others =>
						sigb <= "000";
			end case;
		end if;
	end process;

	----------Gas Value binary to ASCII Convertion------------
	process (clk)

		variable q1 : integer range 0 to 200 := 0;
		variable p1,p2,p3,p4 : integer range 0 to 10 := 0;

	begin

		if rising_edge(clk) then
			siga <= siga + 1;
			case siga is
				when "000" =>         
					q1 := gas;
					p1 := 0;
					p2 := 0;
					p3 := 0;
						
				when "001" =>
					if (q1 >= 100) then
						q1 := q1 - 100;
						p1 := p1 + 1;
						siga <= "001";
					elsif (q1 >= 10) then
						q1 := q1 - 10;
						p2 := p2 + 1;
						siga <= "001";
					else
						p3 := q1;
					end if;
					
				when "010" =>			
				gas_data1 <= conv_std_logic_vector (p1, 8) + x"30";
				when "011" =>			
				gas_data2 <= conv_std_logic_vector (p2, 8) + x"30";
				when "100" =>			
				gas_data3 <= conv_std_logic_vector (p3, 8) + x"30";
				when others =>
						siga <= "000";
			end case;
		end if;
	end process;

end Behavioral;

