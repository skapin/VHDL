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

entity uart_tx is
port (
	wake_up : IN std_logic;
	clk : IN std_logic; 	-- FPGA clock
	data : IN std_logic_vector (7 downto 0);	-- Data to send 
	tx : OUT std_logic;		-- TX link
	busy : OUT std_logic
);
end uart_tx;

architecture behavioral of uart_tx is
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
	
	process (wake_up, baud_clk_8, baud_clk_16, clk)
	variable data_count : integer range 0 to 8 := 0;
	
	constant stop_bit : std_logic := '1';
	constant start_bit : std_logic := '0';
	constant data_length : integer := 8; 
	constant waiting_state : std_logic :='1';
	
	begin
		if ( rising_edge(clk) ) then
			if ( state = 0 ) then 		-- State Idle, wait for start bit
				tx <= waiting_state;
				if ( wake_up = '1' ) then	-- wake up signal, so we change state of the FSM
					baud_clock_enable <= '1';
					state <= 1;
					data_count := 0;
					tx <= start_bit;
					busy <= '1';
				end if;
			elsif ( state = 1 and baud_clk_16 ='1' ) then	--send the value to TX
				tx <= data(data_count);
				data_count := data_count +1;
				if ( data_count >= data_length ) then	-- If all datas send, change state.
					state <= 2;
				end if;
			elsif ( state = 2 and baud_clk_16 ='1' ) then
				state <= 3;
				tx <= stop_bit;
			elsif ( state = 3 and baud_clk_16 ='1' ) then
				baud_clock_enable <= '0';
				busy <='0';
				state <=0;
			end if;
		end if;
	end process;
end behavioral;





