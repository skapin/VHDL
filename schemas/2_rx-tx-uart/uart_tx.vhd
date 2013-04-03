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
	data : IN std_logic_vector (7 downto 0);
	clk : IN std_logic; 	-- FPGA clock
	tx : OUT std_logic;		-- TX link
	busy : OUT std_logic
);
end uart_tx;

architecture behavioral of uart_tx is
signal baud_clock_enable : std_logic := '0' ;
signal baud_clk_8 : std_logic :='0';
signal baud_clk_16 : std_logic :='0';
signal state : integer range 0 to 7 :=0;
signal data_buffer : std_logic_vector ( 7 downto 0) := x"FF";
signal wake_up : std_logic := '1';
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
	
	process (baud_clk_16,clk)
	variable data_count : integer range 0 to 8 := 0;
	variable tx_intern : std_logic :='0';

	constant data_length : integer := 8; 
	constant waiting_state : std_logic :='1';
	constant start_bit : std_logic := '0';
	constant stop_bit :std_logic := '1';
	
	begin
		if ( rising_edge(clk) ) then
		case state is 
			when 0 => -- idle state, waiting for start bit, baudrate clock is off.
				tx <= waiting_state;
				baud_clock_enable <= '0';
				if ( wake_up = '1' ) then
					data_buffer <= data;
					state <= 1;
					baud_clock_enable <= '1';
					
				end if;
			when 1 => -- start bit state
				tx <= start_bit;	
				if ( baud_clk_16 = '1' ) then 		
					state <= 2;
					data_count := 0;
				end if;
			when 2 => -- 8 data bit
				tx <= data_buffer(data_count);	
				if ( baud_clk_16 = '1' ) then 		
					data_count := data_count + 1;
				end if;
				if ( data_count = data_length ) then -- fin de la tram de 8 bit
					state <= 3;
					data_count := 0;
				end if;
			when 3 => -- stop bit state
				tx <= stop_bit;	
				if ( baud_clk_16 = '1' ) then 		
					state <= 4;
				end if;
			when 4 => -- stop bit state
				tx <= waiting_state;	
				if ( baud_clk_16 = '1' ) then 		
					state <= 0;
					baud_clock_enable <= '0';
				end if;
			when others =>
				tx <= waiting_state;
				state <= 0;
		end case;
		busy <= baud_clk_16;
		end if;
	end process;
end behavioral;





