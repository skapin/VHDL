-- Company: <Name>
--
-- File: uart.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::IGLOO> <Die::AGLN250V2> <Package::100 VQFP>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_rx is
port (
	clk : IN std_logic; 	-- FPGA clock
	rx : IN std_logic;		-- RX link
	data : OUT std_logic_vector (7 downto 0)
);
end uart_rx;

architecture behavioral of uart_rx is
signal baud_clock_enable : std_logic := '0' ;
signal baud_clk_8 : std_logic :='0';
signal baud_clk_16 : std_logic :='0';
signal state : integer range 0 to 7 :=0;
component baud_clock
port (
	clk : IN std_logic;		 	-- FPGA clock
--	divisor : IN integer;		-- Divisor
	enable : IN std_logic;		-- Enable the baudrate clock. set to '1' to enable, '0' to stop and reset values
	baud_clk_8 : OUT std_logic;	-- Output baudrate clock
	baud_clk_16 : OUT std_logic	-- Output baudrate clock
);
end component;

begin
	baud_component : baud_clock port map (clk, baud_clock_enable, baud_clk_8, baud_clk_16);
	process (baud_clk_8, baud_clk_16, clk)
	variable data_count : integer range 0 to 8 := 0;
	variable rx_reg : std_logic_vector ( 7 downto 0 ) := x"00" ;
	constant stop_bit : std_logic := '1';
	constant start_bit : std_logic := '0';
	constant data_length : integer := 8; 
	variable rx_in : std_logic;
	begin
		if ( rising_edge(clk) ) then
			rx_in := not rx;
			if ( state = 0 ) then 		-- State Idle, wait for start bit
				data <= rx_reg;
				if ( rx_in = start_bit ) then	-- Start bit : initialize values
					baud_clock_enable <= '1';
					state <= 1;
				end if;
			elsif ( state = 1 and baud_clk_8 ='1' ) then	--Still the start bit ?
				if ( rx_in = start_bit ) then
					data_count := 0;
					rx_reg := x"00";
					state <= 2;
				else
					state <=0;
				end if;
			elsif ( state = 2 and baud_clk_16 ='1' ) then	--Retreive and store the value from Rx to Rx_reg buffer
				rx_reg(data_count) := rx_in;
				data_count := data_count +1;
				if ( data_count >= data_length ) then	-- If all datas raceived, change state.
					state <= 3;
				end if;
			elsif ( state = 3 and baud_clk_16 ='1' ) then
				if ( rx_in = stop_bit ) then
					state <= 0;
					data <= rx_reg;
					baud_clock_enable <= '0';
				end if;
			end if;
		end if;
	end process;
end behavioral;





